import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_service.dart';
import '../../../core/providers/platform_settings_provider.dart';
import '../../../models/rider_profile.dart';

/// Fallback only — the real value comes from platform_settings and is
/// loaded into WalletState on load(), same pattern as the vendor app's
/// min_withdrawal_amount handling.
const fallbackMinWithdrawal = 2000.0; // matches Withdraw.tsx's mock MINIMUM

class WalletState {
  final Wallet? wallet;
  final List<WithdrawalRequest> history;
  final double minWithdrawal;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final WithdrawalRequest? lastSubmitted;

  const WalletState({
    this.wallet,
    this.history = const [],
    this.minWithdrawal = fallbackMinWithdrawal,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.lastSubmitted,
  });

  WalletState copyWith({
    Wallet? wallet,
    List<WithdrawalRequest>? history,
    double? minWithdrawal,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    WithdrawalRequest? lastSubmitted,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      history: history ?? this.history,
      minWithdrawal: minWithdrawal ?? this.minWithdrawal,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      lastSubmitted: lastSubmitted ?? this.lastSubmitted,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletState()) {
    load();
    _subscribe();
  }

  /// Same fix as the vendor app's vendor_wallet_provider.dart — without
  /// this, a rider's own payout (credited by complete_delivery_and_credit
  /// when THIS rider confirms a delivery) only shows up after a full app
  /// restart, since load() only ever ran once at construction.
  void _subscribe() {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    SupabaseService.client
        .channel('rider_wallet_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'wallets',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (_) => load(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (_) => load(),
        )
        .subscribe();
  }

  Future<void> load() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final walletRow = await SupabaseService.client.from('wallets').select().eq('user_id', userId).maybeSingle();
      final historyRows = await SupabaseService.client
          .from('withdrawal_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final settings = await SupabaseService.client.from('platform_settings').select('key, value');
      final settingsMap = {for (final row in (settings as List)) row['key'] as String: row['value'].toString()};

      state = state.copyWith(
        wallet: walletRow != null ? Wallet.fromSupabase(walletRow) : null,
        history: (historyRows as List).map((r) => WithdrawalRequest.fromSupabase(r as Map<String, dynamic>)).toList(),
        // platform_settings uses min_withdrawal_amount for the vendor app;
        // reused here since it's a platform-wide config, not vendor-specific
        // — no rider-only override key exists in platform_settings today.
        minWithdrawal: platformSettingDouble(settingsMap, 'min_withdrawal_amount', fallbackMinWithdrawal),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Only creates the withdrawal *request* — actual bank payout is a
  /// server-side job (Paystack/bank transfer API + webhook to flip
  /// status), same as the vendor app's withdrawal flow. This just inserts
  /// the pending row.
  Future<bool> requestWithdrawal(double amount, Map<String, dynamic> bankDetails) async {
    final userId = SupabaseService.currentUserId;
    final wallet = state.wallet;
    if (userId == null || wallet == null) return false;
    if (amount < state.minWithdrawal || amount > wallet.balance) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      await SupabaseService.client.from('withdrawal_requests').insert({
        'user_id': userId,
        'amount': amount,
        'status': 'pending',
        'bank_details': bankDetails,
        'auto_approved': false,
      });
      await load();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) => WalletNotifier());

/// `rider_profiles` has no bank_name/account_number columns (unlike
/// vendor_profiles, which does) and there's no rider_bank_accounts table
/// either — so there's nowhere to durably store a rider's payout account.
/// As a stand-in, this reads the `bank_details` JSON off the rider's most
/// recent withdrawal_requests row, which is the closest thing to "the bank
/// account on file" that actually exists in the schema today. Flagged as a
/// backend follow-up: add bank columns to rider_profiles (or a dedicated
/// table) rather than inferring it from withdrawal history.
final riderBankDetailsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return null;
  final row = await SupabaseService.client
      .from('withdrawal_requests')
      .select('bank_details')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();
  return row?['bank_details'] as Map<String, dynamic>?;
});
