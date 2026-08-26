import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/primitives.dart';

const _faqs = [
  ('How do I track my order?', 'Open Orders → tap the active order to see live status and the delivery code.'),
  ('Can I order from more than one restaurant?', 'Yes — your cart groups items by vendor and delivers them together.'),
  ('How do refunds work?', 'Contact support with your order number and we\'ll sort it out within 24 hours.'),
];

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppScreenHeader(title: 'Help & support'),
      body: AppScreenBody(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppListRow(icon: Icons.chat_bubble_outline_rounded, title: 'Chat with support', hint: 'Usually replies in minutes', onTap: () {}),
                  const Divider(height: 1, color: AppColors.line),
                  AppListRow(icon: Icons.call_outlined, title: 'Call us', hint: '+234 800 000 0000', onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionLabel(title: 'Frequently asked'),
            ..._faqs.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$1, style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(f.$2, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
