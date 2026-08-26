import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/switch_row.dart';

/// Ports NotificationSettings.tsx.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Notifications',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('While online'),
          const SwitchRow(label: 'New job alerts', description: 'Loud sound + vibration'),
          const SizedBox(height: 10),
          const SwitchRow(label: 'High-pay job alerts', description: 'Jobs over ₦3,000'),
          const SizedBox(height: 10),
          const SwitchRow(label: 'Read alerts aloud', description: 'Hands-free while riding', defaultOn: false),
          const SizedBox(height: 24),
          _section('Money'),
          const SwitchRow(label: 'Payout confirmations'),
          const SizedBox(height: 10),
          const SwitchRow(label: 'Weekly earnings summary'),
          const SizedBox(height: 10),
          const SwitchRow(label: 'Bonus & incentive offers', defaultOn: false),
          const SizedBox(height: 24),
          _section('Other'),
          const SwitchRow(label: 'Customer messages'),
          const SizedBox(height: 10),
          const SwitchRow(label: 'RolandRush news', defaultOn: false),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t.toUpperCase(), style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
      );
}
