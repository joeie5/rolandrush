/// Maps to `public.orders`. current_step: 1 en route to vendor, 2 pickup,
/// 3 delivering, 4 delivered — set by the rider app.
class RushOrder {
  final String id;
  final String orderNumber;
  final String vendorId;
  final String? restaurantName;
  final String status;
  final int currentStep;
  final double totalAmount;
  final double deliveryFee;
  final String? deliveryAddress;
  final String? deliveryOtp;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  const RushOrder({
    required this.id,
    required this.orderNumber,
    required this.vendorId,
    this.restaurantName,
    required this.status,
    this.currentStep = 1,
    required this.totalAmount,
    this.deliveryFee = 0,
    this.deliveryAddress,
    this.deliveryOtp,
    required this.createdAt,
    this.deliveredAt,
  });

  bool get isActive => status != 'delivered' && status != 'cancelled';

  factory RushOrder.fromSupabase(Map<String, dynamic> row) {
    return RushOrder(
      id: row['id'] as String,
      orderNumber: row['order_number'] as String? ?? '',
      vendorId: row['vendor_id'] as String,
      restaurantName: row['restaurant_name'] as String?,
      status: row['status'] as String? ?? 'placed',
      currentStep: (row['current_step'] as int?) ?? 1,
      totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (row['delivery_fee'] as num?)?.toDouble() ?? 0,
      deliveryAddress: row['delivery_address'] as String?,
      deliveryOtp: row['delivery_otp'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      deliveredAt: row['delivered_at'] != null ? DateTime.parse(row['delivered_at'] as String) : null,
    );
  }
}
