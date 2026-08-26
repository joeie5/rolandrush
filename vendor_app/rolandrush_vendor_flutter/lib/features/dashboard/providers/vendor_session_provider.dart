import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/vendor_profile.dart';

class VendorSessionNotifier extends StateNotifier<VendorProfile?> {
  VendorSessionNotifier() : super(null) {
    load();
  }

  Future<void> load() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    final row = await SupabaseService.client
        .from('vendor_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row != null) state = VendorProfile.fromSupabase(row);
  }

  Future<void> setIsOpen(bool isOpen) async {
    final vendor = state;
    if (vendor == null) return;
    state = vendor.copyWith(isOpen: isOpen);
    await SupabaseService.client.from('vendor_profiles').update({'is_open': isOpen}).eq('id', vendor.id);
  }
}

final vendorSessionProvider = StateNotifierProvider<VendorSessionNotifier, VendorProfile?>(
  (ref) => VendorSessionNotifier(),
);
