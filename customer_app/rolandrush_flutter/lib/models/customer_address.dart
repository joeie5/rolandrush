class CustomerAddress {
  final String id;
  final String addressLine;
  final String? label;
  final bool isDefault;
  final String? iconType;

  const CustomerAddress({
    required this.id,
    required this.addressLine,
    this.label,
    this.isDefault = false,
    this.iconType,
  });

  factory CustomerAddress.fromSupabase(Map<String, dynamic> row) => CustomerAddress(
        id: row['id'] as String,
        addressLine: row['address_line'] as String? ?? '',
        label: row['label'] as String?,
        isDefault: row['is_default'] as bool? ?? false,
        iconType: row['icon_type'] as String?,
      );
}
