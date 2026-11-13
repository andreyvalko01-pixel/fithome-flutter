/// Вправа у програмі: або на час (seconds), або на повтори (reps).
class Exercise {
  const Exercise({
    required this.name,
    required this.hint,
    this.seconds,
    this.reps,
    this.rest = 20,
  }) : assert(seconds != null || reps != null);

  final String name;
  final String hint;
  final int? seconds;
  final int? reps;

  /// відпочинок після вправи, секунд
  final int rest;

  bool get isTimed => seconds != null;
}

class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.level,
    required this.focus,
    required this.exercises,
    this.rounds = 1,
  });

  final String id;
  final String title;
  final String level;
  final String focus;
  final List<Exercise> exercises;
  final int rounds;

  /// Орієнтовна тривалість: вправи на повтори рахуємо по 3 секунди на повтор.
  int get durationMinutes {
    final perRound = exercises.fold<int>(
      0,
      (sum, e) => sum + (e.seconds ?? e.reps! * 3) + e.rest,
    );
    return (perRound * rounds / 60).ceil();
  }

  /// Дуже груба оцінка калорій для домашніх тренувань (~7 ккал/хв).
  int get calories => durationMinutes * 7;
}

/// Завершене тренування. Спершу пишеться локально, на сервер синхронізується потім.
class Session {
  const Session({
    required this.id,
    required this.workoutId,
    required this.finishedAt,
    required this.minutes,
    required this.calories,
    this.synced = false,
  });

  final String id;
  final String workoutId;
  final DateTime finishedAt;
  final int minutes;
  final int calories;
  final bool synced;

  Session copyWith({bool? synced}) => Session(
    id: id,
    workoutId: workoutId,
    finishedAt: finishedAt,
    minutes: minutes,
    calories: calories,
    synced: synced ?? this.synced,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'finishedAt': finishedAt.toIso8601String(),
    'minutes': minutes,
    'calories': calories,
    'synced': synced,
  };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'] as String,
    workoutId: json['workoutId'] as String,
    finishedAt: DateTime.parse(json['finishedAt'] as String),
    minutes: json['minutes'] as int,
    calories: json['calories'] as int,
    synced: json['synced'] as bool? ?? false,
  );
}

/// Кроки за конкретний день.
class DaySteps {
  const DaySteps(this.day, this.steps);

  final DateTime day;
  final int steps;
}
