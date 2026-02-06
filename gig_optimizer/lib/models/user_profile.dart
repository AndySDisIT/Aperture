class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.minHourlyRate,
    required this.maxDistanceMiles,
    required this.availableStartTime,
    required this.availableEndTime,
  });

  final String id;
  final String email;
  final double minHourlyRate;
  final double maxDistanceMiles;
  final String availableStartTime;
  final String availableEndTime;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      minHourlyRate: (json['min_hourly_rate'] as num).toDouble(),
      maxDistanceMiles: (json['max_distance_miles'] as num).toDouble(),
      availableStartTime: json['available_start_time'] as String,
      availableEndTime: json['available_end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'min_hourly_rate': minHourlyRate,
      'max_distance_miles': maxDistanceMiles,
      'available_start_time': availableStartTime,
      'available_end_time': availableEndTime,
    };
  }
}
