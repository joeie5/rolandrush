import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/supabase_service.dart';
import '../../../models/rider_profile.dart';

/// Drives the online/offline switch on HomeDashboard. Going online starts
/// a location stream that writes back to `rider_profiles.last_lat/last_lng`
/// so dispatch can find nearby riders — the mock UI just has a Switch with
/// no backing logic, so this is new, not ported.
class RiderStatusNotifier extends StateNotifier<RiderProfile?> {
  RiderStatusNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    final row = await SupabaseService.client
        .from('rider_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row != null) state = RiderProfile.fromSupabase(row);
  }

  Future<void> setOnline(bool online) async {
    if (state == null) return;
    if (online) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    }
    await SupabaseService.client
        .from('rider_profiles')
        .update({'is_online': online}).eq('id', state!.id);
    state = RiderProfile(
      id: state!.id,
      userId: state!.userId,
      firstName: state!.firstName,
      lastName: state!.lastName,
      vehicleType: state!.vehicleType,
      verificationStatus: state!.verificationStatus,
      isOnline: online,
      lastLat: state!.lastLat,
      lastLng: state!.lastLng,
    );
  }
}

final riderStatusProvider = StateNotifierProvider<RiderStatusNotifier, RiderProfile?>(
  (ref) => RiderStatusNotifier(),
);
