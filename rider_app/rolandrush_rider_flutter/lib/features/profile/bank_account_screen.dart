import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../wallet/providers/wallet_provider.dart';

/// Ports BankAccount.tsx. See wallet_provider.dart's riderBankDetailsProvider
/// doc comment: `rider_profiles` has no bank columns and there's no
/// rider_bank_accounts table, so "on file" here means "most recent
/// withdrawal_requests.bank_details" — the closest real substitute. Adding
/// a real account (below) isn't persisted anywhere yet either, since
/// there's nowhere in the schema to put it outside of an actual withdrawal
/// request.
class BankAccountScreen extends ConsumerWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankAsync = ref.watch(riderBankDetailsProvider);
    final bank = bankAsync.valueOrNull;

    return AppScreen(
      title: 'Bank account',
      subtitle: 'Where your payouts land',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bank == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_outlined, size: 40, color: AppColors.inkFaint),
                  const SizedBox(height: 12),
                  Text('No bank account on file', style: AppTheme.sans(size: 18, weight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Add one the first time you withdraw.', style: AppTheme.sans(size: 14, weight: FontWeight.w600, color: AppColors.inkMuted)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.online, width: 2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(height: 48, width: 48, decoration: BoxDecoration(color: AppColors.onlineSoft, borderRadius: BorderRadius.circular(AppRadius.btn)), child: const Icon(Icons.account_balance_outlined, color: AppColors.online)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${bank['bank_name'] ?? 'Bank'}', style: AppTheme.sans(size: 20, weight: FontWeight.w800, letterSpacing: -0.4)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.onlineSoft, borderRadius: BorderRadius.circular(6)),
                        child: const Text('DEFAULT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.online)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: AppColors.line),
                  const SizedBox(height: 12),
                  Text('ACCOUNT NUMBER', style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
                  Text('${bank['account_number'] ?? ''}', style: AppTheme.sans(size: 26, weight: FontWeight.w800, letterSpacing: -0.4)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Payouts are sent when you withdraw. Changing your account pauses withdrawals for 24 hours for security.',
            style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 16),
          AppButton(
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/withdraw'),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_rounded), SizedBox(width: 8), Text('Add another account')]),
          ),
        ],
      ),
    );
  }
}
