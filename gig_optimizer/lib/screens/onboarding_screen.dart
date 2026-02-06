import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/source.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../state/providers.dart';
import 'today_dashboard_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _minRateController = TextEditingController(text: '25');
  final _maxDistanceController = TextEditingController(text: '25');
  final _startTimeController = TextEditingController(text: '08:00');
  final _endTimeController = TextEditingController(text: '20:00');
  final Set<String> _selectedSourceIds = {};

  bool _linkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _minRateController.dispose();
    _maxDistanceController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink(SupabaseService service) async {
    if (_emailController.text.trim().isEmpty) {
      return;
    }
    await service.sendMagicLink(_emailController.text.trim());
    setState(() {
      _linkSent = true;
    });
  }

  Future<void> _saveProfile(SupabaseService service) async {
    final user = service.currentUser();
    if (user == null) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final profile = UserProfile(
      id: user.id,
      email: _emailController.text.trim(),
      minHourlyRate: double.parse(_minRateController.text.trim()),
      maxDistanceMiles: double.parse(_maxDistanceController.text.trim()),
      availableStartTime: _startTimeController.text.trim(),
      availableEndTime: _endTimeController.text.trim(),
    );
    await service.upsertUserProfile(profile);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, TodayDashboardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = ref.watch(supabaseServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Get Started')),
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
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _sendMagicLink(supabaseService),
                    child: Text(_linkSent ? 'Magic Link Sent' : 'Send Magic Link'),
                  ),
                  const SizedBox(height: 20),
                  Text('Sources used', style: Theme.of(context).textTheme.titleMedium),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    )
                  else
                    ...sources.map((source) => CheckboxListTile(
                          value: _selectedSourceIds.contains(source.id),
                          title: Text(source.name),
                          subtitle: Text(source.category),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedSourceIds.add(source.id);
                              } else {
                                _selectedSourceIds.remove(source.id);
                              }
                            });
                          },
                        )),
                  const Divider(height: 32),
                  Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
                  TextFormField(
                    controller: _minRateController,
                    decoration: const InputDecoration(labelText: 'Minimum hourly rate'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _maxDistanceController,
                    decoration: const InputDecoration(labelText: 'Max distance (miles)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(labelText: 'Available start time (HH:MM)'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(labelText: 'Available end time (HH:MM)'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _saveProfile(supabaseService),
                    child: const Text('Continue to Dashboard'),
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
