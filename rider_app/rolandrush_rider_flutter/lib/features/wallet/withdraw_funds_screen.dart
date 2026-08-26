import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/keypad.dart';
import 'providers/wallet_provider.dart';

/// Ports Withdraw.tsx off the real `wallets`/`withdrawal_requests` tables.
class WithdrawFundsScreen extends ConsumerStatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  ConsumerState<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends ConsumerState<WithdrawFundsScreen> {
  String amount = '';
  bool submitting = false;
  double? justSubmitted;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);
    final balance = state.wallet?.balance ?? 0;
    final value = double.tryParse(amount.isEmpty ? '0' : amount) ?? 0;
    final valid = value >= state.minWithdrawal && value <= balance;
    final bankAsync = ref.watch(riderBankDetailsProvider);
    final bank = bankAsync.valueOrNull;

    if (justSubmitted != null) {
      return AppScreen(
        onBack: () => setState(() => justSubmitted = null),
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Container(height: 80, width: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.online), child: const Icon(Icons.check_rounded, color: Colors.white, size: 44)),
              const SizedBox(height: 22),
              Text('${naira(justSubmitted!)} requested', style: AppTheme.sans(size: 30, weight: FontWeight.w800, letterSpacing: -0.8)),
              const SizedBox(height: 8),
              Text('Your bank transfer will be processed shortly.', textAlign: TextAlign.center, style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: AppColors.inkMuted)),
              const SizedBox(height: 28),
              AppButton(fullWidth: false, variant: AppButtonVariant.secondary, onPressed: () => setState(() => justSubmitted = null), child: const Text('Done')),
            ],
          ),
        ),
      );
    }

    return AppScreen(
      title: 'Withdraw',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AVAILABLE BALANCE', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
                Text(naira(balance), style: AppTheme.sans(size: 44, weight: FontWeight.w800, letterSpacing: -1.2)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.ink, width: 2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AMOUNT TO WITHDRAW', style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
                Text(amount.isEmpty ? '₦0' : naira(value), style: AppTheme.sans(size: 38, weight: FontWeight.w800, letterSpacing: -1)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.inkMuted),
            const SizedBox(width: 8),
            Expanded(child: Text('Minimum withdrawal is ${naira(state.minWithdrawal)}. No transfer fee.', style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: AppColors.inkMuted))),
          ]),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Row(
              children: [
                Container(height: 48, width: 48, decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(AppRadius.btn)), child: const Icon(Icons.account_balance_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(bank?['bank_name'] as String? ?? 'No bank account on file', style: AppTheme.sans(size: 17, weight: FontWeight.w700)),
                      Text(
                        bank == null ? 'Add one in Profile → Bank account' : '${bank['account_number'] ?? ''}',
                        style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppKeypad(
            onPress: (d) => setState(() => amount = amount.length < 7 ? amount + d : amount),
            onDelete: () => setState(() => amount = amount.isEmpty ? amount : amount.substring(0, amount.length - 1)),
          ),
          const SizedBox(height: 14),
          AppButton(
            size: AppButtonSize.xl,
            onPressed: valid && !submitting
                ? () async {
                    setState(() => submitting = true);
                    final ok = await ref.read(walletProvider.notifier).requestWithdrawal(value, bank ?? {'bank_name': 'Not set', 'account_number': 'Not set'});
                    if (!mounted) return;
                    setState(() {
                      submitting = false;
                      if (ok) justSubmitted = value;
                      amount = '';
                    });
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit — check the amount')));
                    }
                  }
                : null,
            child: submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(amount.isEmpty ? 'Withdraw' : 'Withdraw ${naira(value)}'),
          ),
          const SizedBox(height: 24),
          Text('WITHDRAWAL HISTORY', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
          const SizedBox(height: 10),
          if (state.history.isEmpty) Text('No withdrawals yet.', style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: AppColors.inkFaint)),
          ...state.history.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(naira(w.amount), style: AppTheme.sans(size: 17, weight: FontWeight.w700)),
                            Text(DateFormat('MMM d, y').format(w.createdAt), style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: w.status == 'completed' ? AppColors.onlineSoft : AppColors.alertSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(w.status.toUpperCase(), style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: w.status == 'completed' ? AppColors.online : AppColors.alert)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
