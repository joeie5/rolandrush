/// Maps to `public.orders`, viewed from the rider's side. The 4-step
/// state machine in ActiveDelivery.tsx (En Route → Pickup → Delivering →
/// Delivered) is exactly `orders.current_step` (int4, already 1-4 in your
/// schema) — no translation needed there, which is a nice sign the
/// original schema was designed with this screen in mind.
enum DeliveryStep {
  enRoute(1, 'En Route', 'Going to restaurant'),
  pickup(2, 'Pickup', 'At restaurant'),
  delivering(3, 'Delivering', 'On the way'),
  delivered(4, 'Delivered', 'Complete');

  final int value;
  final String label;
  final String sublabel;
  const DeliveryStep(this.value, this.label, this.sublabel);

  static DeliveryStep fromInt(int v) =>
      DeliveryStep.values.firstWhere((s) => s.value == v, orElse: () => DeliveryStep.enRoute);
}

class OrderItemLine {
  final String name;
  final int quantity;
  final double price;
  const OrderItemLine({required this.name, required this.quantity, required this.price});

  factory OrderItemLine.fromJson(Map<String, dynamic> json) => OrderItemLine(
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );
}

class DeliveryOrder {
  final String id;
  final String orderNumber;
  final String? vendorId;
  final String restaurantName;
  final String? pickupAddress;
  final String? customerId;
  final String customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final List<OrderItemLine> items;
  final double totalAmount;
  final double deliveryFee;
  final String status; // pending/accepted/preparing/en_route/delivered/cancelled
  final DeliveryStep currentStep;
  final String? deliveryOtp;
  final DateTime createdAt;

  const DeliveryOrder({
    required this.id,
    required this.orderNumber,
    this.vendorId,
    required this.restaurantName,
    this.pickupAddress,
    this.customerId,
    required this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.items = const [],
    required this.totalAmount,
    required this.deliveryFee,
    required this.status,
    required this.currentStep,
    this.deliveryOtp,
    required this.createdAt,
  });

  factory DeliveryOrder.fromSupabase(Map<String, dynamic> row) {
    return DeliveryOrder(
      id: row['id'] as String,
      orderNumber: row['order_number'] as String? ?? '',
      vendorId: row['vendor_id'] as String?,
      restaurantName: row['restaurant_name'] as String? ?? 'Restaurant',
      pickupAddress: row['pickup_address'] as String?,
      customerId: row['customer_id'] as String?,
      customerName: row['customer_name'] as String? ?? 'Customer',
      customerPhone: row['customer_phone'] as String?,
      deliveryAddress: row['delivery_address'] as String?,
      deliveryLat: (row['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (row['delivery_lng'] as num?)?.toDouble(),
      items: (row['items'] as List?)
              ?.map((i) => OrderItemLine.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      totalAmount: (row['total_amount'] as num).toDouble(),
      deliveryFee: (row['delivery_fee'] as num).toDouble(),
      status: row['status'] as String? ?? 'pending',
      currentStep: DeliveryStep.fromInt(row['current_step'] as int? ?? 1),
      deliveryOtp: row['delivery_otp'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
