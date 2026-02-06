import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gig.dart';
import '../services/supabase_service.dart';
import '../state/providers.dart';
import 'gig_detail_screen.dart';

class MyGigsScreen extends ConsumerWidget {
  const MyGigsScreen({super.key});

  static const routeName = '/my-gigs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseService = ref.watch(supabaseServiceProvider);
    final user = supabaseService.currentUser();

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Sign in required.')));
    }

    return DefaultTabController(
      length: GigStatus.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Gigs'),
          bottom: TabBar(
            isScrollable: true,
            tabs: GigStatus.values
                .map((status) => Tab(text: status.name.toUpperCase()))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: GigStatus.values.map((status) {
            return FutureBuilder<List<Gig>>(
              future: supabaseService.fetchGigsByStatus(user.id, status),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final gigs = snapshot.data ?? [];
                if (gigs.isEmpty) {
                  return const Center(child: Text('No gigs yet.'));
                }
                return ListView(
                  children: gigs
                      .map(
                        (gig) => ListTile(
                          title: Text(gig.title),
                          subtitle: Text(gig.address),
                          trailing: Text('\$${gig.pay.toStringAsFixed(2)}'),
                          onTap: () {
                            Navigator.pushNamed(context, GigDetailScreen.routeName, arguments: gig);
                          },
                        ),
                      )
                      .toList(),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
