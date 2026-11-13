import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(stepGoalProvider);
    final store = ref.watch(storeProvider);
    final sync = ref.watch(syncProvider);
    final pending = ref.watch(sessionsProvider).where((s) => !s.synced).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Профіль',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ціль: $goal кроків на день',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Slider(
                  value: goal.toDouble(),
                  min: 3000,
                  max: 15000,
                  divisions: 24,
                  label: '$goal',
                  onChanged: (v) =>
                      ref.read(stepGoalProvider.notifier).set(v.round()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: const Text('Нагадування про тренування'),
            subtitle: Text(
              store.reminderHour == null
                  ? 'Вимкнено'
                  : 'Щодня о ${store.reminderHour}:00',
            ),
            value: store.reminderHour != null,
            onChanged: (on) async {
              await store.setReminderHour(on ? 19 : null);
              ref.invalidate(storeProvider);
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(
              sync.isEnabled
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined,
            ),
            title: Text(
              sync.isEnabled
                  ? 'Синхронізація увімкнена'
                  : 'Дані зберігаються на пристрої',
            ),
            subtitle: Text(
              pending == 0
                  ? 'Усе збережено'
                  : 'Чекають відправки: $pending — відправимо, щойно з’явиться інтернет',
            ),
          ),
        ),
      ],
    );
  }
}
