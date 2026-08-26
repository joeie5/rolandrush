class CustomerProfile {
  final String id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String status;

  const CustomerProfile({
    required this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.status = 'active',
  });

  String get displayName => fullName ?? [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ').trim();
  bool get canOrder => status == 'active';

  factory CustomerProfile.fromSupabase(Map<String, dynamic> row) => CustomerProfile(
        id: row['id'] as String,
        fullName: row['full_name'] as String?,
        firstName: row['first_name'] as String?,
        lastName: row['last_name'] as String?,
        phone: (row['phone_number'] ?? row['phone']) as String?,
        email: row['email'] as String?,
        status: row['status'] as String? ?? 'active',
      );
}
