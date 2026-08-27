import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/customer_profile.dart';

final customerProfileProvider = FutureProvider<CustomerProfile?>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return null;
  final res = await SupabaseService.client.from('customer_profiles').select().eq('user_id', userId).maybeSingle();
  return res != null ? CustomerProfile.fromSupabase(res) : null;
});

/// Returns the signed-in user's `customer_profiles.id` — the value
/// `orders.customer_id` actually foreign-keys to (NOT auth.uid() directly;
/// customer_profiles.id is its own generated PK, distinct from user_id).
/// Creates the row on first use if none exists yet, since nothing in the
/// signup flow does this today — a real gap, not something to route
/// around by writing auth.uid() into orders.customer_id, which fails the
/// foreign key constraint outright.
Future<String?> ensureCustomerProfileId() async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return null;
  final client = SupabaseService.client;
  final existing = await client.from('customer_profiles').select('id').eq('user_id', userId).maybeSingle();
  if (existing != null) return existing['id'] as String;

  final user = client.auth.currentUser;
  final created = await client
      .from('customer_profiles')
      .insert({
        'user_id': userId,
        'phone_number': user?.phone,
        'email': user?.email,
        'status': 'active',
      })
      .select('id')
      .single();
  return created['id'] as String;
}
