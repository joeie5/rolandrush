import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../../core/supabase_service.dart';

/// Dev-only bypass phone number — no SMS provider is configured on the
/// shared RolandRushApp project, and this project's email signup is
/// restricted too (both "@rolandrush.test" and "@rolandrush.example.com"
/// were rejected with email_address_invalid — likely a domain allow-list,
/// not a format issue). This reuses the SAME pre-confirmed dev account
/// already seeded via SQL for the customer app's bypass (same shared
/// database) rather than trying signUp again — it just adds a
/// vendor_profiles row for that user on first use.
const testBypassPhone = '+2348000000000';
const _testBypassEmail = 'devtest.8111111111@rolandrush.test';
const _testBypassPassword = 'RolandRushDevTest_8111111111!';

/// SECOND, DIFFERENT KIND of bypass — unlike [testBypassPhone] above (which
/// only ever signs into a synthetic, empty dev/test account), this signs
/// into a REAL vendor's real account ("tastyBites", +2349061111111) with no
/// OTP check, using a temporary password set on that account via the Admin
/// API for one-off QA (e.g. checking the R2 media migration renders
/// correctly against real menu items). This is a standing OTP-free door
/// into a real account for as long as this block exists — remove it (and
/// clear the password back off that Supabase Auth user) before shipping,
/// it must not reach production.
const _realVendorBypassPhone = '+2349061111111';
const _realVendorBypassPassword = 'RolandRushDevCheck_9061111111!';

class VendorAuthNotifier extends StateNotifier<AsyncValue<void>> {
  VendorAuthNotifier() : super(const AsyncValue.data(null));

  Future<bool> sendOtp(String e164Phone) async {
    if (e164Phone == testBypassPhone) return true;
    if (e164Phone == _realVendorBypassPhone) return true;

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
    if (e164Phone == _realVendorBypassPhone) return _realVendorBypassSignIn();

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

  /// Any code is accepted — signs into the shared pre-confirmed dev account
  /// and adds a vendor_profiles row for it on first use.
  Future<bool> _bypassSignIn() async {
    state = const AsyncValue.loading();
    final client = SupabaseService.client;
    try {
      await client.auth.signInWithPassword(email: _testBypassEmail, password: _testBypassPassword);

      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        final existing = await client.from('vendor_profiles').select('id').eq('user_id', userId).maybeSingle();
        if (existing == null) {
          await client.from('vendor_profiles').insert({
            'user_id': userId,
            'restaurant_name': 'Dev Test Kitchen',
            'first_name': 'Dev',
            'last_name': 'Test Account',
            'phone_number': testBypassPhone,
            'status': 'active',
            'is_open': true,
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

  /// See _realVendorBypassPhone doc comment — signs into a real vendor
  /// account via a temporary password, no OTP check.
  Future<bool> _realVendorBypassSignIn() async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.auth.signInWithPassword(
        phone: _realVendorBypassPhone.replaceFirst('+', ''),
        password: _realVendorBypassPassword,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Registers a new vendor: creates the phone-verified auth user (assumes
  /// verifyOtp already ran during signup's own OTP step) then inserts the
  /// vendor_profiles row. See ROLANDRUSH_CONSOLIDATED_BRIEF.md — this writes
  /// straight to the real relational table, not the legacy KV store.
  Future<bool> registerVendorProfile({
    required String restaurantName,
    required String ownerName,
    required String phoneNumber,
    required String address,
    String? cacNumber,
    String? bankName,
    String? accountNumber,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return false;
    final nameParts = ownerName.trim().split(RegExp(r'\s+'));
    try {
      await SupabaseService.client.from('vendor_profiles').insert({
        'user_id': userId,
        'restaurant_name': restaurantName,
        'first_name': nameParts.isNotEmpty ? nameParts.first : null,
        'last_name': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
        'phone_number': phoneNumber,
        'address': address,
        'cac_number': cacNumber,
        'bank_name': bankName,
        'account_number': accountNumber,
        'status': 'pending',
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

final vendorAuthProvider = StateNotifierProvider<VendorAuthNotifier, AsyncValue<void>>(
  (ref) => VendorAuthNotifier(),
);
