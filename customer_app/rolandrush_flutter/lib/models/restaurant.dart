/// Maps to `public.vendor_profiles`. Field names differ slightly from the
/// Magic Patterns mock `Restaurant` type (see REBUILD_NOTES) — this is the
/// real-schema equivalent used across Home/Discover/RestaurantDetail.
class Restaurant {
  final String id;
  final String name;
  final String? cuisineType;
  final String? description;
  final double rating;
  final int reviewCount;
  final String? deliveryTime;
  final double deliveryFee;
  final String? address;
  final String? city;
  final String? state;
  final bool isOpen;
  final bool isSponsored;
  final String? logoUrl;
  final String? coverUrl;
  final double? latitude;
  final double? longitude;
  final double commissionRate;
  final String verificationStatus;

  bool get isVerified => verificationStatus == 'verified';

  const Restaurant({
    required this.id,
    required this.name,
    this.cuisineType,
    this.description,
    this.rating = 0,
    this.reviewCount = 0,
    this.deliveryTime,
    this.deliveryFee = 0,
    this.address,
    this.city,
    this.state,
    this.isOpen = true,
    this.isSponsored = false,
    this.logoUrl,
    this.coverUrl,
    this.latitude,
    this.longitude,
    this.commissionRate = 0.15,
    this.verificationStatus = 'pending',
  });

  factory Restaurant.fromSupabase(Map<String, dynamic> row) {
    return Restaurant(
      id: row['id'] as String,
      name: row['restaurant_name'] as String? ?? 'Restaurant',
      cuisineType: row['cuisine_type'] as String?,
      description: row['description'] as String?,
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (row['review_count'] as int?) ?? 0,
      deliveryTime: row['delivery_time'] as String?,
      deliveryFee: (row['delivery_fee'] as num?)?.toDouble() ?? 0,
      address: row['address'] as String?,
      city: row['city'] as String?,
      state: row['state'] as String?,
      isOpen: row['is_open'] as bool? ?? true,
      isSponsored: row['is_sponsored'] as bool? ?? false,
      logoUrl: row['logo_url'] as String?,
      coverUrl: row['cover_url'] as String?,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      commissionRate: (row['commission_rate'] as num?)?.toDouble() ?? 0.15,
      verificationStatus: row['verification_status'] as String? ?? 'pending',
    );
  }

  /// Deterministic accent color per vendor, mirrors the mock data's
  /// per-restaurant `accent` used behind the initials avatar.
  int get accentSeed => id.hashCode;
}
