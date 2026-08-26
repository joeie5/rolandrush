import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/vendor_order.dart';

final vendorOrderByIdProvider = FutureProvider.family<VendorOrder?, String>((ref, orderId) async {
  final res = await SupabaseService.client.from('orders').select().eq('id', orderId).maybeSingle();
  return res != null ? VendorOrder.fromSupabase(res) : null;
});
