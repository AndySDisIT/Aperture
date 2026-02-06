import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MapsService {
  MapsService(this.apiKey);

  final String apiKey;

  factory MapsService.fromEnv() {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GOOGLE_MAPS_API_KEY is missing in .env');
    }
    return MapsService(apiKey);
  }

  Future<Map<String, dynamic>> geocodeAddress(String address) async {
    // Uses Google Geocoding API to resolve a street address.
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': address,
      'key': apiKey,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to geocode address');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if ((data['results'] as List).isEmpty) {
      throw Exception('No geocoding results');
    }
    return data;
  }

  Future<DistanceMatrixResult> distanceMatrix({
    required String origin,
    required String destination,
  }) async {
    // Fetches driving distance and duration for scoring.
    final uri = Uri.https('maps.googleapis.com', '/maps/api/distancematrix/json', {
      'origins': origin,
      'destinations': destination,
      'key': apiKey,
      'units': 'imperial',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch distance matrix');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final element = data['rows'][0]['elements'][0];
    return DistanceMatrixResult(
      distanceMiles: (element['distance']['value'] as num).toDouble() / 1609.34,
      durationMinutes: ((element['duration']['value'] as num).toDouble() / 60).round(),
    );
  }

  Future<RouteOptimizationResult> optimizeRoute({
    required String origin,
    required String destination,
    required List<String> waypoints,
  }) async {
    final waypointParam = 'optimize:true|${waypoints.join('|')}';
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': origin,
      'destination': destination,
      'waypoints': waypointParam,
      'key': apiKey,
      'units': 'imperial',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to optimize route');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final route = (data['routes'] as List).first as Map<String, dynamic>;
    final order = (route['waypoint_order'] as List).cast<int>();
    int totalSeconds = 0;
    for (final leg in route['legs'] as List) {
      totalSeconds += (leg['duration']['value'] as num).toInt();
    }
    return RouteOptimizationResult(
      waypointOrder: order,
      totalDriveMinutes: (totalSeconds / 60).round(),
    );
  }
}

class DistanceMatrixResult {
  const DistanceMatrixResult({
    required this.distanceMiles,
    required this.durationMinutes,
  });

  final double distanceMiles;
  final int durationMinutes;
}

class RouteOptimizationResult {
  const RouteOptimizationResult({
    required this.waypointOrder,
    required this.totalDriveMinutes,
  });

  final List<int> waypointOrder;
  final int totalDriveMinutes;
}
