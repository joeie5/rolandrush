import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/primitives.dart';
import '../dashboard/providers/vendor_session_provider.dart';

const _checks = ['Business details received', 'Documents uploaded', 'Payout account verified'];

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorSessionProvider);
    final approved = vendor?.status == 'active';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandMark(),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: approved ? AppColors.goodSoft : AppColors.warnSoft, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(approved ? Icons.check_circle : Icons.schedule, size: 14, color: approved ? AppColors.good : AppColors.warn),
                    const SizedBox(width: 6),
                    Text(approved ? 'APPROVED' : 'UNDER REVIEW', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: approved ? AppColors.good : AppColors.warn).copyWith(letterSpacing: 0.6)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                approved ? "You're live on RolandRush." : "We're reviewing your application.",
                style: AppTheme.num(size: 28, weight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                approved
                    ? '${vendor?.restaurantName ?? 'Your restaurant'} is now visible to customers in Osogbo. Add your menu and start taking orders.'
                    : 'Most restaurants are approved within 24 hours. We\'ll text ${vendor?.phoneNumber ?? 'you'} the moment a decision is made.',
                style: AppTheme.sans(size: 14, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.card),
                child: Column(
                  children: [
                    for (final c in _checks) _checkRow(c, true),
                    const Divider(height: 20, color: AppColors.line),
                    _checkRow('Compliance review${approved ? '' : ' · Est. 24 hrs'}', approved),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                full: true,
                size: AppButtonSize.lg,
                onPressed: approved ? () => context.go('/dashboard') : null,
                child: Text(approved ? 'Go to dashboard' : 'Waiting for approval'),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => ref.read(vendorSessionProvider.notifier).load(),
                  child: Text('Refresh status', style: AppTheme.sans(size: 12, color: AppColors.inkSubtle)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkRow(String label, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: done ? AppColors.goodSoft : AppColors.warnSoft, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: done ? const Icon(Icons.check, size: 14, color: AppColors.good) : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.warn, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTheme.sans(size: 14, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
