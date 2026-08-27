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

/// Status string written alongside each current_step, matching the one
/// canonical vocabulary all three apps write/read
/// (placed/preparing/ready/picked_up/delivering/delivered/cancelled).
/// No entry for step 1 (en route to vendor) — during that leg the order's
/// status stays whatever the vendor last set it to (`ready`); only
/// `orders.rider_id` being non-null signals a rider is assigned and
/// coming. Writing anything here for step 1 was the actual bug: it
/// overwrote the vendor's `ready` with a value ('ready' again, coincidentally
/// harmless here, but conceptually wrong) before the rider had physically
/// done anything yet. No entry for step 4 either — that transition (plus
/// status/commission_amount/delivered_at and both wallet credits) is
/// handled entirely by the complete_delivery_and_credit() RPC, not by a
/// plain client update; see confirmDeliveryWithOtp below.
const _statusForStep = {
  2: 'picked_up', // rider has physically picked up at the vendor
  3: 'delivering',
};

/// Drives ActiveDelivery.tsx's 4-step flow (En Route → Pickup → Delivering
/// → Delivered), backed by real `orders.current_step`. Steps 2-3 are plain
/// client updates; the final step (delivery + vendor/rider payout) goes
/// through the complete_delivery_and_credit() RPC instead — see
/// confirmDeliveryWithOtp. That RPC is a SECURITY DEFINER function that
/// re-checks the delivery_otp match itself (not just trusting this
/// client already checked it) since it's the one place actually crediting
/// money to another user's wallet; a client-side-only OTP check would be
/// bypassable by anyone calling the RPC directly.
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

  /// Advances steps 2 (picked up) and 3 (delivering) only — step 4 must
  /// go through confirmDeliveryWithOtp instead, which is why this refuses
  /// to advance past step 3.
  Future<void> advanceStep() async {
    final order = state.order;
    if (order == null || order.currentStep.value >= 3) return;

    final nextStep = DeliveryStep.fromInt(order.currentStep.value + 1);
    state = state.copyWith(isUpdatingStep: true);
    try {
      await SupabaseService.client.from('orders').update({
        'current_step': nextStep.value,
        if (_statusForStep[nextStep.value] != null) 'status': _statusForStep[nextStep.value],
      }).eq('id', order.id);
      await _load();
    } finally {
      state = state.copyWith(isUpdatingStep: false);
    }
  }

  /// Final step: verifies the code the customer reads out, then calls the
  /// complete_delivery_and_credit() RPC to atomically mark the order
  /// delivered and pay out both the vendor and this rider. No direct
  /// transactions/wallets writes here anymore — RLS blocks a rider from
  /// writing to the vendor's wallet directly, by design (see the FIX 2
  /// migrations); this cross-user payout only happens inside that
  /// SECURITY DEFINER function now.
  Future<bool> confirmDeliveryWithOtp(String enteredOtp) async {
    final order = state.order;
    if (order == null) return false;
    state = state.copyWith(isUpdatingStep: true);
    try {
      await SupabaseService.client.rpc('complete_delivery_and_credit', params: {
        'p_order_id': order.id,
        'p_otp': enteredOtp,
      });
      await _load();
      return true;
    } catch (_) {
      // Covers both "wrong code" and "already delivered"/other RPC
      // exceptions — the RPC's own exception text isn't surfaced to the
      // UI today, just success/failure, matching the previous behavior.
      return false;
    } finally {
      state = state.copyWith(isUpdatingStep: false);
    }
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
