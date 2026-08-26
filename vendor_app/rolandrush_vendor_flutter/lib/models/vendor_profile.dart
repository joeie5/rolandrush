/// Maps to `vendor_profiles` in COMPLETE_DATABASE_SCHEMA.sql. Note the
/// subscription_tier check constraint allows BOTH casing conventions
/// ('STANDARD'/'standard', 'PREMIUM'/'gold'/'platinum') — leftover from
/// merging two naming schemes at different points in the project. Worth
/// picking one convention and migrating the other before this grows further.
class VendorProfile {
  final String id;
  final String userId;
  final String restaurantName;
  final String? ownerName;
  final String phoneNumber;
  final String? email;
  final String subscriptionTier;
  final bool isVerified;
  final String status;
  final String? state;
  final String? city;
  final String? address;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? avatarUrl;
  final String? coverUrl;
  final bool isOpen;
  final String? cuisineType;
  final double rating;
  final int reviewCount;
  final String? description;
  final Map<String, dynamic>? operatingHours;
  final String verificationStatus;
  final double commissionRate;

  bool get isLive => verificationStatus == 'verified';

  const VendorProfile({
    required this.id,
    required this.userId,
    required this.restaurantName,
    this.ownerName,
    required this.phoneNumber,
    this.email,
    this.subscriptionTier = 'STANDARD',
    this.isVerified = false,
    this.status = 'active',
    this.state,
    this.city,
    this.address,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.avatarUrl,
    this.coverUrl,
    this.isOpen = true,
    this.cuisineType,
    this.rating = 0,
    this.reviewCount = 0,
    this.description,
    this.operatingHours,
    this.verificationStatus = 'pending',
    this.commissionRate = 0.15,
  });

  VendorProfile copyWith({bool? isOpen}) => VendorProfile(
        id: id,
        userId: userId,
        restaurantName: restaurantName,
        ownerName: ownerName,
        phoneNumber: phoneNumber,
        email: email,
        subscriptionTier: subscriptionTier,
        isVerified: isVerified,
        status: status,
        state: state,
        city: city,
        address: address,
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        avatarUrl: avatarUrl,
        coverUrl: coverUrl,
        isOpen: isOpen ?? this.isOpen,
        cuisineType: cuisineType,
        rating: rating,
        reviewCount: reviewCount,
        description: description,
        operatingHours: operatingHours,
        verificationStatus: verificationStatus,
        commissionRate: commissionRate,
      );

  factory VendorProfile.fromSupabase(Map<String, dynamic> row) {
    final firstName = row['first_name'] as String?;
    final lastName = row['last_name'] as String?;
    final derivedOwnerName = [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');
    return VendorProfile(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      restaurantName: row['restaurant_name'] as String,
      ownerName: (row['owner_name'] as String?) ?? (derivedOwnerName.isNotEmpty ? derivedOwnerName : null),
      phoneNumber: row['phone_number'] as String,
      email: row['email'] as String?,
      subscriptionTier: row['subscription_tier'] as String? ?? 'STANDARD',
      isVerified: (row['is_verified'] as bool?) ?? (row['status'] == 'active'),
      status: row['status'] as String? ?? 'active',
      state: row['state'] as String?,
      city: row['city'] as String?,
      address: row['address'] as String?,
      bankName: row['bank_name'] as String?,
      accountNumber: row['account_number'] as String?,
      accountName: row['account_name'] as String?,
      avatarUrl: (row['avatar_url'] as String?) ?? (row['logo_url'] as String?),
      coverUrl: row['cover_url'] as String?,
      isOpen: row['is_open'] as bool? ?? true,
      cuisineType: row['cuisine_type'] as String?,
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (row['review_count'] as int?) ?? 0,
      description: row['description'] as String?,
      operatingHours: row['operating_hours'] as Map<String, dynamic>?,
      verificationStatus: row['verification_status'] as String? ?? 'pending',
      commissionRate: (row['commission_rate'] as num?)?.toDouble() ?? 0.15,
    );
  }
}
