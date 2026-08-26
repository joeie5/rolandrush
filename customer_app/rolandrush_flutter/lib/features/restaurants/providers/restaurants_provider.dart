import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/restaurant.dart';

/// All verified vendor_profiles, used by Home (curated rows) and Discover
/// (full list + search). Unverified vendors don't appear to customers —
/// see ROLANDRUSH_CONSOLIDATED_BRIEF.md's business-model wiring notes.
/// Small dataset expected for now — fetched in one page.
final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final res = await SupabaseService.client
      .from('vendor_profiles')
      .select()
      .eq('verification_status', 'verified')
      .order('is_sponsored', ascending: false)
      .order('rating', ascending: false);
  return (res as List).map((r) => Restaurant.fromSupabase(r as Map<String, dynamic>)).toList();
});

final restaurantByIdProvider = FutureProvider.family<Restaurant?, String>((ref, id) async {
  final restaurants = await ref.watch(restaurantsProvider.future);
  try {
    return restaurants.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});
