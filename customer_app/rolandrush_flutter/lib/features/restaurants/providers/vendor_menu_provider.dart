import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/menu_item.dart';

final vendorMenuProvider = FutureProvider.family<List<MenuItem>, String>((ref, vendorId) async {
  final res = await SupabaseService.client
      .from('menu_items')
      .select('*, vendor_profiles(restaurant_name, logo_url, rating, is_sponsored)')
      .eq('vendor_id', vendorId)
      .eq('is_available', true)
      .order('created_at', ascending: false);
  return (res as List).map((r) => MenuItem.fromSupabase(r as Map<String, dynamic>)).toList();
});
