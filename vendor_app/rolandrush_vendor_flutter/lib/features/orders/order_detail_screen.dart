import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/vendor_order.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/error_view.dart';
import '../dashboard/providers/vendor_session_provider.dart';
import 'providers/vendor_order_detail_provider.dart';
import 'providers/vendor_orders_provider.dart';

// Full canonical vocabulary, not just the vendor-writable subset — once
// picked_up/delivering happen (rider-owned), order.status.indexOf() must
// still find them here. With the old 4-stage list (placed/preparing/
// ready/delivered), indexOf() returned -1 for those two statuses, which
// reset the entire progress bar to "nothing done" the moment a rider
// picked up the order — worse than just a missing visual step.
const _timeline = [
  VendorOrderStatus.placed,
  VendorOrderStatus.preparing,
  VendorOrderStatus.ready,
  VendorOrderStatus.pickedUp,
  VendorOrderStatus.delivering,
  VendorOrderStatus.delivered,
];

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(vendorOrderByIdProvider(orderId));
    final vendor = ref.watch(vendorSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return Scaffold(
              appBar: AppScreenHeader(title: 'Order', onBack: () => context.pop()),
              body: const Center(child: Text('Order not found')),
            );
          }
          final action = order.status.advanceLabel;
          final currentStep = _timeline.indexOf(order.status);
          final subtotal = order.effectiveSubtotal;
          final rate = order.commissionRateApplied ?? 0.15;
          // commission_amount is only written once the order is delivered
          // (advanceStatus computes it then); estimate it beforehand so the
          // vendor can see what they'll net without waiting for completion.
          final commission = order.commissionAmount > 0 ? order.commissionAmount : subtotal * rate;
          final payout = subtotal - commission;

          return Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppScreenHeader(
              title: 'Order #${order.id.substring(0, order.id.length.clamp(0, 6))}',
              subtitle: relativeTime(order.createdAt),
              onBack: () => context.pop(),
              action: AppPill(label: order.status.label, bg: AppColors.coralSoft, fg: AppColors.coral),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ORDER SUBTOTAL', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                            Text(naira(subtotal), style: AppTheme.num(size: 34, weight: FontWeight.w800)),
                            Text('Customer paid ${naira(order.totalAmount)} total (incl. delivery + service fee — neither of those go to you)', style: AppTheme.sans(size: 11, color: AppColors.inkSubtle)),
                            Container(margin: const EdgeInsets.symmetric(vertical: 12), height: 1, color: AppColors.line),
                            _row('Commission (${(rate * 100).toStringAsFixed(0)}%)', '− ${naira(commission)}'),
                            const SizedBox(height: 6),
                            _row('Payment method', order.paymentStatus),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('You receive', style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                                Text(naira(payout), style: AppTheme.num(size: 16, weight: FontWeight.w800, color: AppColors.coral)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (order.status != VendorOrderStatus.cancelled) ...[
                        const SizedBox(height: 12),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PROGRESS', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                              const SizedBox(height: 12),
                              Row(
                                children: List.generate(_timeline.length, (i) {
                                  final done = i <= currentStep;
                                  return Expanded(
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Container(width: 10, height: 10, decoration: BoxDecoration(color: done ? AppColors.coral : AppColors.lineStrong, shape: BoxShape.circle)),
                                            const SizedBox(height: 6),
                                            Text(_timeline[i].label, style: AppTheme.sans(size: 10, weight: FontWeight.w600, color: done ? AppColors.ink : AppColors.inkSubtle)),
                                          ],
                                        ),
                                        if (i < _timeline.length - 1)
                                          Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18), color: i < currentStep ? AppColors.coral : AppColors.lineStrong)),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ITEMS', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                            const SizedBox(height: 10),
                            for (final line in order.items)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(8)),
                                      alignment: Alignment.center,
                                      child: Text('${line.quantity}', style: AppTheme.num(size: 11, weight: FontWeight.w800)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(line.name, style: AppTheme.sans(size: 14, weight: FontWeight.w500))),
                                    Text(naira(line.price * line.quantity), style: AppTheme.num(size: 14, weight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            if (order.notes != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.warnSoft, borderRadius: BorderRadius.circular(AppRadius.btn)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.message_outlined, size: 14, color: AppColors.warn),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(order.notes!, style: AppTheme.sans(size: 12))),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CUSTOMER', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                            const SizedBox(height: 8),
                            Text(order.customerName ?? '—', style: AppTheme.sans(size: 15, weight: FontWeight.w600)),
                            if (order.deliveryAddress != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkMuted), const SizedBox(width: 6), Expanded(child: Text(order.deliveryAddress!, style: AppTheme.sans(size: 13, color: AppColors.inkMuted)))]),
                              ),
                            const SizedBox(height: 12),
                            AppButton(full: true, variant: AppButtonVariant.secondary, onPressed: () {}, child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.call_outlined, size: 15), const SizedBox(width: 8), Text('Call ${order.customerPhone ?? ''}')])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (action != null || order.status != VendorOrderStatus.cancelled)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: const BoxDecoration(color: AppColors.canvas, border: Border(top: BorderSide(color: AppColors.line))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (action != null)
                          AppButton(
                            full: true,
                            size: AppButtonSize.lg,
                            onPressed: () async {
                              await ref.read(vendorOrdersProvider(vendor?.id ?? '').notifier).advanceStatus(order);
                              ref.invalidate(vendorOrderByIdProvider(orderId));
                            },
                            child: Text(action),
                          ),
                        if (order.status.vendorCancellable) ...[
                          const SizedBox(height: 8),
                          AppButton(
                            full: true,
                            variant: AppButtonVariant.danger,
                            onPressed: () => _confirmCancel(context, ref, order),
                            child: const Text('Cancel order'),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(vendorOrderByIdProvider(orderId))),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref, VendorOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancel this order?', style: AppTheme.num(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              '${order.customerName ?? 'The customer'} will be refunded ${naira(order.totalAmount)} and notified. Frequent cancellations affect your ranking in the customer feed.',
              style: AppTheme.sans(size: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 20),
            AppButton(
              full: true,
              size: AppButtonSize.lg,
              onPressed: () async {
                final vendor = ref.read(vendorSessionProvider);
                await ref.read(vendorOrdersProvider(vendor?.id ?? '').notifier).cancelOrder(order);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) context.go('/orders');
              },
              child: const Text('Yes, cancel order'),
            ),
            const SizedBox(height: 8),
            AppButton(full: true, variant: AppButtonVariant.secondary, onPressed: () => Navigator.of(ctx).pop(), child: const Text('Keep order')),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.sans(size: 13, color: AppColors.inkMuted)),
          Text(value, style: AppTheme.num(size: 13, weight: FontWeight.w700)),
        ],
      );
}
