import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/primitives.dart';

/// No `payment_methods` table exists yet — checkout currently takes a
/// payment method as a plain string. This screen is a shell until that's
/// backed by real cards/bank details.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppScreenHeader(title: 'Payment methods'),
      body: AppScreenBody(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 32,
                    decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: Text('CASH', style: AppTheme.sans(size: 10, weight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cash on delivery', style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                        Text('Pay the rider when your order arrives', style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: AppColors.coral, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Card and bank-transfer payments aren\'t wired up yet — checkout will support them once a payment '
              'provider (Paystack/Flutterwave) is integrated.',
              style: AppTheme.sans(size: 13, color: AppColors.ink35),
            ),
          ],
        ),
      ),
    );
  }
}
