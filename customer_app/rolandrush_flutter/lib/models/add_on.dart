/// Add-on for a menu item. Your schema actually stores this two ways:
///  1. `menu_items.add_ons` (jsonb) — a denormalized snapshot
///  2. `public.menu_item_addons` — a proper relational table with its own
///     image_url, keyed by menu_item_id
/// Prefer (2) as the source of truth once vendors manage add-ons through
/// the admin dashboard; this model reads either shape.
class AddOn {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  int quantity; // client-side selection state, not persisted here

  AddOn({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 0,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    return AddOn(
      // The denormalized menu_items.add_ons jsonb snapshot doesn't carry an
      // id (only name/image/price) — fall back to the name since it's used
      // purely as a client-side selection key within one menu item.
      id: (json['id'] as String?) ?? name,
      name: name,
      price: (json['price'] as num).toDouble(),
      imageUrl: (json['image_url'] ?? json['image']) as String?,
    );
  }

  double get lineTotal => price * quantity;
}
