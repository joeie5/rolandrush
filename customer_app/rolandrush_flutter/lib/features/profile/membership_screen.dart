import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/primitives.dart';

/// No `memberships`/subscription table exists yet — visual shell only.
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppScreenHeader(title: 'RushPass'),
      body: AppScreenBody(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.workspace_premium_outlined, color: AppColors.coral, size: 28),
                  const SizedBox(height: 12),
                  Text('You\'re not subscribed', style: AppTheme.display(size: 18, weight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Free delivery, exclusive drops and priority support.', style: AppTheme.sans(size: 13, color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionLabel(title: 'What you get'),
            AppCard(
              child: Column(
                children: const [
                  AppListRow(icon: Icons.local_shipping_outlined, title: 'Free delivery', hint: 'On orders over ₦3,000'),
                  Divider(height: 1, color: AppColors.line),
                  AppListRow(icon: Icons.bolt_outlined, title: 'Priority preparation', hint: 'Jump the vendor queue'),
                  Divider(height: 1, color: AppColors.line),
                  AppListRow(icon: Icons.percent_rounded, title: '2x RolandPoints', hint: 'On every order'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(full: true, size: AppButtonSize.lg, onPressed: null, child: const Text('Subscribe — coming soon')),
          ],
        ),
      ),
    );
  }
}
