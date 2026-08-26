/// Maps to `menu_items` (vendor-side schema — this project's version adds
/// media_type, video_thumbnail_url, tags[] on top of what RolandRushApp's
/// customer-facing menu_items has). Structurally close enough that a
/// future consolidation onto one schema is realistic, but the column sets
/// aren't identical today.
class VendorMenuItem {
  final String id;
  final String vendorId;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? imageUrl;
  final String? videoUrl;
  final String mediaType; // 'image' | 'video' | 'none'
  final bool isAvailable;
  final int preparationTime;
  final List<String> tags;
  final List<String> dietaryInfo;

  const VendorMenuItem({
    required this.id,
    required this.vendorId,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.imageUrl,
    this.videoUrl,
    this.mediaType = 'image',
    this.isAvailable = true,
    this.preparationTime = 15,
    this.tags = const [],
    this.dietaryInfo = const [],
  });

  factory VendorMenuItem.fromSupabase(Map<String, dynamic> row) {
    return VendorMenuItem(
      id: row['id'] as String,
      vendorId: row['vendor_id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      price: (row['price'] as num).toDouble(),
      category: row['category'] as String?,
      imageUrl: row['image_url'] as String?,
      videoUrl: row['video_url'] as String?,
      mediaType: row['media_type'] as String? ?? 'image',
      isAvailable: row['is_available'] as bool? ?? true,
      preparationTime: row['preparation_time'] as int? ?? 15,
      tags: (row['tags'] as List?)?.cast<String>() ?? const [],
      dietaryInfo: (row['dietary_info'] as List?)?.cast<String>() ?? const [],
    );
  }

  /// Only real columns on the shared RolandRushApp menu_items table —
  /// media_type/tags don't exist there (they were this project's Partner
  /// project schema before both apps were confirmed to share one database).
  Map<String, dynamic> toInsertJson() => {
        'vendor_id': vendorId,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'video_url': videoUrl,
        'is_available': isAvailable,
        'preparation_time': preparationTime,
        'dietary_info': dietaryInfo,
      };
}
