import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/gig.dart';
import '../models/source.dart';
import '../models/user_profile.dart';

class SupabaseService {
  SupabaseService(this.client);

  final SupabaseClient client;

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw Exception('Supabase credentials are missing in .env');
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseService instance() {
    return SupabaseService(Supabase.instance.client);
  }

  Future<void> sendMagicLink(String email) async {
    // Magic link auth for passwordless sign-in.
    await client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  User? currentUser() => client.auth.currentUser;

  Future<List<Source>> fetchSources() async {
    final response = await client.from('sources').select();
    return response.map<Source>((row) => Source.fromJson(row)).toList();
  }

  Future<UserProfile?> fetchUserProfile(String userId) async {
    final response = await client.from('users').select().eq('id', userId).maybeSingle();
    if (response == null) {
      return null;
    }
    return UserProfile.fromJson(response);
  }

  Future<void> upsertUserProfile(UserProfile profile) async {
    await client.from('users').upsert(profile.toJson());
  }

  Future<List<Gig>> fetchGigsByStatus(String userId, GigStatus status) async {
    final response = await client
        .from('gigs')
        .select()
        .eq('user_id', userId)
        .eq('status', status.name)
        .order('deadline');
    return response.map<Gig>((row) => Gig.fromJson(row)).toList();
  }

  Future<List<Gig>> fetchApprovedGigs(String userId) async {
    final response = await client
        .from('gigs')
        .select()
        .eq('user_id', userId)
        .eq('status', GigStatus.approved.name)
        .order('deadline');
    return response.map<Gig>((row) => Gig.fromJson(row)).toList();
  }

  Future<Gig> addGig(Gig gig) async {
    final payload = Map<String, dynamic>.from(gig.toJson());
    if (gig.id.isEmpty) {
      payload.remove('id');
    }
    final response = await client.from('gigs').insert(payload).select().single();
    return Gig.fromJson(response);
  }

  Future<Gig> updateGigStatus({required String gigId, required GigStatus status}) async {
    final response = await client
        .from('gigs')
        .update({'status': status.name})
        .eq('id', gigId)
        .select()
        .single();
    return Gig.fromJson(response);
  }
}
