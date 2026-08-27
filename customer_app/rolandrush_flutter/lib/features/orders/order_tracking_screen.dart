import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../core/supabase_service.dart';
import '../../models/order.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_view.dart';
import 'providers/orders_provider.dart';

// Driven entirely by `orders.status` (the cross-app lifecycle field), not
// `current_step` — current_step is a rider-only fine-grained field that
// only starts meaning anything once status reaches picked_up, and sits
// frozen at 1 for the entire placed/preparing/ready phase before any rider
// is even assigned. Using it as the primary tracker made the UI show "en
// route" the whole time an order was still just sitting with the vendor.
const _steps = ['Placed', 'Preparing', 'Ready for pickup', 'Picked up', 'On the way', 'Delivered'];
const _statusOrder = ['placed', 'preparing', 'ready', 'picked_up', 'delivering', 'delivered'];

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  RushOrder? liveOrder;

  @override
  void initState() {
    super.initState();
    SupabaseService.client
        .channel('order-${widget.orderId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: widget.orderId),
          callback: (payload) {
            if (mounted) setState(() => liveOrder = RushOrder.fromSupabase(payload.newRecord));
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.chevron_left, size: 22), onPressed: () => context.go('/orders')),
        title: Text('Track order', style: AppTheme.display(size: 18, weight: FontWeight.w800)),
      ),
      body: orderAsync.when(
        data: (fetched) {
          final order = liveOrder ?? fetched;
          if (order == null) return const Center(child: Text('Order not found'));
          // cancelled has no place on this forward-only progress track —
          // show it as a distinct terminal state, not a stalled position.
          final statusIndex = _statusOrder.indexOf(order.status);
          final step = statusIndex == -1 ? 0 : statusIndex + 1;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderNumber, style: AppTheme.display(size: 18, weight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(order.restaurantName ?? '', style: AppTheme.sans(size: 13, color: AppColors.ink35)),
                    const SizedBox(height: 20),
                    if (order.status == 'cancelled')
                      Row(
                        children: [
                          const Icon(Icons.cancel_outlined, size: 20, color: AppColors.coral),
                          const SizedBox(width: 8),
                          Text('Order cancelled', style: AppTheme.sans(size: 15, weight: FontWeight.w700, color: AppColors.coral)),
                        ],
                      )
                    else
                      for (var i = 0; i < _steps.length; i++)
                        _StepRow(label: _steps[i], done: i < step, active: i == step - 1, isLast: i == _steps.length - 1),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (order.deliveryOtp != null)
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock_outlined, size: 20, color: AppColors.coral),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery code', style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                            Text(order.deliveryOtp!, style: AppTheme.display(size: 20, weight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Text('Share with rider', style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Delivery address', order.deliveryAddress ?? '—'),
                    const SizedBox(height: 10),
                    _row('Total', naira(order.totalAmount)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                full: true,
                size: AppButtonSize.lg,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go('/orders'),
                child: const Text('Back to orders'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(orderByIdProvider(widget.orderId))),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: AppTheme.sans(size: 13, weight: FontWeight.w600))),
        ],
      );
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final bool isLast;
  const _StepRow({required this.label, required this.done, required this.active, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.coral : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: done ? AppColors.coral : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: done ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: done ? AppColors.coral : AppColors.line)),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(label, style: AppTheme.sans(size: 14, weight: active ? FontWeight.w700 : FontWeight.w500, color: done || active ? AppColors.ink : AppColors.ink35)),
          ),
        ],
      ),
    );
  }
}
