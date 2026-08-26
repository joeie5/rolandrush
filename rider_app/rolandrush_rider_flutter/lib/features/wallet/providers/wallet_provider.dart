import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/rider_profile.dart';

const minimumWithdrawal = 5000.0; // mirrors WithdrawFunds.tsx mock value

class WalletState {
  final Wallet? wallet;
  final List<WithdrawalRequest> history;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const WalletState({
    this.wallet,
    this.history = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  WalletState copyWith({
    Wallet? wallet,
    List<WithdrawalRequest>? history,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletState()) {
    load();
  }

  Future<void> load() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final walletRow = await SupabaseService.client
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final historyRows = await SupabaseService.client
          .from('withdrawal_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      state = state.copyWith(
        wallet: walletRow != null ? Wallet.fromSupabase(walletRow) : null,
        history: (historyRows as List)
            .map((r) => WithdrawalRequest.fromSupabase(r as Map<String, dynamic>))
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Only creates the withdrawal *request* — actual bank payout is a
  /// server-side job (Paystack/bank transfer API + webhook to flip status),
  /// same as your other payout flows. This just inserts the pending row.
  Future<bool> requestWithdrawal(double amount, Map<String, dynamic> bankDetails) async {
    final userId = SupabaseService.currentUserId;
    final wallet = state.wallet;
    if (userId == null || wallet == null) return false;
    if (amount < minimumWithdrawal || amount > wallet.balance) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      await SupabaseService.client.from('withdrawal_requests').insert({
        'user_id': userId,
        'amount': amount,
        'status': 'pending',
        'bank_details': bankDetails,
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

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(),
);
