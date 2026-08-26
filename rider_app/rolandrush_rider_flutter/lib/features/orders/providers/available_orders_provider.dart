import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/delivery_order.dart';

enum OrderFilter { all, nearby, highPay }

class AvailableOrdersState {
  final List<DeliveryOrder> orders;
  final bool isLoading;
  final OrderFilter filter;
  final String? error;

  const AvailableOrdersState({this.orders = const [], this.isLoading = false, this.filter = OrderFilter.all, this.error});

  AvailableOrdersState copyWith({List<DeliveryOrder>? orders, bool? isLoading, OrderFilter? filter, String? error}) {
    return AvailableOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  /// "Nearby" needs rider lat/lng vs order pickup-location distance — the
  /// schema's `rider_locations` table has a PostGIS `geography` column, so
  /// a real implementation should be a `nearby_orders(lat, lng, radius)`
  /// Postgres RPC rather than client-side math without coordinates on the
  /// order row itself. Left as a no-op filter (same list) until that RPC
  /// exists — flagged rather than faked.
  List<DeliveryOrder> get filtered {
    switch (filter) {
      case OrderFilter.highPay:
        return [...orders]..sort((a, b) => b.deliveryFee.compareTo(a.deliveryFee));
      case OrderFilter.nearby:
      case OrderFilter.all:
        return orders;
    }
  }
}

/// Job board: orders ready for pickup with no rider assigned yet. Ports
/// Jobs.tsx, backed by real `orders` rows instead of the mock job list.
///
/// Status value fix vs. the first cut of this provider: the vendor app
/// marks an order `ready` (not `pending`) once it's cooked and awaiting a
/// rider — `pending`/`preparing` orders haven't been accepted by the
/// vendor yet and shouldn't show up here.
class AvailableOrdersNotifier extends StateNotifier<AvailableOrdersState> {
  AvailableOrdersNotifier() : super(const AvailableOrdersState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await SupabaseService.client
          .from('orders')
          .select()
          .eq('status', 'ready')
          .filter('rider_id', 'is', null)
          .order('created_at', ascending: false);

      final orders = (res as List).map((row) => DeliveryOrder.fromSupabase(row as Map<String, dynamic>)).toList();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(OrderFilter filter) => state = state.copyWith(filter: filter);

  /// Assigns this rider and starts the current_step machine at 1 (en route
  /// to vendor). Guarded by `rider_id is null` so it only succeeds if no
  /// other rider grabbed it first — still a plain client update racing on
  /// two simultaneous taps though; a real fix is a `accept_order(order_id,
  /// rider_id)` Postgres function using `UPDATE ... WHERE rider_id IS NULL
  /// RETURNING *`, called via RPC. Flagged, not fixed, here.
  Future<bool> acceptOrder(String orderId, String riderId) async {
    try {
      final rows = await SupabaseService.client
          .from('orders')
          .update({'rider_id': riderId, 'current_step': 1})
          .eq('id', orderId)
          .filter('rider_id', 'is', null)
          .select();
      final accepted = (rows as List).isNotEmpty;
      if (accepted) await load();
      return accepted;
    } catch (_) {
      return false;
    }
  }
}

final availableOrdersProvider = StateNotifierProvider<AvailableOrdersNotifier, AvailableOrdersState>(
  (ref) => AvailableOrdersNotifier(),
);
