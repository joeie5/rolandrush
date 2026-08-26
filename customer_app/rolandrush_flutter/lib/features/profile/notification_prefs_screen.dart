import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/primitives.dart';

/// No `notification_preferences` table exists — local-only for now,
/// same pattern as favourites.
class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  bool push = true;
  bool email = false;
  bool sms = true;
  bool promotions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppScreenHeader(title: 'Notification preferences'),
      body: AppScreenBody(
        padding: const EdgeInsets.all(20),
        child: AppCard(
          child: Column(
            children: [
              _row('Push notifications', push, (v) => setState(() => push = v)),
              const Divider(height: 1, color: AppColors.line),
              _row('Email', email, (v) => setState(() => email = v)),
              const Divider(height: 1, color: AppColors.line),
              _row('SMS', sms, (v) => setState(() => sms = v)),
              const Divider(height: 1, color: AppColors.line),
              _row('Promotions & offers', promotions, (v) => setState(() => promotions = v)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTheme.sans(size: 14, weight: FontWeight.w600))),
          AppToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
