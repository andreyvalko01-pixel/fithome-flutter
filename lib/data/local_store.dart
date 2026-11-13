import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

/// Локальне сховище: історія тренувань і налаштування.
/// Все пишеться спершу сюди — застосунок повністю працює офлайн.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _sessionsKey = 'sessions';
  static const _goalKey = 'daily_step_goal';
  static const _reminderKey = 'reminder_hour';

  static Future<LocalStore> open() async =>
      LocalStore(await SharedPreferences.getInstance());

  List<Session> sessions() {
    final raw = _prefs.getStringList(_sessionsKey) ?? [];
    return raw
        .map((s) => Session.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
  }

  Future<void> saveSessions(List<Session> sessions) => _prefs.setStringList(
    _sessionsKey,
    sessions.map((s) => jsonEncode(s.toJson())).toList(),
  );

  Future<void> addSession(Session session) =>
      saveSessions([session, ...sessions()]);

  /// Тренування, які ще не потрапили на сервер (зроблені без інтернету).
  List<Session> pending() => sessions().where((s) => !s.synced).toList();

  Future<void> markSynced(Iterable<String> ids) async {
    final set = ids.toSet();
    await saveSessions([
      for (final s in sessions())
        set.contains(s.id) ? s.copyWith(synced: true) : s,
    ]);
  }

  int get dailyStepGoal => _prefs.getInt(_goalKey) ?? 8000;
  Future<void> setDailyStepGoal(int value) => _prefs.setInt(_goalKey, value);

  int? get reminderHour => _prefs.getInt(_reminderKey);
  Future<void> setReminderHour(int? hour) => hour == null
      ? _prefs.remove(_reminderKey)
      : _prefs.setInt(_reminderKey, hour);
}
