import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/add_on.dart';
import '../../../models/cart_item.dart';
import '../../../models/menu_item.dart';

/// Cart spans multiple vendors (multi-restaurant checkout, per
/// CART_MULTI_RESTAURANT_CHECKOUT.md in the Figma export) — grouping by
/// vendorId happens in the cart/checkout screen, not here.
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addOrUpdate(MenuItem item, {required int quantity, List<AddOn>? addOns}) {
    final existingIndex = state.indexWhere((c) => c.menuItemId == item.id);
    final newItem = CartItem.fromMenuItem(item, quantity: quantity, addOns: addOns);

    if (existingIndex >= 0) {
      final updated = [...state];
      updated[existingIndex] = newItem;
      state = updated;
    } else {
      state = [...state, newItem];
    }
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      remove(menuItemId);
      return;
    }
    state = [
      for (final c in state)
        if (c.menuItemId == menuItemId) (c..quantity = quantity) else c,
    ];
  }

  void remove(String menuItemId) {
    state = state.where((c) => c.menuItemId != menuItemId).toList();
  }

  CartItem? forMenuItem(String menuItemId) {
    try {
      return state.firstWhere((c) => c.menuItemId == menuItemId);
    } catch (_) {
      return null;
    }
  }

  void clear() => state = [];

  double get total => state.fold(0, (sum, c) => sum + c.lineTotal);

  /// Group by vendorId for multi-restaurant checkout — each group becomes
  /// its own `orders` row on submit.
  Map<String, List<CartItem>> get groupedByVendor {
    final map = <String, List<CartItem>>{};
    for (final item in state) {
      map.putIfAbsent(item.vendorId, () => []).add(item);
    }
    return map;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, c) => sum + c.quantity);
});
