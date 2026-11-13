import '../models.dart';
import 'steps_source_stub.dart' if (dart.library.io) 'steps_source_health.dart';

/// Кроки за останні дні. На телефоні — з Apple Health / Health Connect,
/// у веб-версії таких даних немає, тому показуємо приклад (і чесно про це пишемо в UI).
abstract class StepsService {
  /// true — дані справжні, false — демонстраційні
  bool get isReal;

  Future<bool> requestPermission();

  /// Кроки за кожен з останніх [days] днів, від найстарішого до сьогодні.
  Future<List<DaySteps>> lastDays(int days);

  factory StepsService() => createStepsService();
}

/// Демо-дані для веб-версії і для випадку, коли користувач не дав доступ.
class DemoStepsService implements StepsService {
  @override
  bool get isReal => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<List<DaySteps>> lastDays(int days) async {
    final today = DateTime.now();
    const pattern = [
      6200,
      8400,
      7100,
      10300,
      5400,
      9100,
      11800,
      7600,
      8900,
      6700,
      9800,
      12400,
      4300,
      8100,
    ];
    return List.generate(days, (i) {
      final day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: days - 1 - i));
      return DaySteps(day, pattern[(day.day + day.month) % pattern.length]);
    });
  }
}
