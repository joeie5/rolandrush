import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/format.dart';
import '../models/delivery_order.dart';
import 'app_button.dart';

/// Ports components/JobCard.tsx.
class JobCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback onAccept;
  const JobCard({super.key, required this.order, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final highPay = order.deliveryFee >= 3000;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (highPay)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.alertSoft, borderRadius: BorderRadius.circular(6)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.bolt_rounded, size: 14, color: AppColors.alert),
                          const SizedBox(width: 4),
                          Text('HIGH PAY', style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.alert, letterSpacing: 0.4)),
                        ]),
                      ),
                    Text(order.restaurantName, style: AppTheme.sans(size: 19, weight: FontWeight.w800, letterSpacing: -0.4)),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.inkMuted),
                      const SizedBox(width: 4),
                      Flexible(child: Text(order.pickupAddress ?? '', overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 14, weight: FontWeight.w600, color: AppColors.inkMuted))),
                    ]),
                  ],
                ),
              ),
              Text(naira(order.deliveryFee), style: AppTheme.sans(size: 28, weight: FontWeight.w800, letterSpacing: -0.8)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(AppRadius.btn)),
            child: Row(children: [
              const Icon(Icons.two_wheeler_rounded, size: 20),
              const SizedBox(width: 6),
              Text('${order.items.length} items', style: AppTheme.sans(size: 15, weight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: AppColors.inkMuted),
              children: [
                const TextSpan(text: 'Drop off · '),
                TextSpan(text: order.deliveryAddress ?? '', style: AppTheme.sans(size: 15, weight: FontWeight.w800, color: AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppButton(onPressed: onAccept, child: Text('Accept · ${naira(order.deliveryFee)}')),
        ],
      ),
    );
  }
}
