import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the Supabase client for RolandRushApp
/// (project ref: wjtyasspkowlibvigtrt).
///
/// IMPORTANT: before shipping, RLS must be enabled + policies written for
/// the 16 tables currently exposed with RLS disabled (menu_items,
/// transactions, withdrawal_requests, chat_messages, notifications, etc.)
/// — see the security note flagged earlier. Anyone with the anon key can
/// currently read/write every row in those tables.
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static String? get currentUserId => client.auth.currentUser?.id;
  static bool get isSignedIn => client.auth.currentUser != null;

  static Future<void> init({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
