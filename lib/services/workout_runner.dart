import '../models.dart';

enum Phase { exercise, rest, finished }

/// Логіка плеєра тренування без UI: які вправа, фаза і скільки секунд лишилось.
/// Таймер у віджеті просто викликає tick() раз на секунду — так логіку легко тестувати.
class WorkoutRunner {
  WorkoutRunner(this.workout) {
    _startExercise();
  }

  final Workout workout;

  int round = 1;
  int index = 0;
  Phase phase = Phase.exercise;

  /// Для вправ на повтори таймер не йде — чекаємо, поки користувач натисне «Готово».
  int? secondsLeft;
  int elapsed = 0;

  Exercise get current => workout.exercises[index];

  Exercise? get next {
    if (index + 1 < workout.exercises.length)
      return workout.exercises[index + 1];
    if (round < workout.rounds) return workout.exercises.first;
    return null;
  }

  int get totalSteps => workout.exercises.length * workout.rounds;
  int get doneSteps => (round - 1) * workout.exercises.length + index;
  double get progress => phase == Phase.finished ? 1 : doneSteps / totalSteps;

  void _startExercise() {
    phase = Phase.exercise;
    secondsLeft = current.seconds;
  }

  void tick() {
    if (phase == Phase.finished) return;
    elapsed++;
    if (secondsLeft == null) return;

    secondsLeft = secondsLeft! - 1;
    if (secondsLeft! <= 0) {
      phase == Phase.exercise ? _finishExercise() : _goNext();
    }
  }

  /// Кнопка «Готово» для вправ на повтори або «Пропустити» для будь-якої фази.
  void skip() {
    if (phase == Phase.exercise) {
      _finishExercise();
    } else if (phase == Phase.rest) {
      _goNext();
    }
  }

  void _finishExercise() {
    if (next == null) {
      phase = Phase.finished;
      secondsLeft = null;
      return;
    }
    phase = Phase.rest;
    secondsLeft = current.rest;
  }

  void _goNext() {
    if (index + 1 < workout.exercises.length) {
      index++;
    } else {
      round++;
      index = 0;
    }
    _startExercise();
  }
}
