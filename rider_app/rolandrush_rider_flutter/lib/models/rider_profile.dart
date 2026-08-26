/// Maps to `public.rider_profiles`.
class RiderProfile {
  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? vehicleType;
  final String verificationStatus; // pending/verified/rejected
  final bool isOnline;
  final double? lastLat;
  final double? lastLng;
  final DateTime? createdAt;

  const RiderProfile({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.email,
    this.address,
    this.vehicleType,
    this.verificationStatus = 'pending',
    this.isOnline = false,
    this.lastLat,
    this.lastLng,
    this.createdAt,
  });

  String get fullName {
    final joined = [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');
    return joined.isEmpty ? 'Rider' : joined;
  }

  RiderProfile copyWith({bool? isOnline, String? verificationStatus, double? lastLat, double? lastLng}) {
    return RiderProfile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
      vehicleType: vehicleType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isOnline: isOnline ?? this.isOnline,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      createdAt: createdAt,
    );
  }

  factory RiderProfile.fromSupabase(Map<String, dynamic> row) {
    return RiderProfile(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      firstName: row['first_name'] as String?,
      lastName: row['last_name'] as String?,
      phoneNumber: (row['phone_number'] ?? row['phone']) as String?,
      email: row['email'] as String?,
      address: row['address'] as String?,
      vehicleType: row['vehicle_type'] as String?,
      verificationStatus: row['verification_status'] as String? ?? 'pending',
      isOnline: row['is_online'] as bool? ?? false,
      lastLat: (row['last_lat'] as num?)?.toDouble(),
      lastLng: (row['last_lng'] as num?)?.toDouble(),
      createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
    );
  }
}

/// Maps to `public.wallets`, keyed by user_id (rider's auth user id).
class Wallet {
  final String id;
  final String userId;
  final double balance;
  final double totalEarned;

  const Wallet({required this.id, required this.userId, required this.balance, required this.totalEarned});

  factory Wallet.fromSupabase(Map<String, dynamic> row) {
    return Wallet(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      balance: (row['balance'] as num?)?.toDouble() ?? 0,
      totalEarned: (row['total_earned'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Maps to `public.withdrawal_requests`.
class WithdrawalRequest {
  final String id;
  final double amount;
  final String status; // pending/processing/completed/failed
  final DateTime createdAt;
  final Map<String, dynamic>? bankDetails;

  const WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.bankDetails,
  });

  factory WithdrawalRequest.fromSupabase(Map<String, dynamic> row) {
    return WithdrawalRequest(
      id: row['id'] as String,
      amount: (row['amount'] as num).toDouble(),
      status: row['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(row['created_at'] as String),
      bankDetails: row['bank_details'] as Map<String, dynamic>?,
    );
  }
}

/// Maps to `public.transactions`, keyed by user_id (rider's auth user id).
class RiderTransaction {
  final String id;
  final String? orderId;
  final double amount;
  final String type;
  final DateTime createdAt;

  const RiderTransaction({
    required this.id,
    this.orderId,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory RiderTransaction.fromSupabase(Map<String, dynamic> row) {
    return RiderTransaction(
      id: row['id'] as String,
      orderId: row['order_id'] as String?,
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      type: row['type'] as String? ?? 'earning',
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
