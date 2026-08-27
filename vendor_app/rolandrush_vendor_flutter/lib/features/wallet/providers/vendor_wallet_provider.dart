import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_service.dart';
import '../../../core/providers/platform_settings_provider.dart';
import '../../../models/vendor_wallet.dart';

/// Fallback only — the real values come from platform_settings and are
/// loaded into VendorWalletState on load().
const _fallbackMinWithdrawal = 5000.0;
const _fallbackAutoApprovalThreshold = 20000.0;

class VendorWalletState {
  final VendorWallet? wallet;
  final List<VendorTransaction> transactions;
  final double minWithdrawal;
  final double autoApprovalThreshold;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const VendorWalletState({
    this.wallet,
    this.transactions = const [],
    this.minWithdrawal = _fallbackMinWithdrawal,
    this.autoApprovalThreshold = _fallbackAutoApprovalThreshold,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  VendorWalletState copyWith({
    VendorWallet? wallet,
    List<VendorTransaction>? transactions,
    double? minWithdrawal,
    double? autoApprovalThreshold,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return VendorWalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      minWithdrawal: minWithdrawal ?? this.minWithdrawal,
      autoApprovalThreshold: autoApprovalThreshold ?? this.autoApprovalThreshold,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class VendorWalletNotifier extends StateNotifier<VendorWalletState> {
  VendorWalletNotifier() : super(const VendorWalletState()) {
    load();
    _subscribe();
  }

  /// Without this, new payouts never show up here without a full app
  /// restart — order payouts are credited by the RIDER app's session
  /// (complete_delivery_and_credit) when a delivery completes, which has
  /// no way to tell an already-open vendor wallet screen in a different
  /// app/session to refetch on its own. Same fix as
  /// vendor_orders_provider.dart's realtime subscription.
  void _subscribe() {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    SupabaseService.client
        .channel('vendor_wallet_$userId')
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
      final walletRow =
          await SupabaseService.client.from('wallets').select().eq('user_id', userId).maybeSingle();
      final txRows = await SupabaseService.client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      final settings = await SupabaseService.client.from('platform_settings').select('key, value');
      final settingsMap = {for (final row in (settings as List)) row['key'] as String: row['value'].toString()};

      state = state.copyWith(
        wallet: walletRow != null ? VendorWallet.fromSupabase(walletRow) : null,
        transactions:
            (txRows as List).map((r) => VendorTransaction.fromSupabase(r as Map<String, dynamic>)).toList(),
        minWithdrawal: platformSettingDouble(settingsMap, 'min_withdrawal_amount', _fallbackMinWithdrawal),
        autoApprovalThreshold: platformSettingDouble(settingsMap, 'auto_withdrawal_approval_threshold', _fallbackAutoApprovalThreshold),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Only creates the withdrawal *request* — actual bank payout, and any
  /// auto-approval for requests at/below platform_settings'
  /// auto_withdrawal_approval_threshold, is server-side work (a Supabase
  /// Edge Function or scheduled job — a client can't be trusted to approve
  /// its own payout). This just inserts the pending row and enforces the
  /// minimum amount before allowing submission at all.
  Future<bool> requestWithdrawal(double amount) async {
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

final vendorWalletProvider = StateNotifierProvider<VendorWalletNotifier, VendorWalletState>(
  (ref) => VendorWalletNotifier(),
);
