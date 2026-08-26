import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/app_button.dart';
import '../earnings/providers/earnings_provider.dart';

/// Ports DeliverySuccess.tsx. Tip amount from the mock (a fixed ₦200) has
/// no backing column on `orders`/`transactions` — no tipping feature
/// exists in the schema — so this shows only the real delivery_fee credit,
/// no fabricated tip line.
class DeliverySuccessScreen extends ConsumerWidget {
  final double amount;
  const DeliverySuccessScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnings = ref.watch(earningsProvider);
    final todayTotals = earnings.totalsFor(EarningsRange.today);

    return Scaffold(
      backgroundColor: AppColors.online,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 96,
                      width: 96,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      child: const Icon(Icons.check_rounded, size: 56, color: AppColors.online),
                    ),
                    const SizedBox(height: 22),
                    Text('Delivery complete', style: AppTheme.sans(size: 22, weight: FontWeight.w700, color: Colors.white.withOpacity(0.85))),
                    const SizedBox(height: 6),
                    Text('+${naira(amount)}', style: AppTheme.sans(size: 60, weight: FontWeight.w800, color: Colors.white, letterSpacing: -1.6)),
                    const SizedBox(height: 6),
                    Text('${naira(amount)} delivery', style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.card)),
                      child: Row(
                        children: [
                          Expanded(child: _Stat(label: 'Earned today', value: naira(todayTotals.amount))),
                          Expanded(child: _Stat(label: 'Deliveries', value: '${todayTotals.trips}')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                size: AppButtonSize.xl,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go('/jobs'),
                child: const Text('Find next order', style: TextStyle(color: AppColors.online)),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: () => context.go('/home'), child: Text('Back to dashboard', style: AppTheme.sans(size: 16, weight: FontWeight.w700, color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.sans(size: 24, weight: FontWeight.w800, color: Colors.white, letterSpacing: -0.6)),
        Text(label.toUpperCase(), style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: Colors.white.withOpacity(0.75), letterSpacing: 0.4)),
      ],
    );
  }
}
