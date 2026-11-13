import 'package:fit_home/models.dart';
import 'package:fit_home/services/workout_runner.dart';
import 'package:flutter_test/flutter_test.dart';

const workout = Workout(
  id: 't',
  title: 'Тест',
  level: '',
  focus: '',
  rounds: 2,
  exercises: [
    Exercise(name: 'A', hint: '', seconds: 3, rest: 2),
    Exercise(name: 'B', hint: '', reps: 10, rest: 1),
  ],
);

void main() {
  test('timed exercise goes to rest, then to next exercise', () {
    final r = WorkoutRunner(workout);
    expect(r.current.name, 'A');
    expect(r.secondsLeft, 3);

    for (var i = 0; i < 3; i++) {
      r.tick();
    }
    expect(r.phase, Phase.rest);
    expect(r.secondsLeft, 2);

    r.tick();
    r.tick();
    expect(r.phase, Phase.exercise);
    expect(r.current.name, 'B');
  });

  test('reps exercise waits for "done"', () {
    final r = WorkoutRunner(workout)..skip()..skip();
    expect(r.current.name, 'B');
    expect(r.secondsLeft, isNull);

    r.tick();
    r.tick();
    expect(r.phase, Phase.exercise, reason: 'без натискання «Готово» не переходимо далі');
  });

  test('second round and finish', () {
    final r = WorkoutRunner(workout);
    // A -> rest -> B -> rest -> (коло 2) A -> rest -> B -> кінець
    for (var i = 0; i < 7; i++) {
      r.skip();
    }
    expect(r.round, 2);
    expect(r.phase, Phase.finished);
    expect(r.progress, 1);
  });

  test('duration estimate', () {
    // (3 + 2) + (10*3 + 1) = 36 с на коло, 2 кола = 72 с -> 2 хв
    expect(workout.durationMinutes, 2);
  });
}
