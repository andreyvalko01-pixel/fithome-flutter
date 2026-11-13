import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/programs.dart';
import '../models.dart';
import '../providers.dart';
import '../theme.dart';

const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  bool _month = false;

  @override
  Widget build(BuildContext context) {
    final steps = ref.watch(stepsProvider);
    final goal = ref.watch(stepGoalProvider);
    final sessions = ref.watch(sessionsProvider);
    final days = _month ? 30 : 7;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Прогрес',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Тиждень')),
                ButtonSegment(value: true, label: Text('Місяць')),
              ],
              selected: {_month},
              onSelectionChanged: (s) => setState(() => _month = s.first),
              showSelectedIcon: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
            child: steps.when(
              loading: () => const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e'),
              data: (all) => _StepsChart(
                data: all.sublist(all.length - days),
                goal: goal,
                month: _month,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Totals(sessions: sessions, days: days),
        const SizedBox(height: 20),
        Text(
          'Історія тренувань',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Ще жодного тренування — почніть з «Ранкової зарядки» 💪',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        for (final s in sessions.take(10))
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
              title: Text(workoutById(s.workoutId).title),
              subtitle: Text(
                '${MaterialLocalizations.of(context).formatShortDate(s.finishedAt)} · ${s.minutes} хв · ${s.calories} ккал',
              ),
              trailing: Icon(
                s.synced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                color: s.synced ? brand : Colors.grey,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}

class _StepsChart extends StatelessWidget {
  const _StepsChart({
    required this.data,
    required this.goal,
    required this.month,
  });

  final List<DaySteps> data;
  final int goal;
  final bool month;

  @override
  Widget build(BuildContext context) {
    final avg = data.fold<int>(0, (s, d) => s + d.steps) ~/ data.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'У середньому $avg кроків на день',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY:
                  (data.map((d) => d.steps).reduce((a, b) => a > b ? a : b) *
                          1.15)
                      .clamp(goal * 1.1, double.infinity)
                      .toDouble(),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: goal.toDouble(),
                    color: accent,
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final d = data[value.toInt()].day;
                      // на місячному графіку підписуємо кожен 5-й день, щоб не злипалось
                      if (month && value.toInt() % 5 != 4)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          month ? '${d.day}' : _weekdays[d.weekday - 1],
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (final (i, d) in data.indexed)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: d.steps.toDouble(),
                        width: month ? 6 : 22,
                        borderRadius: BorderRadius.circular(6),
                        color: d.steps >= goal
                            ? brand
                            : brand.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.sessions, required this.days});

  final List<Session> sessions;
  final int days;

  @override
  Widget build(BuildContext context) {
    final from = DateTime.now().subtract(Duration(days: days));
    final period = sessions.where((s) => s.finishedAt.isAfter(from));
    final items = [
      ('${period.length}', 'тренувань'),
      ('${period.fold<int>(0, (s, e) => s + e.minutes)}', 'хвилин'),
      ('${period.fold<int>(0, (s, e) => s + e.calories)}', 'ккал'),
    ];
    return Row(
      children: [
        for (final (i, item) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: brand,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
