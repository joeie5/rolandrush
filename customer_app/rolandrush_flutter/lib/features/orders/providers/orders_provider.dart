import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/order.dart';

final ordersProvider = FutureProvider<List<RushOrder>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  final res = await SupabaseService.client
      .from('orders')
      .select()
      .eq('customer_id', userId)
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
