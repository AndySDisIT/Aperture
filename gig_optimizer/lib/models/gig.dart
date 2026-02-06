enum GigStatus {
  available,
  approved,
  completed,
  submitted,
  paid,
}

class Gig {
  const Gig({
    required this.id,
    required this.userId,
    required this.sourceId,
    required this.title,
    required this.pay,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.deadline,
    required this.estimatedDurationMinutes,
    required this.status,
  });

  final String id;
  final String userId;
  final String sourceId;
  final String title;
  final double pay;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime deadline;
  final int estimatedDurationMinutes;
  final GigStatus status;

  factory Gig.fromJson(Map<String, dynamic> json) {
    return Gig(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sourceId: json['source_id'] as String,
      title: json['title'] as String,
      pay: (json['pay'] as num).toDouble(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline'] as String),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int,
      status: GigStatus.values.firstWhere(
        (status) => status.name == (json['status'] as String).toLowerCase(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'source_id': sourceId,
      'title': title,
      'pay': pay,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'deadline': deadline.toIso8601String(),
      'estimated_duration_minutes': estimatedDurationMinutes,
      'status': status.name,
    };
  }
}
