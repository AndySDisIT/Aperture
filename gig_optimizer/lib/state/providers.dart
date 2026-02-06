import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/maps_service.dart';
import '../services/scoring_service.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance();
});

final mapsServiceProvider = Provider<MapsService>((ref) {
  return MapsService.fromEnv();
});

final scoringServiceProvider = Provider<ScoringService>((ref) {
  return ScoringService.fromEnv();
});
