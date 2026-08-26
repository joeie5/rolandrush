import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bottom_nav.dart';
import '../dashboard/providers/vendor_session_provider.dart';
import '../notifications/providers/vendor_notifications_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorSessionProvider);
    final unread = ref.watch(vendorUnreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                Text('Account', style: AppTheme.num(size: 20, weight: FontWeight.w800)),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: Text((vendor?.restaurantName ?? 'RR').substring(0, 1).toUpperCase(), style: AppTheme.num(size: 20, weight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vendor?.restaurantName ?? 'Your restaurant', overflow: TextOverflow.ellipsis, style: AppTheme.num(size: 16, weight: FontWeight.w800)),
                            Text(vendor?.address ?? '—', overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(999)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.coral),
                          const SizedBox(width: 3),
                          Text(vendor?.rating.toStringAsFixed(1) ?? '0.0', style: AppTheme.num(size: 12, weight: FontWeight.w700)),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: vendor?.isOpen == true ? AppColors.good : AppColors.inkSubtle, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(vendor?.isOpen == true ? 'Accepting orders' : 'Kitchen closed', style: AppTheme.sans(size: 14, weight: FontWeight.w600))),
                      AppToggle(checked: vendor?.isOpen ?? true, onChanged: (v) => ref.read(vendorSessionProvider.notifier).setIsOpen(v)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(999)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.workspace_premium_outlined, size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('${vendor?.subscriptionTier ?? 'STANDARD'} PLAN', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: Colors.white).copyWith(letterSpacing: 0.5)),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      Text('Manage your subscription in-app soon', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                      const SizedBox(height: 12),
                      AppButton(full: true, variant: AppButtonVariant.secondary, onPressed: () {}, child: const Text('Compare plans')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _row(icon: Icons.store_outlined, title: 'Business information', detail: '${vendor?.ownerName ?? '—'} · CAC ${vendor?.id.substring(0, 6) ?? '—'}', onTap: () {}),
                const SizedBox(height: 8),
                _row(icon: Icons.schedule_outlined, title: 'Operating hours', detail: vendor?.operatingHours != null ? 'Set' : 'Not set', onTap: () {}),
                const SizedBox(height: 8),
                _row(icon: Icons.account_balance_outlined, title: 'Payout bank details', detail: '${vendor?.bankName ?? '—'} · ${vendor?.accountNumber ?? '—'}', onTap: () => context.push('/withdraw')),
                const SizedBox(height: 8),
                _row(icon: Icons.notifications_none_rounded, title: 'Notifications', detail: unread > 0 ? '$unread unread' : 'All caught up', onTap: () => context.push('/notifications'), highlight: unread > 0),
                const SizedBox(height: 8),
                _row(icon: Icons.bar_chart_rounded, title: 'Insights', detail: 'Revenue, top sellers, peak hours', onTap: () => context.push('/insights')),
                const SizedBox(height: 24),
                AppButton(
                  full: true,
                  variant: AppButtonVariant.ghost,
                  onPressed: () async {
                    await SupabaseService.client.auth.signOut();
                    if (context.mounted) context.go('/');
                  },
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.logout_rounded, size: 15, color: AppColors.coral),
                    SizedBox(width: 8),
                    Text('Log out', style: TextStyle(color: AppColors.coral)),
                  ]),
                ),
                const SizedBox(height: 8),
                Center(child: Text('RolandRush Business v3.0', style: AppTheme.sans(size: 11, color: AppColors.inkSubtle))),
              ],
            ),
          ),
          const Align(alignment: Alignment.bottomCenter, child: VendorBottomNav(currentPath: '/account')),
        ],
      ),
    );
  }

  Widget _row({required IconData icon, required String title, required String detail, required VoidCallback onTap, bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.line), boxShadow: AppShadows.card),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.inkMuted)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                  Text(detail, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 12, weight: highlight ? FontWeight.w700 : FontWeight.w400, color: highlight ? AppColors.coral : AppColors.inkMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.inkSubtle),
          ],
        ),
      ),
    );
  }
}
