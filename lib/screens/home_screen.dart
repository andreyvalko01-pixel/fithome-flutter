import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/programs.dart';
import '../providers.dart';
import '../theme.dart';
import 'workout_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(stepsProvider);
    final goal = ref.watch(stepGoalProvider);
    final sessions = ref.watch(sessionsProvider);
    final isReal = ref.watch(stepsServiceProvider).isReal;

    final today = DateTime.now();
    final todaySessions = sessions
        .where((s) => DateUtils.isSameDay(s.finishedAt, today))
        .toList();
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekSessions = sessions
        .where((s) => s.finishedAt.isAfter(weekAgo))
        .toList();

    // рекомендуємо програму, яку давно не робили
    final suggested = programs.firstWhere(
      (p) => !weekSessions.any((s) => s.workoutId == p.id),
      orElse: () => programs.first,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Привіт! 👋',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Невеликий крок щодня — і результат прийде',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // кільце кроків
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: steps.when(
              loading: () => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Не вдалося отримати кроки: $e'),
              data: (days) {
                final todaySteps = days.last.steps;
                return Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: _RingPainter(todaySteps / goal),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$todaySteps',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'з $goal',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Кроки сьогодні',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Stat(
                            icon: Icons.local_fire_department,
                            color: accent,
                            text: '${(todaySteps * 0.04).round()} ккал',
                          ),
                          _Stat(
                            icon: Icons.route,
                            color: brand,
                            text:
                                '${(todaySteps * 0.75 / 1000).toStringAsFixed(1)} км',
                          ),
                          if (!isReal)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Приклад даних: у веб-версії немає доступу до Health',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Тренувань за тиждень',
                  value: '${weekSessions.length}',
                  icon: Icons.event_available,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Хвилин сьогодні',
                  value:
                      '${todaySessions.fold<int>(0, (s, e) => s + e.minutes)}',
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Тренування дня',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutScreen(workout: suggested),
            ),
          ),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [brand, Color(0xFF8B5CF6)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggested.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${suggested.durationMinutes} хв · ${suggested.exercises.length} вправ · ${suggested.level}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.play_arrow_rounded, color: brand, size: 32),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: brand),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final base = Paint()
      ..color = const Color(0xFFE8E8F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final arc = Paint()
      ..shader = const SweepGradient(colors: [brand, accent, brand])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
