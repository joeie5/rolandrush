import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/supabase_service.dart';
import '../../models/rider_profile.dart';

/// Loads and drives the current rider's own `rider_profiles` row — backs
/// the online/offline toggle everywhere (Home, Jobs) and rider details
/// shown on Profile/VehicleDetails.
class RiderStatusNotifier extends StateNotifier<AsyncValue<RiderProfile?>> {
  RiderStatusNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final row = await SupabaseService.client
          .from('rider_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      state = AsyncValue.data(row != null ? RiderProfile.fromSupabase(row) : null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setOnline(bool online) async {
    final profile = state.valueOrNull;
    if (profile == null) return;
    if (online) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    }
    await SupabaseService.client.from('rider_profiles').update({'is_online': online}).eq('id', profile.id);
    state = AsyncValue.data(profile.copyWith(isOnline: online));
  }
}

final riderStatusProvider = StateNotifierProvider<RiderStatusNotifier, AsyncValue<RiderProfile?>>(
  (ref) => RiderStatusNotifier(),
);

/// Real average from `rider_reviews` — no fabricated rating. Null/empty
/// means "No ratings yet" (see Profile/Home screens).
/// `rider_reviews.rider_id` references `rider_profiles.id` (same pattern
/// as `orders.vendor_id` -> `vendor_profiles.id` in the vendor app), not
/// the auth user id — use profile.id, not profile.userId.
final riderRatingProvider = FutureProvider<(double? avg, int count)>((ref) async {
  final profile = ref.watch(riderStatusProvider).valueOrNull;
  if (profile == null) return (null, 0);
  final rows = await SupabaseService.client
      .from('rider_reviews')
      .select('rating')
      .eq('rider_id', profile.id);
  final ratings = (rows as List).map((r) => (r['rating'] as num).toDouble()).toList();
  if (ratings.isEmpty) return (null, 0);
  final avg = ratings.reduce((a, b) => a + b) / ratings.length;
  return (avg, ratings.length);
});
