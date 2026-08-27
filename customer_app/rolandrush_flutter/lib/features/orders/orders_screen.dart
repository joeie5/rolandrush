import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/order.dart';
import '../../widgets/primitives.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/floating_cart_button.dart';
import '../../widgets/error_view.dart';
import 'providers/orders_provider.dart';

const _statusLabels = {
  'placed': 'Placed',
  'preparing': 'Preparing',
  'ready': 'Ready for pickup',
  'picked_up': 'Picked up',
  'delivering': 'On the way',
  'delivered': 'Delivered',
  'cancelled': 'Cancelled',
};

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.ink35),
                          const SizedBox(height: 16),
                          Text('No orders yet', style: AppTheme.display(size: 17, weight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text('Your order history will show up here.',
                              textAlign: TextAlign.center, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
                        ],
                      ),
                    ),
                  );
                }
                final active = orders.where((o) => o.isActive).toList();
                final past = orders.where((o) => !o.isActive).toList();

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ordersProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: [
                      Text('Orders', style: AppTheme.display(size: 26, weight: FontWeight.w800)),
                      if (active.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const SectionLabel(title: 'Active'),
                        ...active.map((o) => _OrderTile(order: o)),
                      ],
                      if (past.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const SectionLabel(title: 'Past orders'),
                        ...past.map((o) => _OrderTile(order: o)),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(ordersProvider)),
            ),
          ),
          const FloatingCartButton(bottom: 96),
          Align(alignment: Alignment.bottomCenter, child: AppBottomNav(currentPath: '/orders')),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final RushOrder order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push(order.isActive ? '/tracking/${order.id}' : '/orders'),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Icon(order.isActive ? Icons.local_shipping_outlined : Icons.check_circle_outline_rounded,
                    size: 20, color: order.isActive ? AppColors.coral : AppColors.mint),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurantName ?? order.orderNumber, style: AppTheme.display(size: 15, weight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('${order.orderNumber} · ${DateFormat('MMM d, h:mm a').format(order.createdAt)}',
                        style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(naira(order.totalAmount), style: AppTheme.display(size: 14, weight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(_statusLabels[order.status] ?? order.status,
                      style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: order.isActive ? AppColors.coral : AppColors.ink35)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
