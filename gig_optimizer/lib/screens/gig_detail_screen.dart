import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/gig.dart';
import '../services/supabase_service.dart';
import '../state/providers.dart';

class GigDetailScreen extends ConsumerStatefulWidget {
  const GigDetailScreen({super.key});

  static const routeName = '/gig-detail';

  @override
  ConsumerState<GigDetailScreen> createState() => _GigDetailScreenState();
}

class _GigDetailScreenState extends ConsumerState<GigDetailScreen> {
  bool _arrived = false;
  bool _proofComplete = false;
  bool _submitted = false;

  Future<void> _openMaps(Gig gig) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${gig.latitude},${gig.longitude}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gig = ModalRoute.of(context)!.settings.arguments as Gig;
    final supabaseService = ref.watch(supabaseServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(gig.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pay: \$${gig.pay.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Address: ${gig.address}'),
            const SizedBox(height: 16),
            StreamBuilder<int>(
              stream: Stream.periodic(const Duration(seconds: 1), (_) {
                final remaining = gig.deadline.difference(DateTime.now()).inSeconds;
                return remaining < 0 ? 0 : remaining;
              }),
              builder: (context, snapshot) {
                final seconds = snapshot.data ?? 0;
                final duration = Duration(seconds: seconds);
                final hours = duration.inHours;
                final minutes = duration.inMinutes.remainder(60);
                final display = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
                return Text('Time left: $display', style: Theme.of(context).textTheme.titleLarge);
              },
            ),
            const SizedBox(height: 16),
            const Text('Checklist'),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _arrived,
              onChanged: (value) {
                setState(() {
                  _arrived = value ?? false;
                });
              },
              title: const Text('Arrive at location'),
            ),
            CheckboxListTile(
              value: _proofComplete,
              onChanged: (value) {
                setState(() {
                  _proofComplete = value ?? false;
                });
              },
              title: const Text('Complete required proof'),
            ),
            CheckboxListTile(
              value: _submitted,
              onChanged: (value) {
                setState(() {
                  _submitted = value ?? false;
                });
              },
              title: const Text('Submit confirmation'),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMaps(gig),
                    icon: const Icon(Icons.map),
                    label: const Text('Open in Maps'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await supabaseService.updateGigStatus(gigId: gig.id, status: GigStatus.completed);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Completed'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
