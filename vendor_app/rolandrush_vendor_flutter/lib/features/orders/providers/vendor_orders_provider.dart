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

  /// Vendor only ever advances placed->preparing->ready (see
  /// VendorOrderStatus.next) — picked_up/delivering/delivered are written
  /// by the rider app once a rider is physically involved, per the
  /// cross-app status ownership table. Wallet crediting on delivery moved
  /// with it: see rider_app's active_delivery_provider.dart, which now
  /// does the commission math and pays the vendor out when the rider
  /// confirms delivery via OTP, not when the vendor marks anything here.
  Future<void> advanceStatus(VendorOrder order) async {
    final next = order.status.next;
    if (next == null) return;
    await SupabaseService.client.from('orders').update({'status': next.value}).eq('id', order.id);
    await load();
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
