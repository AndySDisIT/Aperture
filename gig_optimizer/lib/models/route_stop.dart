class RouteStop {
  const RouteStop({
    required this.id,
    required this.routeId,
    required this.gigId,
    required this.stopOrder,
    required this.arrivalTime,
  });

  final String id;
  final String routeId;
  final String gigId;
  final int stopOrder;
  final DateTime arrivalTime;

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      gigId: json['gig_id'] as String,
      stopOrder: json['stop_order'] as int,
      arrivalTime: DateTime.parse(json['arrival_time'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'gig_id': gigId,
      'stop_order': stopOrder,
      'arrival_time': arrivalTime.toIso8601String(),
    };
  }
}
