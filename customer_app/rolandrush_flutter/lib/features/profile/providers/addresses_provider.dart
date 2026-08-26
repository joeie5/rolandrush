import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/customer_address.dart';

final addressesProvider = FutureProvider<List<CustomerAddress>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  final res = await SupabaseService.client
      .from('customer_addresses')
      .select()
      .eq('user_id', userId)
      .order('is_default', ascending: false);
  return (res as List).map((r) => CustomerAddress.fromSupabase(r as Map<String, dynamic>)).toList();
});

final selectedAddressIdProvider = StateProvider<String?>((ref) => null);

class AddressesNotifier {
  static Future<void> add(String label, String line, {bool isDefault = false}) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    await SupabaseService.client.from('customer_addresses').insert({
      'user_id': userId,
      'label': label,
      'address_line': line,
      'is_default': isDefault,
    });
  }

  static Future<void> remove(String id) async {
    await SupabaseService.client.from('customer_addresses').delete().eq('id', id);
  }
}
