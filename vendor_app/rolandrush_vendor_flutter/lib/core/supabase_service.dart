import 'package:supabase_flutter/supabase_flutter.dart';

/// Shares the same Supabase project as the customer/rider apps
/// (RolandRushApp, ref wjtyasspkowlibvigtrt) — confirmed all three apps
/// point at one database, so this no longer targets the separate Partner
/// project ref (epvbhtfycoqqwzstrlno) the original brief assumed.
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static String? get currentUserId => client.auth.currentUser?.id;
  static bool get isSignedIn => client.auth.currentUser != null;
}
