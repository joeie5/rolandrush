import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/customer_profile.dart';

final customerProfileProvider = FutureProvider<CustomerProfile?>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return null;
  final res = await SupabaseService.client.from('customer_profiles').select().eq('user_id', userId).maybeSingle();
  return res != null ? CustomerProfile.fromSupabase(res) : null;
});
