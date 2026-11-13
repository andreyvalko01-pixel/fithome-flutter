import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../providers.dart';
import '../services/workout_runner.dart';
import '../theme.dart';

/// Огляд програми + кнопка старту.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key, required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('${workout.durationMinutes} хв')),
              Chip(label: Text(workout.level)),
              if (workout.rounds > 1)
                Chip(label: Text('${workout.rounds} кола')),
            ],
          ),
          const SizedBox(height: 12),
          for (final (i, e) in workout.exercises.indexed)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: brand.withValues(alpha: 0.1),
                  child: Text('${i + 1}'),
                ),
                title: Text(
                  e.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(e.hint),
                trailing: Text(
                  e.isTimed ? '${e.seconds} с' : '×${e.reps}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: brand,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Почати тренування'),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutPlayer(workout: workout),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Плеєр: таймер вправи / відпочинку, підказка, наступна вправа.
class WorkoutPlayer extends ConsumerStatefulWidget {
  const WorkoutPlayer({super.key, required this.workout});

  final Workout workout;

  @override
  ConsumerState<WorkoutPlayer> createState() => _WorkoutPlayerState();
}

class _WorkoutPlayerState extends ConsumerState<WorkoutPlayer> {
  late final WorkoutRunner runner = WorkoutRunner(widget.workout);
  Timer? _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      setState(runner.tick);
      if (runner.phase == Phase.finished) _finish();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final minutes = (runner.elapsed / 60).ceil();
    await ref
        .read(sessionsProvider.notifier)
        .add(
          Session(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            workoutId: widget.workout.id,
            finishedAt: DateTime.now(),
            minutes: minutes,
            calories: minutes * 7,
          ),
        );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (runner.phase == Phase.finished)
      return _FinishedView(
        workout: widget.workout,
        minutes: (runner.elapsed / 60).ceil(),
      );

    final isRest = runner.phase == Phase.rest;
    final e = runner.current;
    final color = isRest ? const Color(0xFF16A34A) : brand;

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(
          widget.workout.rounds > 1
              ? 'Коло ${runner.round} з ${widget.workout.rounds}'
              : widget.workout.title,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: runner.progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
              const Spacer(),
              Text(
                isRest ? 'Відпочинок' : e.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isRest ? 'Далі: ${runner.next?.name ?? ''}' : e.hint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Text(
                runner.secondsLeft != null
                    ? '${runner.secondsLeft}'
                    : '×${e.reps}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (runner.secondsLeft == null)
                const Text(
                  'повторень',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              const Spacer(),
              Row(
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                    ),
                    iconSize: 32,
                    icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                    onPressed: () => setState(() => _paused = !_paused),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                      ),
                      onPressed: () {
                        setState(runner.skip);
                        if (runner.phase == Phase.finished) _finish();
                      },
                      child: Text(
                        isRest
                            ? 'Пропустити відпочинок'
                            : (e.isTimed ? 'Пропустити' : 'Готово'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({required this.workout, required this.minutes});

  final Workout workout;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text(
                'Тренування завершено!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '${workout.title} · $minutes хв · ~${minutes * 7} ккал',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('На головну'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
