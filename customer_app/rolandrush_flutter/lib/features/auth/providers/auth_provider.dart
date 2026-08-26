import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../../core/supabase_service.dart';

/// Dev-only bypass phone number — no SMS provider is configured on the
/// RolandRushApp project, so real signInWithOtp/verifyOTP can't be tested
/// end to end yet. This number skips SMS entirely and accepts ANY code,
/// backed by a pre-seeded, pre-confirmed Supabase Auth account (created
/// directly via SQL — see ROLANDRUSH_CONSOLIDATED_BRIEF.md — since both
/// email-signup and anonymous sign-in trip the project's rate limit /
/// disabled-provider guards). currentUserId works everywhere else as normal.
/// Remove this once a real SMS provider (Twilio/etc.) is wired up.
const testBypassPhone = '+2348111111111';
const _testBypassEmail = 'devtest.8111111111@rolandrush.test';
const _testBypassPassword = 'RolandRushDevTest_8111111111!';

/// Wraps Supabase phone-OTP auth. Requires an SMS provider (Twilio/etc.)
/// configured on the RolandRushApp project — if none is configured,
/// signInWithOtp will throw and the UI surfaces that error as-is, except
/// for [testBypassPhone] which never touches SMS.
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<bool> sendOtp(String e164Phone) async {
    if (e164Phone == testBypassPhone) return true;

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

    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.auth.verifyOTP(
        phone: e164Phone,
        token: token,
        type: OtpType.sms,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Any code is accepted — signs into the pre-seeded dev account.
  Future<bool> _bypassSignIn() async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: _testBypassEmail,
        password: _testBypassPassword,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(),
);

final isSignedInProvider = Provider<bool>((ref) => SupabaseService.isSignedIn);
