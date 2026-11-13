import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local_store.dart';
import 'models.dart';
import 'services/steps_service.dart';
import 'services/sync_service.dart';

/// Підміняється в main() вже відкритим сховищем.
final storeProvider = Provider<LocalStore>((ref) => throw UnimplementedError());

final syncProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref.watch(storeProvider));
  ref.onDispose(service.dispose);
  return service;
});

final stepsServiceProvider = Provider<StepsService>((ref) => StepsService());

/// Кроки за останні 30 днів — і для головного екрана, і для графіків.
final stepsProvider = FutureProvider<List<DaySteps>>(
  (ref) => ref.watch(stepsServiceProvider).lastDays(30),
);

class SessionsNotifier extends Notifier<List<Session>> {
  @override
  List<Session> build() => ref.watch(storeProvider).sessions();

  Future<void> add(Session session) async {
    await ref.read(storeProvider).addSession(session);
    state = ref.read(storeProvider).sessions();
    // офлайн — нічого страшного, синхронізуємо пізніше
    await ref.read(syncProvider).syncPending();
    state = ref.read(storeProvider).sessions();
  }
}

final sessionsProvider = NotifierProvider<SessionsNotifier, List<Session>>(
  SessionsNotifier.new,
);

class GoalNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(storeProvider).dailyStepGoal;

  Future<void> set(int value) async {
    await ref.read(storeProvider).setDailyStepGoal(value);
    state = value;
  }
}

final stepGoalProvider = NotifierProvider<GoalNotifier, int>(GoalNotifier.new);
