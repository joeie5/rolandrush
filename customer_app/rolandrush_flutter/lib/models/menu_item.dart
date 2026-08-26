import 'add_on.dart';

/// Maps 1:1 to `public.menu_items` in Supabase, with the parent vendor
/// joined in for feed rendering (vendor name/avatar/rating shown per card,
/// same as the Figma "restaurant" block on each feed post).
class MenuItem {
  final String id;
  final String vendorId;
  final String name;
  final double price;
  final String? category;
  final String? imageUrl;
  final String? videoUrl;
  final bool isAvailable;
  final String? description;
  final int? preparationTime; // minutes
  final String? portionSize;
  final int? spicyLevel;
  final List<String> dietaryInfo;
  final List<String> allergens;
  final List<AddOn> addOns;

  // Joined vendor context (not on menu_items itself, but needed for the
  // feed card — pull via a join or a second query against vendor_profiles).
  final String vendorName;
  final String? vendorLogoUrl;
  final double vendorRating;
  final bool vendorIsSponsored;

  // Engagement counts — not in the current schema. See note in
  // FEED_ARCHITECTURE.md: likes/comments/shares need a menu_item_engagement
  // table (or columns) before these can be real. Defaulted to 0 for now.
  final int likeCount;
  final int commentCount;
  final int shareCount;

  const MenuItem({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    this.category,
    this.imageUrl,
    this.videoUrl,
    this.isAvailable = true,
    this.description,
    this.preparationTime,
    this.portionSize,
    this.spicyLevel,
    this.dietaryInfo = const [],
    this.allergens = const [],
    this.addOns = const [],
    required this.vendorName,
    this.vendorLogoUrl,
    this.vendorRating = 0,
    this.vendorIsSponsored = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
  });

  /// [row] is a menu_items row with an embedded `vendor_profiles` object,
  /// e.g. via a Supabase query like:
  ///   .select('*, vendor_profiles(restaurant_name, logo_url, rating, is_sponsored)')
  factory MenuItem.fromSupabase(Map<String, dynamic> row) {
    final vendor = row['vendor_profiles'] as Map<String, dynamic>? ?? {};
    return MenuItem(
      id: row['id'] as String,
      vendorId: row['vendor_id'] as String,
      name: row['name'] as String,
      price: (row['price'] as num).toDouble(),
      category: row['category'] as String?,
      imageUrl: row['image_url'] as String?,
      videoUrl: row['video_url'] as String?,
      isAvailable: row['is_available'] as bool? ?? true,
      description: row['description'] as String?,
      preparationTime: row['preparation_time'] as int?,
      portionSize: row['portion_size'] as String?,
      spicyLevel: row['spicy_level'] as int?,
      dietaryInfo: (row['dietary_info'] as List?)?.cast<String>() ?? const [],
      allergens: (row['allergens'] as List?)?.cast<String>() ?? const [],
      addOns: (row['add_ons'] as List?)
              ?.map((a) => AddOn.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
      vendorName: vendor['restaurant_name'] as String? ?? 'Restaurant',
      vendorLogoUrl: vendor['logo_url'] as String?,
      vendorRating: (vendor['rating'] as num?)?.toDouble() ?? 0,
      vendorIsSponsored: vendor['is_sponsored'] as bool? ?? false,
    );
  }

  /// Feed only makes sense with a video. Cards without one fall back to
  /// imageUrl as a static poster (handled in the feed widget).
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
}
