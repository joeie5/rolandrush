import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_service.dart';
import '../../../models/vendor_order.dart';

class VendorOrdersState {
  final List<VendorOrder> orders;
  final bool isLoading;
  final String? error;

  const VendorOrdersState({this.orders = const [], this.isLoading = false, this.error});

  VendorOrdersState copyWith({List<VendorOrder>? orders, bool? isLoading, String? error}) {
    return VendorOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<VendorOrder> get active =>
      orders.where((o) => o.status != VendorOrderStatus.delivered && o.status != VendorOrderStatus.cancelled).toList();

  List<VendorOrder> get history =>
      orders.where((o) => o.status == VendorOrderStatus.delivered || o.status == VendorOrderStatus.cancelled).toList();
}

/// Mirrors getOrders() + subscribeToOrders() from the React app's
/// utils/supabase/database.ts — real table query plus a realtime channel
/// so new orders appear without a manual refresh (matches "Real-time
/// notification panel" behavior described for DashboardNotifications.tsx).
class VendorOrdersNotifier extends StateNotifier<VendorOrdersState> {
  final String vendorId;
  VendorOrdersNotifier(this.vendorId) : super(const VendorOrdersState()) {
    load();
    _subscribe();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await SupabaseService.client
          .from('orders')
          .select()
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);
      final orders = (res as List).map((r) => VendorOrder.fromSupabase(r as Map<String, dynamic>)).toList();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _subscribe() {
    SupabaseService.client
        .channel('vendor_orders_$vendorId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'vendor_id', value: vendorId),
          callback: (_) => load(),
        )
        .subscribe();
  }

  Future<void> advanceStatus(VendorOrder order) async {
    final next = order.status.next;
    if (next == null) return;

    final update = <String, dynamic>{'status': next.value};
    if (next == VendorOrderStatus.delivered) {
      update['delivered_at'] = DateTime.now().toIso8601String();
      // Commission is computed here, at completion, not at checkout —
      // the customer never sees or pays it; it's deducted from the
      // vendor's payout. commission_rate_applied was snapshotted onto the
      // order at checkout so a later change to vendor_profiles.commission_rate
      // doesn't retroactively change already-placed orders.
      final rate = order.commissionRateApplied ?? 0.15;
      final subtotal = order.effectiveSubtotal;
      final commissionAmount = subtotal * rate;
      update['commission_amount'] = commissionAmount;
      await SupabaseService.client.from('orders').update(update).eq('id', order.id);
      await _creditVendorWallet(order, commissionAmount);
    } else {
      await SupabaseService.client.from('orders').update(update).eq('id', order.id);
    }
    await load();
  }

  /// Credits (subtotal − commission), not total_amount — delivery fee goes
  /// to whoever fulfilled delivery and service fee to the platform, neither
  /// belongs in the vendor's payout. No DB trigger does this automatically
  /// today, so the app has to.
  Future<void> _creditVendorWallet(VendorOrder order, double commissionAmount) async {
    final client = SupabaseService.client;
    final vendorRow = await client.from('vendor_profiles').select('user_id').eq('id', vendorId).maybeSingle();
    final userId = vendorRow?['user_id'] as String?;
    if (userId == null) return;

    final netPayout = order.effectiveSubtotal - commissionAmount;
    if (netPayout <= 0) return;

    final wallet = await client.from('wallets').select('id, balance, total_earned').eq('user_id', userId).maybeSingle();
    if (wallet == null) {
      await client.from('wallets').insert({'user_id': userId, 'balance': netPayout, 'total_earned': netPayout});
    } else {
      final newBalance = ((wallet['balance'] as num?)?.toDouble() ?? 0) + netPayout;
      final newTotalEarned = ((wallet['total_earned'] as num?)?.toDouble() ?? 0) + netPayout;
      await client.from('wallets').update({'balance': newBalance, 'total_earned': newTotalEarned}).eq('id', wallet['id']);
    }

    await client.from('transactions').insert({
      'user_id': userId,
      'type': 'credit',
      'amount': netPayout,
      'description': 'Order payout (order #${order.id.substring(0, order.id.length.clamp(0, 8))}, commission ${(commissionAmount).toStringAsFixed(0)} deducted)',
      'status': 'completed',
    });
  }

  Future<void> cancelOrder(VendorOrder order) async {
    await SupabaseService.client.from('orders').update({'status': 'cancelled'}).eq('id', order.id);
    await load();
  }
}

final vendorOrdersProvider =
    StateNotifierProvider.family<VendorOrdersNotifier, VendorOrdersState, String>(
  (ref, vendorId) => VendorOrdersNotifier(vendorId),
);
