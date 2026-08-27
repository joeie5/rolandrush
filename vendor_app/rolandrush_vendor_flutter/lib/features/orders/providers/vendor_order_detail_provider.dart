import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/vendor_order.dart';

/// A StreamProvider, not a one-shot FutureProvider — the previous version
/// fetched once and never updated, so a vendor sitting on this screen
/// never saw the rider's own status changes (picked_up/delivering/
/// delivered) land, since nothing here ever re-queried. `.stream()`
/// keeps this screen live for as long as it's open, matching the pattern
/// already used for the vendor orders list's realtime subscription.
final vendorOrderByIdProvider = StreamProvider.family<VendorOrder?, String>((ref, orderId) {
  return SupabaseService.client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', orderId)
      .map((rows) => rows.isNotEmpty ? VendorOrder.fromSupabase(rows.first) : null);
});
