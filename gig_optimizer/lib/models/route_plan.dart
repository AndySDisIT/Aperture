class RoutePlan {
  const RoutePlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalPay,
    required this.totalDriveMinutes,
  });

  final String id;
  final String userId;
  final DateTime date;
  final double totalPay;
  final int totalDriveMinutes;

  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    return RoutePlan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalPay: (json['total_pay'] as num).toDouble(),
      totalDriveMinutes: json['total_drive_minutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'total_pay': totalPay,
      'total_drive_minutes': totalDriveMinutes,
    };
  }
}
