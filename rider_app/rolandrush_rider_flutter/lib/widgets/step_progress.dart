import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/delivery_order.dart';

const stepLabels = ['En route', 'Pickup', 'Delivering', 'Delivered'];

/// Ports components/StepProgress.tsx.
class StepProgress extends StatelessWidget {
  final DeliveryStep step;
  const StepProgress({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final done = i < step.value - 1;
        final current = i == step.value - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 6, decoration: BoxDecoration(color: done ? AppColors.online : current ? AppColors.coral : AppColors.line, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 4),
                Text(
                  stepLabels[i].toUpperCase(),
                  style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: current ? AppColors.coral : done ? AppColors.online : AppColors.inkFaint, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
