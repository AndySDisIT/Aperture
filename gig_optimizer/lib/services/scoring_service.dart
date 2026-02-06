import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScoringService {
  ScoringService({required this.costPerMile});

  final double costPerMile;

  factory ScoringService.fromEnv() {
    final costValue = dotenv.env['TRAVEL_COST_PER_MILE'];
    final parsed = costValue == null || costValue.isEmpty ? 0.67 : double.parse(costValue);
    return ScoringService(costPerMile: parsed);
  }

  double effectiveHourlyRate({
    required double pay,
    required double distanceMiles,
    required int estimatedDurationMinutes,
    required int driveMinutes,
  }) {
    // Effective hourly rate uses earnings minus travel cost over total time.
    final travelCost = distanceMiles * costPerMile;
    final totalMinutes = estimatedDurationMinutes + driveMinutes;
    if (totalMinutes == 0) {
      return 0;
    }
    return ((pay - travelCost) / totalMinutes) * 60;
  }

  int comparePriority({
    required double hourlyRateA,
    required double hourlyRateB,
    required DateTime deadlineA,
    required DateTime deadlineB,
    required double distanceA,
    required double distanceB,
  }) {
    final rateCompare = hourlyRateB.compareTo(hourlyRateA);
    if (rateCompare != 0) {
      return rateCompare;
    }
    final deadlineCompare = deadlineA.compareTo(deadlineB);
    if (deadlineCompare != 0) {
      return deadlineCompare;
    }
    return distanceA.compareTo(distanceB);
  }
}
