import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/delivery_order.dart';

class ActiveDeliveryState {
  final DeliveryOrder? order;
  final bool isLoading;
  final bool isUpdatingStep;
  final String? error;

  const ActiveDeliveryState({this.order, this.isLoading = false, this.isUpdatingStep = false, this.error});

  ActiveDeliveryState copyWith({DeliveryOrder? order, bool? isLoading, bool? isUpdatingStep, String? error, bool clearOrder = false}) {
    return ActiveDeliveryState(
      order: clearOrder ? null : (order ?? this.order),
      isLoading: isLoading ?? this.isLoading,
      isUpdatingStep: isUpdatingStep ?? this.isUpdatingStep,
      error: error,
    );
  }
}

/// Status string written alongside each current_step, matching the values
/// the customer app's orders_screen.dart already understands
/// (placed/preparing/picked_up/delivering/delivered/cancelled).
const _statusForStep = {
  1: 'ready', // en route to vendor — rider assigned, not yet physically there
  2: 'ready', // at vendor, about to pick up
  3: 'delivering',
  4: 'delivered',
};

/// Drives ActiveDelivery.tsx's 4-step flow (En Route → Pickup → Delivering
/// → Delivered), backed by real `orders.current_step`. Step 4 requires the
/// customer's delivery_otp instead of firing on tap alone — the schema
/// already has `orders.delivery_otp` for exactly this anti-fraud check.
class ActiveDeliveryNotifier extends StateNotifier<ActiveDeliveryState> {
  final String orderId;
  ActiveDeliveryNotifier(this.orderId) : super(const ActiveDeliveryState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final row = await SupabaseService.client.from('orders').select().eq('id', orderId).single();
      state = state.copyWith(order: DeliveryOrder.fromSupabase(row), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> advanceStep() async {
    final order = state.order;
    if (order == null || order.currentStep == DeliveryStep.delivered) return;

    final nextStep = DeliveryStep.fromInt(order.currentStep.value + 1);
    state = state.copyWith(isUpdatingStep: true);
    try {
      await SupabaseService.client.from('orders').update({
        'current_step': nextStep.value,
        'status': _statusForStep[nextStep.value],
        if (nextStep == DeliveryStep.delivered) 'delivered_at': DateTime.now().toIso8601String(),
      }).eq('id', order.id);

      if (nextStep == DeliveryStep.delivered) {
        await _creditRiderWallet(order);
      }

      await _load();
    } finally {
      state = state.copyWith(isUpdatingStep: false);
    }
  }

  /// Credits the rider's wallet with the order's delivery_fee on
  /// completion — same client-side wallet-credit pattern the vendor app
  /// uses in vendor_orders_provider.dart's _creditVendorWallet (no DB
  /// trigger does this automatically today, so the app has to). Rider
  /// earns the delivery_fee, not the order total/subtotal — those go to
  /// the vendor and platform respectively.
  Future<void> _creditRiderWallet(DeliveryOrder order) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    final amount = order.deliveryFee;
    if (amount <= 0) return;

    final client = SupabaseService.client;
    final wallet = await client.from('wallets').select('id, balance, total_earned').eq('user_id', userId).maybeSingle();
    if (wallet == null) {
      await client.from('wallets').insert({'user_id': userId, 'balance': amount, 'total_earned': amount});
    } else {
      final newBalance = ((wallet['balance'] as num?)?.toDouble() ?? 0) + amount;
      final newTotalEarned = ((wallet['total_earned'] as num?)?.toDouble() ?? 0) + amount;
      await client.from('wallets').update({'balance': newBalance, 'total_earned': newTotalEarned}).eq('id', wallet['id']);
    }
    await client.from('transactions').insert({
      'user_id': userId,
      'order_id': order.id,
      'amount': amount,
      'type': 'delivery_earning',
    });
  }

  /// Called on the final step instead of advanceStep() directly — verifies
  /// the code the customer reads out before marking delivered.
  Future<bool> confirmDeliveryWithOtp(String enteredOtp) async {
    final order = state.order;
    if (order == null) return false;
    if (order.deliveryOtp == null || order.deliveryOtp != enteredOtp) return false;
    await advanceStep();
    return true;
  }
}

final activeDeliveryProvider = StateNotifierProvider.family<ActiveDeliveryNotifier, ActiveDeliveryState, String>(
  (ref, orderId) => ActiveDeliveryNotifier(orderId),
);

/// The rider's current in-progress order (if any) — orders assigned to
/// this rider that aren't delivered/cancelled yet. Drives the "Delivery in
/// progress" banner on Home and decides whether ActiveDelivery has
/// anything to show. `orders.rider_id` references `rider_profiles.id`
/// (same pattern as `orders.vendor_id` -> `vendor_profiles.id` in the
/// vendor app), so this looks up the profile row first.
final riderActiveOrderProvider = FutureProvider<DeliveryOrder?>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return null;
  final profileRow =
      await SupabaseService.client.from('rider_profiles').select('id').eq('user_id', userId).maybeSingle();
  if (profileRow == null) return null;
  final rows = await SupabaseService.client
      .from('orders')
      .select()
      .eq('rider_id', profileRow['id'])
      .not('status', 'in', '(delivered,cancelled)')
      .order('created_at', ascending: false)
      .limit(1);
  final list = rows as List;
  if (list.isEmpty) return null;
  return DeliveryOrder.fromSupabase(list.first as Map<String, dynamic>);
});
