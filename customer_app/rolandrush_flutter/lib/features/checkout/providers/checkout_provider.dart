import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../core/providers/platform_settings_provider.dart';
import '../../../models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../../restaurants/providers/restaurants_provider.dart';
import '../../profile/providers/customer_profile_provider.dart';

class CheckoutLineTotals {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  const CheckoutLineTotals({required this.subtotal, required this.deliveryFee, required this.serviceFee, required this.total});
}

/// Places one `orders` row per vendor group in the cart (multi-restaurant
/// checkout — see CART_MULTI_RESTAURANT_CHECKOUT.md). Returns the created
/// order ids so the UI can navigate to tracking.
class CheckoutNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  CheckoutNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Thrown to the UI as a distinct message when the customer is blocked.
  static const blockedError = 'account_blocked';

  Future<List<String>> placeOrder({required String deliveryAddress, required String paymentMethod}) async {
    state = const AsyncValue.loading();
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      state = AsyncValue.error('Not signed in', StackTrace.current);
      return [];
    }

    final profile = await ref.read(customerProfileProvider.future);
    if (profile != null && !profile.canOrder) {
      state = AsyncValue.error(blockedError, StackTrace.current);
      return [];
    }

    final grouped = ref.read(cartProvider.notifier).groupedByVendor;
    final restaurants = await ref.read(restaurantsProvider.future);
    final settings = await ref.read(platformSettingsProvider.future);
    final serviceFeeRate = platformSettingDouble(settings, 'service_fee_rate', 0.10);
    final createdIds = <String>[];

    try {
      for (final entry in grouped.entries) {
        final vendorId = entry.key;
        final lines = entry.value;
        final restaurant = restaurants.where((r) => r.id == vendorId);
        final restaurantName = restaurant.isNotEmpty ? restaurant.first.name : lines.first.vendorName;
        final commissionRate = restaurant.isNotEmpty ? restaurant.first.commissionRate : 0.15;

        // No delivery_fee_rules rows exist yet (per the migration notes),
        // so this always falls back to vendor_profiles.delivery_fee today.
        // Once rules are seeded, look them up by service area here instead.
        final deliveryFee = restaurant.isNotEmpty ? restaurant.first.deliveryFee : 0.0;

        final subtotal = lines.fold<double>(0, (s, l) => s + l.lineTotal);
        final serviceFee = (subtotal * serviceFeeRate).roundToDouble();
        final totalAmount = subtotal + deliveryFee + serviceFee;

        final row = await SupabaseService.client
            .from('orders')
            .insert({
              'customer_id': userId,
              'vendor_id': vendorId,
              'restaurant_name': restaurantName,
              'items': lines.map((l) => _lineToJson(l)).toList(),
              'subtotal': subtotal,
              'total_amount': totalAmount,
              'delivery_fee': deliveryFee,
              'service_fee': serviceFee,
              // Commission is deducted from the vendor's payout, never
              // charged to the customer — commission_amount is computed at
              // order completion (see vendor app), not here. Only the rate
              // is snapshotted now, since vendor_profiles.commission_rate
              // can change later and this order should keep the rate that
              // applied when it was placed.
              'commission_rate_applied': commissionRate,
              'status': 'placed',
              'current_step': 1,
              'delivery_address': deliveryAddress,
              'payment_method': paymentMethod,
              'payment_status': 'pending',
            })
            .select('id')
            .single();
        createdIds.add(row['id'] as String);
      }

      ref.read(cartProvider.notifier).clear();
      state = const AsyncValue.data(null);
      return createdIds;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return [];
    }
  }

  Map<String, dynamic> _lineToJson(CartItem l) => {
        'menu_item_id': l.menuItemId,
        'name': l.name,
        'price': l.basePrice,
        'quantity': l.quantity,
        'add_ons': l.selectedAddOns.map((a) => {'name': a.name, 'price': a.price, 'quantity': a.quantity}).toList(),
      };
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, AsyncValue<void>>(
  (ref) => CheckoutNotifier(ref),
);
