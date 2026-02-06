import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/gig.dart';
import '../services/maps_service.dart';
import '../services/supabase_service.dart';
import '../state/providers.dart';

class RouteOptimizationScreen extends ConsumerStatefulWidget {
  const RouteOptimizationScreen({super.key});

  static const routeName = '/route-optimization';

  @override
  ConsumerState<RouteOptimizationScreen> createState() => _RouteOptimizationScreenState();
}

class _RouteOptimizationScreenState extends ConsumerState<RouteOptimizationScreen> {
  final Set<String> _selectedGigIds = {};
  List<Gig> _gigs = [];
  List<Gig> _orderedStops = [];
  int? _totalDriveMinutes;
  bool _loading = false;

  Future<void> _loadGigs(SupabaseService service) async {
    final user = service.currentUser();
    if (user == null) return;
    final gigs = await service.fetchApprovedGigs(user.id);
    setState(() {
      _gigs = gigs;
    });
  }

  Future<void> _optimizeRoute({
    required MapsService mapsService,
  }) async {
    if (_selectedGigIds.length < 2) {
      return;
    }
    setState(() {
      _loading = true;
    });
    final position = await Geolocator.getCurrentPosition();
    final origin = '${position.latitude},${position.longitude}';
    final selectedGigs = _gigs.where((gig) => _selectedGigIds.contains(gig.id)).toList();
    final waypoints = selectedGigs.map((gig) => '${gig.latitude},${gig.longitude}').toList();
    final result = await mapsService.optimizeRoute(
      origin: origin,
      destination: origin,
      waypoints: waypoints,
    );
    final ordered = <Gig>[];
    for (final index in result.waypointOrder) {
      ordered.add(selectedGigs[index]);
    }
    setState(() {
      _orderedStops = ordered;
      _totalDriveMinutes = result.totalDriveMinutes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = ref.watch(supabaseServiceProvider);
    final mapsService = ref.watch(mapsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Route Optimization')),
      body: FutureBuilder<void>(
        future: _loadGigs(supabaseService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: _gigs
                        .map((gig) => CheckboxListTile(
                              value: _selectedGigIds.contains(gig.id),
                              title: Text(gig.title),
                              subtitle: Text('${gig.address} • \$${gig.pay.toStringAsFixed(2)}'),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedGigIds.add(gig.id);
                                  } else {
                                    _selectedGigIds.remove(gig.id);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
                if (_orderedStops.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Optimized Stops', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ..._orderedStops.asMap().entries.map(
                                (entry) => Text('${entry.key + 1}. ${entry.value.title}'),
                              ),
                          if (_totalDriveMinutes != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('Total drive: $_totalDriveMinutes mins'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _loading ? null : () => _optimizeRoute(mapsService: mapsService),
                  child: Text(_loading ? 'Optimizing...' : 'Optimize Route'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
