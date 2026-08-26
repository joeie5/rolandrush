import 'package:supabase_flutter/supabase_flutter.dart';

/// Same RolandRushApp project as the customer app (ref wjtyasspkowlibvigtrt) —
/// riders and customers share one Supabase backend, just different auth
/// roles and RLS policies once those are written.
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
