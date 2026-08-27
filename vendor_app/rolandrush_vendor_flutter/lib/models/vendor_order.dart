/// Maps to `orders` in the shared RolandRushApp schema. `status` follows one
/// canonical vocabulary written by all three apps:
///   placed (customer, at checkout) -> preparing (vendor) -> ready (vendor)
///   -> picked_up (rider) -> delivering (rider) -> delivered (rider)
///   -> cancelled (vendor, or customer — only from placed/preparing/ready)
/// The vendor app only ever WRITES preparing/ready/cancelled. picked_up/
/// delivering/delivered are rider-owned and shown here read-only.
enum VendorOrderStatus { placed, preparing, ready, pickedUp, delivering, delivered, cancelled }

VendorOrderStatus _statusFromString(String? s) {
  switch (s) {
    case 'preparing':
      return VendorOrderStatus.preparing;
    case 'ready':
      return VendorOrderStatus.ready;
    case 'picked_up':
      return VendorOrderStatus.pickedUp;
    case 'delivering':
      return VendorOrderStatus.delivering;
    case 'delivered':
      return VendorOrderStatus.delivered;
    case 'cancelled':
      return VendorOrderStatus.cancelled;
    default:
      return VendorOrderStatus.placed;
  }
}

extension VendorOrderStatusX on VendorOrderStatus {
  /// The exact string written to/read from `orders.status`.
  String get value {
    switch (this) {
      case VendorOrderStatus.pickedUp:
        return 'picked_up';
      default:
        return name;
    }
  }

  String get label {
    switch (this) {
      case VendorOrderStatus.placed:
        return 'New';
      case VendorOrderStatus.preparing:
        return 'Preparing';
      case VendorOrderStatus.ready:
        return 'Ready for Pickup';
      case VendorOrderStatus.pickedUp:
        return 'Picked up by rider';
      case VendorOrderStatus.delivering:
        return 'Out for delivery';
      case VendorOrderStatus.delivered:
        return 'Delivered';
      case VendorOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Label for the one-tap "advance" button, or null once the rider owns
  /// the order (picked_up onward) or it's in a terminal state.
  String? get advanceLabel {
    switch (this) {
      case VendorOrderStatus.placed:
        return 'Accept order';
      case VendorOrderStatus.preparing:
        return 'Mark ready';
      default:
        return null;
    }
  }

  /// What the vendor can move an order to from here. Vendor never sets
  /// picked_up/delivering/delivered — that's the rider app's job once a
  /// rider physically takes the order (see active_delivery_provider.dart).
  VendorOrderStatus? get next {
    switch (this) {
      case VendorOrderStatus.placed:
        return VendorOrderStatus.preparing;
      case VendorOrderStatus.preparing:
        return VendorOrderStatus.ready;
      default:
        return null;
    }
  }

  /// Vendor can only cancel before a rider has physically picked up.
  bool get vendorCancellable =>
      this == VendorOrderStatus.placed || this == VendorOrderStatus.preparing || this == VendorOrderStatus.ready;
}

class OrderLineAddOn {
  final String name;
  final int quantity;
  final double price;
  const OrderLineAddOn({required this.name, required this.quantity, required this.price});

  factory OrderLineAddOn.fromJson(Map<String, dynamic> json) => OrderLineAddOn(
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );
}

class OrderLineItem {
  final String name;
  final int quantity;
  final double price;
  final List<OrderLineAddOn> addOns;
  const OrderLineItem({required this.name, required this.quantity, required this.price, this.addOns = const []});

  // The customer app writes add-ons under 'add_ons'; a handful of older
  // rows (seeded before that key existed) use 'addons' instead — read
  // either so this doesn't silently drop add-ons on real historical orders.
  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        addOns: ((json['add_ons'] ?? json['addons']) as List?)
                ?.map((a) => OrderLineAddOn.fromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );
}

class VendorOrder {
  final String id;
  final String vendorId;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final List<OrderLineItem> items;
  final double totalAmount;
  final double? subtotal;
  final double? commissionRateApplied;
  final double commissionAmount;
  final VendorOrderStatus status;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;

  const VendorOrder({
    required this.id,
    required this.vendorId,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.items = const [],
    required this.totalAmount,
    this.subtotal,
    this.commissionRateApplied,
    this.commissionAmount = 0,
    required this.status,
    this.paymentStatus = 'pending',
    this.notes,
    required this.createdAt,
  });

  /// Falls back to computing subtotal from line items if the column
  /// wasn't set (orders placed before checkout math was wired up).
  double get effectiveSubtotal => subtotal ?? items.fold<double>(0, (s, l) => s + l.price * l.quantity);

  /// What the vendor actually receives once commission is deducted —
  /// delivery fee goes to the rider, service fee to the platform, neither
  /// belongs in the vendor's payout.
  double get netPayout => effectiveSubtotal - (commissionAmount > 0 ? commissionAmount : effectiveSubtotal * (commissionRateApplied ?? 0));

  factory VendorOrder.fromSupabase(Map<String, dynamic> row) {
    return VendorOrder(
      id: row['id'] as String,
      vendorId: row['vendor_id'] as String,
      customerName: row['customer_name'] as String?,
      customerPhone: row['customer_phone'] as String?,
      deliveryAddress: row['delivery_address'] as String?,
      items: (row['items'] as List?)
              ?.map((i) => OrderLineItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      totalAmount: (row['total_amount'] as num).toDouble(),
      subtotal: (row['subtotal'] as num?)?.toDouble(),
      commissionRateApplied: (row['commission_rate_applied'] as num?)?.toDouble(),
      commissionAmount: (row['commission_amount'] as num?)?.toDouble() ?? 0,
      status: _statusFromString(row['status'] as String?),
      paymentStatus: row['payment_status'] as String? ?? 'pending',
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
