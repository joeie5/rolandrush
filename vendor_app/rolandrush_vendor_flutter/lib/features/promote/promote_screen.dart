import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../dashboard/providers/vendor_session_provider.dart';

class PromoteScreen extends ConsumerWidget {
  const PromoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppScreenHeader(title: 'Promote', subtitle: 'Reach more customers in Osogbo', onBack: () => context.pop()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.coralSoft, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.auto_awesome, size: 18, color: AppColors.coral),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Boost your listing', style: AppTheme.num(size: 17, weight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('Sponsored restaurants in Osogbo get about 3.4× more views in the customer feed.', style: AppTheme.sans(size: 13, color: AppColors.inkMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(full: true, size: AppButtonSize.lg, onPressed: () => _showComingSoon(context), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.campaign_outlined, size: 16), SizedBox(width: 8), Text('Create promotion')])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Current status', style: AppTheme.num(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          AppCard(
            child: Row(
              children: [
                Icon(vendor?.status == 'active' ? Icons.check_circle : Icons.info_outline, size: 20, color: AppColors.inkMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sponsored placement: off', style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                      Text('Campaign creation and spend tracking aren\'t wired up yet — needs an ad_campaigns table.', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promotion creation is coming soon')));
  }
}
