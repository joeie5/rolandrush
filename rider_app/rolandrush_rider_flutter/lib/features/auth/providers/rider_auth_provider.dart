import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../../core/supabase_service.dart';

/// Dev-only bypass phone number — mirrors the working precedent in the
/// customer app (+2348111111111-style) and vendor app (+2348000000000):
/// no SMS provider is wired up for this project yet, so any code entered
/// for this number signs into a shared, pre-confirmed Supabase Auth
/// account instead of a real OTP round-trip. Picked a phone not already
/// claimed by the other two apps' bypasses.
const testBypassPhone = '+2348222222222';
const _testBypassEmail = 'devtest.8111111111@rolandrush.test';
const _testBypassPassword = 'RolandRushDevTest_8111111111!';

/// SECOND, DIFFERENT KIND of bypass — unlike [testBypassPhone] above (which
/// signs into a synthetic, empty dev/test account), this signs into a REAL
/// rider account ("Tunde Bakare", based in Osogbo, +2348123334455) with no
/// OTP check, using a password set on that account via the Admin API —
/// same pattern as the vendor app's real-tastyBites-account bypass. This
/// is a standing OTP-free door into a real account for as long as this
/// block exists — remove it (and clear the password back off that
/// Supabase Auth user) before shipping, it must not reach production.
const _realRiderBypassPhone = '+2348123334455';
const _realRiderBypassPassword = 'RolandRushDevCheck_8123334455!';

class RiderAuthNotifier extends StateNotifier<AsyncValue<void>> {
  RiderAuthNotifier() : super(const AsyncValue.data(null));

  Future<bool> sendOtp(String e164Phone) async {
    if (e164Phone == testBypassPhone) return true;
    if (e164Phone == _realRiderBypassPhone) return true;

    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.auth.signInWithOtp(phone: e164Phone);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> verifyOtp(String e164Phone, String token) async {
    if (e164Phone == testBypassPhone) return _bypassSignIn();
    if (e164Phone == _realRiderBypassPhone) return _realRiderBypassSignIn();

    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.auth.verifyOTP(phone: e164Phone, token: token, type: OtpType.sms);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Any 4-digit code is accepted for the bypass number — signs into the
  /// shared dev account and creates a rider_profiles row (pre-verified, so
  /// the dev account skips straight past VerificationStatus into the
  /// Home/Jobs flow) if one doesn't already exist.
  Future<bool> _bypassSignIn() async {
    state = const AsyncValue.loading();
    final client = SupabaseService.client;
    try {
      await client.auth.signInWithPassword(email: _testBypassEmail, password: _testBypassPassword);

      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        final existing = await client.from('rider_profiles').select('id').eq('user_id', userId).maybeSingle();
        if (existing == null) {
          await client.from('rider_profiles').insert({
            'user_id': userId,
            'first_name': 'Dev',
            'last_name': 'Rider',
            'phone_number': testBypassPhone,
            'vehicle_type': 'Motorcycle',
            'verification_status': 'verified',
            'is_online': true,
          });
        }
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// See _realRiderBypassPhone doc comment — signs into a real rider
  /// account via a temporary password, no OTP check.
  Future<bool> _realRiderBypassSignIn() async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.auth.signInWithPassword(
        phone: _realRiderBypassPhone.replaceFirst('+', ''),
        password: _realRiderBypassPassword,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Registers a brand-new rider: assumes verifyOtp already confirmed the
  /// phone during the OTP step, this just writes the rider_profiles row.
  /// New riders land in verification_status = 'pending' (matches
  /// VerificationStatus.tsx's default "Under review" state).
  Future<bool> registerRiderProfile({
    required String fullName,
    required String email,
    required String address,
    required String phoneNumber,
    required String vehicleType,
    String? bankName,
    String? accountNumber,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return false;
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    try {
      await SupabaseService.client.from('rider_profiles').insert({
        'user_id': userId,
        'first_name': nameParts.isNotEmpty ? nameParts.first : null,
        'last_name': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
        'email': email,
        'address': address,
        'phone_number': phoneNumber,
        'vehicle_type': vehicleType,
        'verification_status': 'pending',
        'is_online': false,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

final riderAuthProvider = StateNotifierProvider<RiderAuthNotifier, AsyncValue<void>>(
  (ref) => RiderAuthNotifier(),
);
