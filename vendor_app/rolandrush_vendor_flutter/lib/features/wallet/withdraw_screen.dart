import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/primitives.dart';
import '../dashboard/providers/vendor_session_provider.dart';
import 'providers/vendor_wallet_provider.dart';

const _quickAmounts = [50000, 100000, 250000];

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final amountController = TextEditingController();
  bool done = false;
  bool submitting = false;
  double submittedAmount = 0;

  double get value => double.tryParse(amountController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(vendorWalletProvider);
    final vendor = ref.watch(vendorSessionProvider);
    final balance = walletState.wallet?.balance ?? 0;
    final minWithdrawal = walletState.minWithdrawal;
    final tooSmall = value > 0 && value < minWithdrawal;
    final tooBig = value > balance;
    final needsReview = value > walletState.autoApprovalThreshold;
    final valid = value > 0 && !tooSmall && !tooBig;

    if (done) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width: 64, height: 64, decoration: const BoxDecoration(color: AppColors.goodSoft, shape: BoxShape.circle), child: const Icon(Icons.check, size: 30, color: AppColors.good)),
                const SizedBox(height: 20),
                Text('Withdrawal sent', style: AppTheme.num(size: 24, weight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(naira(submittedAmount), style: AppTheme.num(size: 32, weight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text('On its way to ${vendor?.bankName ?? 'your bank'} ${vendor?.accountNumber ?? ''}. Payouts land within 1 business day.', textAlign: TextAlign.center, style: AppTheme.sans(size: 14, color: AppColors.inkMuted)),
                const SizedBox(height: 24),
                AppCard(
                  child: Column(
                    children: [
                      _line('New wallet balance', naira(balance - submittedAmount)),
                      const SizedBox(height: 8),
                      _line('Fee', '₦0'),
                    ],
                  ),
                ),
                const Spacer(),
                AppButton(full: true, size: AppButtonSize.lg, onPressed: () => context.go('/wallet'), child: const Text('Back to wallet')),
                const SizedBox(height: 8),
                AppButton(full: true, variant: AppButtonVariant.ghost, onPressed: () => context.go('/dashboard'), child: const Text('Go to dashboard')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppScreenHeader(title: 'Withdraw funds', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('AVAILABLE TO WITHDRAW', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                    Text(naira(balance), style: AppTheme.num(size: 30, weight: FontWeight.w800)),
                    const SizedBox(height: 20),
                    AppField(label: 'Amount', child: AppMoneyInput(controller: amountController, onChanged: (_) => setState(() {}))),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: (tooSmall || tooBig) ? AppColors.coral : AppColors.inkSubtle),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tooBig ? 'That is more than your available balance.' : tooSmall ? 'Minimum withdrawal is ${naira(minWithdrawal)}.' : 'Minimum withdrawal ${naira(minWithdrawal)} · no withdrawal fees.',
                            style: AppTheme.sans(size: 12, weight: (tooSmall || tooBig) ? FontWeight.w700 : FontWeight.w400, color: (tooSmall || tooBig) ? AppColors.coral : AppColors.inkMuted),
                          ),
                        ),
                      ],
                    ),
                    if (needsReview) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.warn),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Larger withdrawals may take up to 24 hours for review.',
                              style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.warn),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final q in _quickAmounts) ...[
                          Expanded(child: _quickBtn(naira(q), () => setState(() => amountController.text = q.toString()))),
                          const SizedBox(width: 8),
                        ],
                        Expanded(child: _quickBtn('All', () => setState(() => amountController.text = balance.toStringAsFixed(0)))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppCard(
                      child: Row(
                        children: [
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.account_balance_outlined, color: AppColors.inkMuted)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vendor?.accountName ?? vendor?.restaurantName ?? '—', overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                                Text('${vendor?.bankName ?? '—'} · ${vendor?.accountNumber ?? '—'}', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                              ],
                            ),
                          ),
                          AppPill(label: 'Verified', bg: AppColors.goodSoft, fg: AppColors.good),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppButton(
              full: true,
              size: AppButtonSize.lg,
              onPressed: valid && !submitting ? _submit : null,
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(value > 0 ? 'Withdraw ${naira(value)}' : 'Withdraw'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.btn), border: Border.all(color: AppColors.lineStrong)),
        alignment: Alignment.center,
        child: Text(label, style: AppTheme.num(size: 13, weight: FontWeight.w700)),
      ),
    );
  }

  Widget _line(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.sans(size: 13, color: AppColors.inkMuted)),
          Text(value, style: AppTheme.num(size: 13, weight: FontWeight.w700)),
        ],
      );

  Future<void> _submit() async {
    setState(() => submitting = true);
    final amount = value;
    final ok = await ref.read(vendorWalletProvider.notifier).requestWithdrawal(amount);
    if (!mounted) return;
    setState(() => submitting = false);
    if (ok) {
      setState(() {
        done = true;
        submittedAmount = amount;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit withdrawal')));
    }
  }
}
