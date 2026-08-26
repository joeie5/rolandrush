import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/delivery_order.dart';

enum OrderFilter { all, nearby, highPay }

class AvailableOrdersState {
  final List<DeliveryOrder> orders;
  final bool isLoading;
  final OrderFilter filter;
  final String? error;

  const AvailableOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.filter = OrderFilter.all,
    this.error,
  });

  AvailableOrdersState copyWith({
    List<DeliveryOrder>? orders,
    bool? isLoading,
    OrderFilter? filter,
    String? error,
  }) {
    return AvailableOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  /// "nearby"/"high-pay" sorting needs rider lat/lng + a distance calc
  /// (Supabase has PostGIS via rider_locations already, so this can move
  /// server-side with an RPC once that's written). For now, high-pay
  /// sorts client-side by deliveryFee descending.
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

/// Job board: orders with status 'pending' and no rider assigned yet.
/// Matches AvailableOrders.tsx, but reading real `orders` rows instead of
/// the 6 hardcoded mock jobs.
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
          .eq('status', 'pending')
          .filter('rider_id', 'is', null)
          .order('created_at', ascending: false);

      final orders = (res as List)
          .map((row) => DeliveryOrder.fromSupabase(row as Map<String, dynamic>))
          .toList();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(OrderFilter filter) => state = state.copyWith(filter: filter);

  /// Accepting an order assigns this rider and flips status — should
  /// really be a single RPC/transaction server-side to avoid two riders
  /// racing to accept the same order (first-write-wins isn't safe done
  /// as a plain update from the client). Flagging as a TODO rather than
  /// a real fix here.
  Future<bool> acceptOrder(String orderId, String riderId) async {
    try {
      await SupabaseService.client.from('orders').update({
        'rider_id': riderId,
        'status': 'accepted',
        'current_step': 1,
      }).eq('id', orderId).filter('rider_id', 'is', null); // only succeeds if still unassigned
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final availableOrdersProvider =
    StateNotifierProvider<AvailableOrdersNotifier, AvailableOrdersState>(
  (ref) => AvailableOrdersNotifier(),
);
