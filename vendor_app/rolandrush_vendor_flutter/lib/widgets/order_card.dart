import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/format.dart';
import '../models/vendor_order.dart';
import 'primitives.dart';
import 'app_button.dart';

(Color, Color) _statusTone(VendorOrderStatus s) {
  switch (s) {
    case VendorOrderStatus.placed:
      return (AppColors.coralSoft, AppColors.coral);
    case VendorOrderStatus.preparing:
      return (AppColors.warnSoft, AppColors.warn);
    case VendorOrderStatus.ready:
    case VendorOrderStatus.pickedUp:
    case VendorOrderStatus.delivering:
      return (AppColors.infoSoft, AppColors.info);
    case VendorOrderStatus.delivered:
      return (AppColors.goodSoft, AppColors.good);
    case VendorOrderStatus.cancelled:
      return (AppColors.line, AppColors.inkMuted);
  }
}

class OrderCard extends StatelessWidget {
  final VendorOrder order;
  final VoidCallback? onAdvance;
  final bool compact;
  const OrderCard({super.key, required this.order, this.onAdvance, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final tone = _statusTone(order.status);
    final isNew = order.status == VendorOrderStatus.placed;
    final itemCount = order.items.fold<int>(0, (s, l) => s + l.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isNew ? AppColors.coral.withOpacity(0.4) : AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.push('/orders/${order.id}'),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppPill(label: order.status.label, bg: tone.$1, fg: tone.$2),
                            const SizedBox(width: 8),
                            Text('#${order.id.substring(0, order.id.length.clamp(0, 6))}', style: AppTheme.num(size: 11, weight: FontWeight.w700, color: AppColors.inkSubtle)),
                            const SizedBox(width: 4),
                            Text('· ${relativeTime(order.createdAt)}', style: AppTheme.sans(size: 11, color: AppColors.inkSubtle)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(order.customerName ?? 'Customer', style: AppTheme.sans(size: 15, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(order.items.map((l) => '${l.quantity}× ${l.name}').join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 13, color: AppColors.inkMuted)),
                        if (!compact && order.deliveryAddress != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(order.deliveryAddress!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 11, color: AppColors.inkSubtle)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(naira(order.totalAmount), style: AppTheme.num(size: 18, weight: FontWeight.w800)),
                      Text('$itemCount items', style: AppTheme.sans(size: 11, color: AppColors.inkSubtle)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.inkSubtle),
                ],
              ),
            ),
          ),
          if (order.status.advanceLabel != null && onAdvance != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: AppButton(
                full: true,
                variant: isNew ? AppButtonVariant.primary : AppButtonVariant.secondary,
                onPressed: onAdvance,
                child: Text(order.status.advanceLabel!),
              ),
            ),
        ],
      ),
    );
  }
}
