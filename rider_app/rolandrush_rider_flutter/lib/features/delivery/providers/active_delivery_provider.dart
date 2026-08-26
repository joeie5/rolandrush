import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/delivery_order.dart';

class ActiveDeliveryState {
  final DeliveryOrder? order;
  final bool isLoading;
  final bool isUpdatingStep;
  final String? error;

  const ActiveDeliveryState({this.order, this.isLoading = false, this.isUpdatingStep = false, this.error});

  ActiveDeliveryState copyWith({
    DeliveryOrder? order,
    bool? isLoading,
    bool? isUpdatingStep,
    String? error,
  }) {
    return ActiveDeliveryState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingStep: isUpdatingStep ?? this.isUpdatingStep,
      error: error,
    );
  }
}

/// Drives ActiveDelivery.tsx's 4-step flow, backed by real `orders` rows
/// instead of the hardcoded mock order. One addition vs. the Figma design:
/// step 4 ("Complete Delivery") now requires the customer's delivery_otp
/// rather than firing on tap alone — orders.delivery_otp already exists in
/// the schema but the mock UI never reads it. Worth confirming with the
/// team this is the intended anti-fraud flow before shipping; easy to
/// revert to a plain button if not.
class ActiveDeliveryNotifier extends StateNotifier<ActiveDeliveryState> {
  ActiveDeliveryNotifier(String orderId) : super(const ActiveDeliveryState()) {
    _load(orderId);
  }

  Future<void> _load(String orderId) async {
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
        if (nextStep == DeliveryStep.delivered) 'status': 'delivered',
        if (nextStep == DeliveryStep.delivered) 'delivered_at': DateTime.now().toIso8601String(),
      }).eq('id', order.id);

      await SupabaseService.client.from('order_tracking').insert({
        'order_id': order.id,
        'status': nextStep.name,
      });

      await _load(order.id);
    } finally {
      state = state.copyWith(isUpdatingStep: false);
    }
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

final activeDeliveryProvider =
    StateNotifierProvider.family<ActiveDeliveryNotifier, ActiveDeliveryState, String>(
  (ref, orderId) => ActiveDeliveryNotifier(orderId),
);
