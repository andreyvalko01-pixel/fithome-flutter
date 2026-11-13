import 'package:flutter/material.dart';

import '../data/programs.dart';
import '../theme.dart';
import 'workout_screen.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  static const _icons = {
    'morning': Icons.wb_sunny_outlined,
    'fullbody': Icons.fitness_center,
    'abs': Icons.bolt,
    'stretch': Icons.self_improvement,
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Програми',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Без інвентарю, можна вдома',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        for (final w in programs) ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: brand.withValues(alpha: 0.1),
                child: Icon(_icons[w.id] ?? Icons.fitness_center, color: brand),
              ),
              title: Text(
                w.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${w.focus} · ${w.level}\n${w.durationMinutes} хв · ~${w.calories} ккал'
                '${w.rounds > 1 ? ' · ${w.rounds} кола' : ''}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorkoutScreen(workout: w)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
