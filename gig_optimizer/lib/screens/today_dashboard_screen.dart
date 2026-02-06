import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/gig.dart';
import '../services/maps_service.dart';
import '../services/scoring_service.dart';
import '../services/supabase_service.dart';
import '../state/providers.dart';
import '../widgets/gig_list_tile.dart';
import 'add_gig_screen.dart';
import 'gig_detail_screen.dart';
import 'my_gigs_screen.dart';
import 'route_optimization_screen.dart';

class TodayDashboardScreen extends ConsumerWidget {
  const TodayDashboardScreen({super.key});

  static const routeName = '/dashboard';

  Future<List<GigPriority>> _loadPriorities({
    required SupabaseService supabaseService,
    required MapsService mapsService,
    required ScoringService scoringService,
  }) async {
    final user = supabaseService.currentUser();
    if (user == null) {
      return [];
    }
    final position = await _determinePosition();
    final origin = '${position.latitude},${position.longitude}';
    final gigs = await supabaseService.fetchApprovedGigs(user.id);
    final List<GigPriority> priorities = [];
    for (final gig in gigs) {
      final distanceResult = await mapsService.distanceMatrix(
        origin: origin,
        destination: '${gig.latitude},${gig.longitude}',
      );
      final hourlyRate = scoringService.effectiveHourlyRate(
        pay: gig.pay,
        distanceMiles: distanceResult.distanceMiles,
        estimatedDurationMinutes: gig.estimatedDurationMinutes,
        driveMinutes: distanceResult.durationMinutes,
      );
      priorities.add(
        GigPriority(
          gig: gig,
          hourlyRate: hourlyRate,
          distanceMiles: distanceResult.distanceMiles,
          driveMinutes: distanceResult.durationMinutes,
        ),
      );
    }
    priorities.sort((a, b) => scoringService.comparePriority(
          hourlyRateA: a.hourlyRate,
          hourlyRateB: b.hourlyRate,
          deadlineA: a.gig.deadline,
          deadlineB: b.gig.deadline,
          distanceA: a.distanceMiles,
          distanceB: b.distanceMiles,
        ));
    return priorities;
  }

  Future<Position> _determinePosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseService = ref.watch(supabaseServiceProvider);
    final mapsService = ref.watch(mapsServiceProvider);
    final scoringService = ref.watch(scoringServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.route),
            onPressed: () => Navigator.pushNamed(context, RouteOptimizationScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.pushNamed(context, MyGigsScreen.routeName),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddGigScreen.routeName),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<GigPriority>>(
        future: _loadPriorities(
          supabaseService: supabaseService,
          mapsService: mapsService,
          scoringService: scoringService,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final priorities = snapshot.data ?? [];
          if (priorities.isEmpty) {
            return const Center(child: Text('No approved gigs yet.'));
          }
          return ListView.builder(
            itemCount: priorities.length,
            itemBuilder: (context, index) {
              final item = priorities[index];
              return GigListTile(
                title: item.gig.title,
                pay: item.gig.pay,
                hourlyRate: item.hourlyRate,
                distanceMiles: item.distanceMiles,
                deadline: item.gig.deadline,
                onTap: () {
                  Navigator.pushNamed(context, GigDetailScreen.routeName, arguments: item.gig);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class GigPriority {
  const GigPriority({
    required this.gig,
    required this.hourlyRate,
    required this.distanceMiles,
    required this.driveMinutes,
  });

  final Gig gig;
  final double hourlyRate;
  final double distanceMiles;
  final int driveMinutes;
}
