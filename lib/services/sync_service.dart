import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../firebase_options.dart';

/// Синхронізація з Firebase:
///  * тренування спершу пишуться локально, а тут відправляються в Firestore, щойно є інтернет;
///  * анонімний вхід — щоб не змушувати реєструватися, акаунт можна прив'язати пізніше;
///  * push-нагадування приходять через FCM (тема "workout_reminders").
class SyncService {
  SyncService(this._store);

  final LocalStore _store;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  bool _ready = false;

  bool get isEnabled => _ready;

  Future<void> start() async {
    if (!firebaseConfigured) {
      debugPrint(
        'Firebase не налаштовано (flutterfire configure) — працюємо лише локально',
      );
      return;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      _ready = true;
    } catch (e) {
      debugPrint('Firebase недоступний: $e');
      return;
    }

    // повертається мережа — відправляємо все, що накопичилось офлайн
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) syncPending();
    });
    await syncPending();
    await _setupPush();
  }

  Future<int> syncPending() async {
    if (!_ready) return 0;
    final pending = _store.pending();
    if (pending.isEmpty) return 0;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final batch = FirebaseFirestore.instance.batch();
    final sessions = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sessions');
    for (final s in pending) {
      batch.set(sessions.doc(s.id), {
        ...s.toJson()..remove('synced'),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
      await _store.markSynced(pending.map((s) => s.id));
      return pending.length;
    } on FirebaseException catch (e) {
      // немає мережі або правила доступу — спробуємо наступного разу
      debugPrint('Синхронізація не вдалась: ${e.code}');
      return 0;
    }
  }

  Future<void> _setupPush() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    if (!kIsWeb) {
      await messaging.subscribeToTopic('workout_reminders');
    }
    final token = await messaging.getToken();
    if (token != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      // година нагадування зберігається поруч з токеном — Cloud Function шле push саме тоді
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'reminderHour': _store.reminderHour,
      }, SetOptions(merge: true));
    }
  }

  void dispose() => _connectivity?.cancel();
}
