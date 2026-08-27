import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/order.dart';
import '../../profile/providers/customer_profile_provider.dart';

final ordersProvider = FutureProvider<List<RushOrder>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  // orders.customer_id is customer_profiles.id, not auth.uid() — see
  // checkout_provider.dart's placeOrder for why this indirection exists.
  final customerProfileId = await ensureCustomerProfileId();
  if (customerProfileId == null) return [];
  final res = await SupabaseService.client
      .from('orders')
      .select()
      .eq('customer_id', customerProfileId)
      .order('created_at', ascending: false);
  return (res as List).map((r) => RushOrder.fromSupabase(r as Map<String, dynamic>)).toList();
});

final activeOrderProvider = FutureProvider<RushOrder?>((ref) async {
  final orders = await ref.watch(ordersProvider.future);
  try {
    return orders.firstWhere((o) => o.isActive);
  } catch (_) {
    return null;
  }
});

final orderByIdProvider = FutureProvider.family<RushOrder?, String>((ref, id) async {
  final res = await SupabaseService.client.from('orders').select().eq('id', id).maybeSingle();
  return res != null ? RushOrder.fromSupabase(res) : null;
});
