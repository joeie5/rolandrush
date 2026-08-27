import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/keypad.dart';
import '../../widgets/code_boxes.dart';
import 'providers/active_delivery_provider.dart';

/// Ports DeliveryConfirm.tsx — final step, verified against
/// `orders.delivery_otp` (via ActiveDeliveryNotifier.confirmDeliveryWithOtp)
/// instead of firing on a plain tap.
class DeliveryConfirmScreen extends ConsumerStatefulWidget {
  const DeliveryConfirmScreen({super.key});

  @override
  ConsumerState<DeliveryConfirmScreen> createState() => _DeliveryConfirmScreenState();
}

class _DeliveryConfirmScreenState extends ConsumerState<DeliveryConfirmScreen> {
  String code = '';
  bool confirming = false;

  @override
  Widget build(BuildContext context) {
    final activeOrderAsync = ref.watch(riderActiveOrderProvider);
    final order = activeOrderAsync.valueOrNull;

    return AppScreen(
      onBack: () => context.pop(),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FINAL STEP', style: AppTheme.sans(size: 15, weight: FontWeight.w800, color: AppColors.online, letterSpacing: 0.4)),
            const SizedBox(height: 4),
            Text(
              'Ask ${order?.customerName ?? 'the customer'} for their 4-digit code',
              style: AppTheme.sans(size: 32, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -1),
            ),
            const SizedBox(height: 28),
            CodeBoxes(value: code, tone: CodeBoxTone.ink),
            const SizedBox(height: 20),
            Center(
              child: Text("Don't hand over the order until the code matches.",
                  textAlign: TextAlign.center, style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: AppColors.inkMuted)),
            ),
            const SizedBox(height: 24),
            AppKeypad(
              onPress: (d) => setState(() => code = code.length < 4 ? code + d : code),
              onDelete: () => setState(() => code = code.isEmpty ? code : code.substring(0, code.length - 1)),
            ),
            const SizedBox(height: 16),
            AppButton(
              size: AppButtonSize.xl,
              variant: AppButtonVariant.success,
              onPressed: code.length >= 4 && !confirming && order != null
                  ? () async {
                      setState(() => confirming = true);
                      final ok = await ref.read(activeDeliveryProvider(order.id).notifier).confirmDeliveryWithOtp(code);
                      if (!mounted) return;
                      setState(() => confirming = false);
                      if (ok) {
                        // Same staleness issue as jobs_screen.dart's
                        // accept flow — without this, Home would keep
                        // showing "delivery in progress" for an order
                        // that's actually already delivered.
                        ref.invalidate(riderActiveOrderProvider);
                        context.go('/delivery/success', extra: order.deliveryFee);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect code. Ask the customer to double-check it.')));
                      }
                    }
                  : null,
              child: confirming
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm delivery'),
            ),
          ],
        ),
      ),
    );
  }
}
