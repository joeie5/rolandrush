import 'add_on.dart';
import 'menu_item.dart';

/// Client-side cart line. On checkout this gets serialized into the
/// `orders.items` jsonb column (see CheckoutScreen.tsx equivalent) —
/// one cart can span multiple vendors, matching CART_MULTI_RESTAURANT_CHECKOUT.md,
/// so checkout groups CartItems by vendorId and creates one `orders` row per vendor.
class CartItem {
  final String menuItemId;
  final String name;
  final double basePrice;
  final String? imageUrl;
  final String vendorId;
  final String vendorName;
  int quantity;
  List<AddOn> selectedAddOns;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.basePrice,
    this.imageUrl,
    required this.vendorId,
    required this.vendorName,
    this.quantity = 1,
    List<AddOn>? selectedAddOns,
  }) : selectedAddOns = selectedAddOns ?? [];

  factory CartItem.fromMenuItem(MenuItem item, {int quantity = 1, List<AddOn>? addOns}) {
    return CartItem(
      menuItemId: item.id,
      name: item.name,
      basePrice: item.price,
      imageUrl: item.imageUrl,
      vendorId: item.vendorId,
      vendorName: item.vendorName,
      quantity: quantity,
      selectedAddOns: addOns,
    );
  }

  double get addOnsTotal =>
      selectedAddOns.fold(0, (sum, a) => sum + a.lineTotal);

  double get unitPrice => basePrice + addOnsTotal;

  // addOnsTotal is already the total for this cart line's add-ons (each
  // AddOn.lineTotal is price × that add-on's own selected quantity) — it
  // must not be multiplied by the item's quantity again, or e.g. 1 egg
  // sauce on a 4x item overcharges as if 4 egg sauces were added.
  double get lineTotal => basePrice * quantity + addOnsTotal;
}
