import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/primitives.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/order_card.dart';
import '../../widgets/error_view.dart';
import '../../models/vendor_order.dart';
import '../dashboard/providers/vendor_session_provider.dart';
import '../notifications/providers/vendor_notifications_provider.dart';
import 'providers/vendor_orders_provider.dart';

class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen> {
  int tab = 0; // 0 = active, 1 = history

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorSessionProvider);
    final vendorId = vendor?.id ?? '';
    final state = vendorId.isEmpty ? null : ref.watch(vendorOrdersProvider(vendorId));
    final unread = ref.watch(vendorUnreadCountProvider);

    final active = state?.active ?? [];
    final history = state?.history ?? [];
    final list = tab == 0 ? active : history;
    final historyTotal = history.where((o) => o.status.value == 'delivered').fold<double>(0, (s, o) => s + o.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: state?.error != null
                ? AppErrorView(error: state!.error!, onRetry: () => ref.read(vendorOrdersProvider(vendorId).notifier).load())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Orders', style: AppTheme.num(size: 20, weight: FontWeight.w800)),
                          GestureDetector(
                            onTap: () => context.push('/notifications'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.lineStrong)),
                                  child: const Icon(Icons.notifications_none_rounded, size: 18),
                                ),
                                if (unread > 0)
                                  Positioned(right: -1, top: -1, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.line.withOpacity(0.7), borderRadius: BorderRadius.circular(AppRadius.btn)),
                        child: Row(
                          children: [
                            Expanded(child: _tabBtn('Active', 0, active.length)),
                            Expanded(child: _tabBtn('History', 1, null)),
                          ],
                        ),
                      ),
                      if (tab == 1) ...[
                        const SizedBox(height: 16),
                        AppCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('COMPLETED TODAY', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                                  Text(naira(historyTotal), style: AppTheme.num(size: 26, weight: FontWeight.w800)),
                                ],
                              ),
                              Text('${history.where((o) => o.status.value == 'delivered').length} delivered', style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (list.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            children: [
                              Text('Nothing here yet', style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(tab == 0 ? 'New orders appear instantly with an alert.' : 'Completed orders will be listed here.', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: list
                              .map((o) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: OrderCard(
                                      order: o,
                                      onAdvance: tab == 0 ? () => ref.read(vendorOrdersProvider(vendorId).notifier).advanceStatus(o) : null,
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
          ),
          Align(alignment: Alignment.bottomCenter, child: VendorBottomNav(currentPath: '/orders', newOrderCount: active.where((o) => o.status.value == 'pending').length)),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index, int? count) {
    final active = tab == index;
    return GestureDetector(
      onTap: () => setState(() => tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(9), boxShadow: active ? AppShadows.card : null),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: active ? AppColors.ink : AppColors.inkMuted)),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: active ? AppColors.coralSoft : Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(999)),
                child: Text('$count', style: AppTheme.num(size: 11, weight: FontWeight.w800, color: active ? AppColors.coral : AppColors.inkSubtle)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
