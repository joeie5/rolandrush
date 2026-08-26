import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/online_toggle.dart';
import 'rider_status_provider.dart';
import '../orders/providers/available_orders_provider.dart';
import '../delivery/providers/active_delivery_provider.dart';
import '../earnings/providers/earnings_provider.dart';
import '../wallet/providers/wallet_provider.dart';

/// Ports Home.tsx.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(riderStatusProvider).valueOrNull;
    final isOnline = profile?.isOnline ?? false;
    final activeOrderAsync = ref.watch(riderActiveOrderProvider);
    final availableJobs = ref.watch(availableOrdersProvider).orders;
    final earnings = ref.watch(earningsProvider);
    final todayTotals = earnings.totalsFor(EarningsRange.today);
    final rating = ref.watch(riderRatingProvider).valueOrNull;
    final balance = ref.watch(walletProvider).wallet?.balance ?? 0;

    return AppScreen(
      nav: true,
      navPath: '/home',
      title: 'Hi, ${profile?.firstName ?? 'Rider'}',
      subtitle: profile?.address ?? 'Osogbo, Osun State',
      action: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.push('/profile/notifications'),
        child: Container(
          height: 48,
          width: 48,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
          child: const Icon(Icons.notifications_outlined, color: AppColors.ink),
        ),
      ),
      child: Column(
        children: [
          const OnlineToggle(),
          activeOrderAsync.when(
            data: (order) {
              if (order == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: () => context.push('/delivery/active'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(AppRadius.card)),
                    child: Row(
                      children: [
                        const Icon(Icons.navigation_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Delivery in progress', style: AppTheme.sans(size: 20, weight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
                              Text('${order.restaurantName} → ${order.deliveryAddress ?? ''}',
                                  overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 14, weight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('EARNED TODAY', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.5)),
                      InkWell(onTap: () => context.push('/earnings'), child: Text('Details', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.coral))),
                    ],
                  ),
                  Text(naira(todayTotals.amount), style: AppTheme.sans(size: 46, weight: FontWeight.w800, color: AppColors.online, letterSpacing: -1.4)),
                  Container(margin: const EdgeInsets.symmetric(vertical: 14), height: 1, color: AppColors.line),
                  Row(
                    children: [
                      Expanded(child: _Metric(label: 'Deliveries', value: '${todayTotals.trips}')),
                      Expanded(child: _Metric(label: 'Online', value: isOnline ? 'Active' : 'Off')),
                      Expanded(
                        child: _Metric(
                          label: 'Rating',
                          value: rating == null || rating.$1 == null ? 'No ratings yet' : rating.$1!.toStringAsFixed(1),
                          icon: rating != null && rating.$1 != null ? const Icon(Icons.star_rounded, size: 16, color: AppColors.alert) : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: isOnline
                ? InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: () => context.push('/jobs'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(color: AppColors.alert, borderRadius: BorderRadius.circular(AppRadius.card)),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${availableJobs.length} jobs nearby', style: AppTheme.sans(size: 24, weight: FontWeight.w800, color: Colors.white, letterSpacing: -0.6)),
                                Text(
                                  'Best pay right now: ${naira(availableJobs.isEmpty ? 0 : availableJobs.map((j) => j.deliveryFee).reduce((a, b) => a > b ? a : b))}',
                                  style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: Colors.white.withOpacity(0.85)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.line, width: 2)),
                    child: Column(
                      children: [
                        Text('No jobs while offline', style: AppTheme.sans(size: 19, weight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Flip the switch above to see nearby orders.', style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: AppColors.inkMuted)),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          AppButton(variant: AppButtonVariant.secondary, onPressed: () => context.push('/withdraw'), child: Text('Cash out ${naira(balance)}')),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Widget? icon;
  const _Metric({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Flexible(child: Text(value, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 20, weight: FontWeight.w800, letterSpacing: -0.4))),
        ]),
        Text(label.toUpperCase(), style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
      ],
    );
  }
}
