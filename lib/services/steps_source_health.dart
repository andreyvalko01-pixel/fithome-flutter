import 'package:health/health.dart';

import '../models.dart';
import 'steps_service.dart';

/// iOS — Apple Health, Android — Health Connect. Обидва через пакет health.
StepsService createStepsService() => HealthStepsService();

class HealthStepsService implements StepsService {
  final _health = Health();
  bool _authorized = false;

  @override
  bool get isReal => _authorized;

  @override
  Future<bool> requestPermission() async {
    await _health.configure();
    _authorized = await _health.requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ],
    );
    return _authorized;
  }

  @override
  Future<List<DaySteps>> lastDays(int days) async {
    if (!_authorized && !await requestPermission()) {
      return DemoStepsService().lastDays(days);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DaySteps>[];
    for (var i = days - 1; i >= 0; i--) {
      final start = today.subtract(Duration(days: i));
      final end = i == 0 ? now : start.add(const Duration(days: 1));
      final steps = await _health.getTotalStepsInInterval(start, end) ?? 0;
      result.add(DaySteps(start, steps));
    }
    return result;
  }
}
