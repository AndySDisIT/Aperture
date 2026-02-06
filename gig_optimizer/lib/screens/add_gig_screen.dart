import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gig.dart';
import '../models/source.dart';
import '../services/maps_service.dart';
import '../services/supabase_service.dart';
import '../state/providers.dart';

class AddGigScreen extends ConsumerStatefulWidget {
  const AddGigScreen({super.key});

  static const routeName = '/add-gig';

  @override
  ConsumerState<AddGigScreen> createState() => _AddGigScreenState();
}

class _AddGigScreenState extends ConsumerState<AddGigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _payController = TextEditingController();
  final _addressController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _durationController = TextEditingController();

  bool _saving = false;
  String? _selectedSourceId;

  @override
  void dispose() {
    _titleController.dispose();
    _payController.dispose();
    _addressController.dispose();
    _deadlineController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveGig({
    required SupabaseService supabaseService,
    required MapsService mapsService,
  }) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedSourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a source.')),
      );
      return;
    }
    final user = supabaseService.currentUser();
    if (user == null) {
      return;
    }
    setState(() {
      _saving = true;
    });
    final geocode = await mapsService.geocodeAddress(_addressController.text.trim());
    final location = geocode['results'][0]['geometry']['location'];
    final gig = Gig(
      id: '',
      userId: user.id,
      sourceId: _selectedSourceId!,
      title: _titleController.text.trim(),
      pay: double.parse(_payController.text.trim()),
      address: _addressController.text.trim(),
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      deadline: DateTime.parse(_deadlineController.text.trim()),
      estimatedDurationMinutes: int.parse(_durationController.text.trim()),
      status: GigStatus.approved,
    );
    await supabaseService.addGig(gig);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = ref.watch(supabaseServiceProvider);
    final mapsService = ref.watch(mapsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Gig')),
      body: FutureBuilder<List<Source>>(
        future: supabaseService.fetchSources(),
        builder: (context, snapshot) {
          final sources = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedSourceId,
                    decoration: const InputDecoration(labelText: 'Source'),
                    items: sources
                        .map(
                          (source) => DropdownMenuItem(
                            value: source.id,
                            child: Text(source.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSourceId = value;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _payController,
                    decoration: const InputDecoration(labelText: 'Pay'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _deadlineController,
                    decoration: const InputDecoration(labelText: 'Deadline (YYYY-MM-DD HH:MM)'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Estimated duration (minutes)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () => _saveGig(supabaseService: supabaseService, mapsService: mapsService),
                    child: Text(_saving ? 'Saving...' : 'Save Gig'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
