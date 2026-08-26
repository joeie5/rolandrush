import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/vendor_wallet.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/error_view.dart';
import 'providers/vendor_wallet_provider.dart';

class VendorWalletScreen extends ConsumerWidget {
  const VendorWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vendorWalletProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: state.error != null
                ? AppErrorView(error: state.error!, onRetry: () => ref.read(vendorWalletProvider.notifier).load())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Wallet', style: AppTheme.num(size: 20, weight: FontWeight.w800)),
                          AppPill(label: 'Secured', bg: AppColors.goodSoft, fg: AppColors.good),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AVAILABLE BALANCE', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                            Text(naira(state.wallet?.balance ?? 0), style: AppTheme.num(size: 42, weight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            AppButton(full: true, size: AppButtonSize.lg, onPressed: () => context.push('/withdraw'), child: const Text('Withdraw to bank')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _statCard('TOTAL EARNED', naira(state.wallet?.totalEarned ?? 0))),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('TOTAL WITHDRAWN', naira(state.wallet?.totalWithdrawn ?? 0))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Transactions', style: AppTheme.num(size: 15, weight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      if (state.transactions.isEmpty)
                        AppCard(padding: const EdgeInsets.symmetric(vertical: 30), child: Center(child: Text('No transactions yet', style: AppTheme.sans(size: 13, color: AppColors.inkMuted))))
                      else
                        AppCard(
                          flush: true,
                          child: Column(
                            children: [
                              for (var i = 0; i < state.transactions.length; i++) ...[
                                _txRow(state.transactions[i]),
                                if (i != state.transactions.length - 1) const Divider(height: 1, color: AppColors.line),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          Align(alignment: Alignment.bottomCenter, child: VendorBottomNav(currentPath: '/wallet')),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.sans(size: 10, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.5)),
          Text(value, style: AppTheme.num(size: 20, weight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _txRow(VendorTransaction tx) {
    final outgoing = tx.type == 'debit';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: outgoing ? AppColors.canvas : AppColors.goodSoft, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(outgoing ? Icons.north_east_rounded : Icons.south_west_rounded, size: 16, color: outgoing ? AppColors.inkMuted : AppColors.good),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description ?? (outgoing ? 'Withdrawal' : 'Order payout'), overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                Text(relativeTime(tx.createdAt), style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${outgoing ? '−' : '+'}${naira(tx.amount.abs())}', style: AppTheme.num(size: 15, weight: FontWeight.w800, color: outgoing ? AppColors.ink : AppColors.good)),
              if (tx.status == 'pending') Text('Pending', style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.warn)),
            ],
          ),
        ],
      ),
    );
  }
}
