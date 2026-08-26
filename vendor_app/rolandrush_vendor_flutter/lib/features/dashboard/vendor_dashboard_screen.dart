import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/primitives.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/order_card.dart';
import '../orders/providers/vendor_orders_provider.dart';
import '../menu/providers/menu_manager_provider.dart';
import '../wallet/providers/vendor_wallet_provider.dart';
import '../notifications/providers/vendor_notifications_provider.dart';
import 'providers/vendor_session_provider.dart';

const _quickLinks = [
  (path: '/insights', label: 'Insights', icon: Icons.bar_chart_rounded),
  (path: '/promote', label: 'Promote', icon: Icons.campaign_outlined),
  (path: '/menu', label: 'Menu', icon: Icons.restaurant_menu_rounded),
  (path: '/withdraw', label: 'Withdraw', icon: Icons.account_balance_outlined),
];

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorSessionProvider);
    final vendorId = vendor?.id ?? '';
    final ordersState = vendorId.isEmpty ? null : ref.watch(vendorOrdersProvider(vendorId));
    final menuState = vendorId.isEmpty ? null : ref.watch(menuManagerProvider(vendorId));
    final walletState = ref.watch(vendorWalletProvider);
    final unread = ref.watch(vendorUnreadCountProvider);

    final active = ordersState?.active ?? [];
    final soldOut = (menuState?.items ?? []).where((i) => !i.isAvailable).toList();
    final todayRevenue = (ordersState?.orders ?? [])
        .where((o) => _isToday(o.createdAt))
        .fold<double>(0, (s, o) => s + o.totalAmount);
    final todayOrders = (ordersState?.orders ?? []).where((o) => _isToday(o.createdAt)).length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning, ${vendor?.ownerName?.split(' ').first ?? 'there'}', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                          Text(vendor?.restaurantName ?? 'Your restaurant', style: AppTheme.num(size: 20, weight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.lineStrong)),
                            child: const Icon(Icons.notifications_none_rounded, size: 18),
                          ),
                          if (unread > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text('$unread', style: AppTheme.num(size: 10, weight: FontWeight.w800, color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (vendor != null && !vendor.isLive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: vendor.verificationStatus == 'rejected' ? AppColors.coralSoft : AppColors.warnSoft,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Row(
                      children: [
                        Icon(vendor.verificationStatus == 'rejected' ? Icons.error_outline : Icons.schedule,
                            size: 18, color: vendor.verificationStatus == 'rejected' ? AppColors.coral : AppColors.warn),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vendor.verificationStatus == 'rejected'
                                ? 'Verification rejected — contact support to fix and resubmit.'
                                : 'Your restaurant is pending review. It won\'t appear to customers until an admin verifies it.',
                            style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: vendor.verificationStatus == 'rejected' ? AppColors.coral : AppColors.warn),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TODAY'S REVENUE", style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                      Text(naira(todayRevenue), style: AppTheme.num(size: 42, weight: FontWeight.w800)),
                      Container(margin: const EdgeInsets.symmetric(vertical: 14), height: 1, color: AppColors.line),
                      Row(
                        children: [
                          Expanded(child: _statCol('$todayOrders', 'Orders')),
                          Expanded(child: _statCol('${active.length}', 'In progress', color: AppColors.coral)),
                          Expanded(child: _statCol('—', 'Avg. accept')),
                        ],
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vendor?.isOpen == true ? 'Accepting orders' : 'Kitchen closed', style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                            Text(vendor?.isOpen == true ? 'Customers can order right now' : 'Customers cannot order right now', style: AppTheme.sans(size: 11, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                      AppToggle(checked: vendor?.isOpen ?? true, onChanged: (v) => ref.read(vendorSessionProvider.notifier).setIsOpen(v)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('In the kitchen', style: AppTheme.num(size: 15, weight: FontWeight.w700)),
                    GestureDetector(onTap: () => context.push('/orders'), child: Text('All orders', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral))),
                  ],
                ),
                const SizedBox(height: 10),
                if (active.isEmpty)
                  AppCard(
                    child: Column(
                      children: [
                        Text('No orders in progress', style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('New orders will alert you here.', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                      ],
                    ),
                  )
                else
                  Column(
                    children: active.take(3).map((o) => Padding(padding: const EdgeInsets.only(bottom: 10), child: OrderCard(order: o, compact: true, onAdvance: () => ref.read(vendorOrdersProvider(vendorId).notifier).advanceStatus(o)))).toList(),
                  ),
                const SizedBox(height: 20),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WALLET BALANCE', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                          Text(naira(walletState.wallet?.balance ?? 0), style: AppTheme.num(size: 26, weight: FontWeight.w800)),
                        ],
                      ),
                      _MiniButton(label: 'Withdraw', onTap: () => context.push('/wallet')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                  children: _quickLinks.map((q) => _quickLinkTile(context, q)).toList(),
                ),
                if (soldOut.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/menu'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.warnSoft, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.warn.withOpacity(0.25))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${soldOut.length} items marked sold out', style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                                Text(soldOut.map((i) => i.name).join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                              ],
                            ),
                          ),
                          Text('Fix', style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: AppColors.warn)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: VendorBottomNav(currentPath: '/dashboard', newOrderCount: active.where((o) => o.status.name == 'pending').length)),
        ],
      ),
    );
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  Widget _statCol(String value, String label, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTheme.num(size: 20, weight: FontWeight.w800, color: color ?? AppColors.ink)),
        Text(label, style: AppTheme.sans(size: 11, color: AppColors.inkMuted)),
      ],
    );
  }

  Widget _quickLinkTile(BuildContext context, ({String path, String label, IconData icon}) q) {
    return GestureDetector(
      onTap: () => context.push(q.path),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.line), boxShadow: AppShadows.card),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(q.icon, size: 19, color: AppColors.inkMuted),
            const SizedBox(height: 6),
            Text(q.label, style: AppTheme.sans(size: 11, weight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MiniButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(AppRadius.btn)),
        child: Text(label, style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}
