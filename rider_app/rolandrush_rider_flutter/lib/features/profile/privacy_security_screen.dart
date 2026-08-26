import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/row_tile.dart';
import '../../widgets/switch_row.dart';

/// Ports PrivacySecurity.tsx. All the toggles/rows here (PIN, fingerprint
/// unlock, location-sharing preferences, trip history retention, data
/// export/delete) have no backing columns anywhere in the schema — same
/// as NotificationSettings, kept as local-state-only UI.
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Privacy & security',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Sign in'),
          const RowTile(label: 'Change PIN', value: 'Last updated Jun 2026', icon: Icons.key_outlined),
          const SizedBox(height: 10),
          const SwitchRow(label: 'Fingerprint unlock', description: 'Open the app without a PIN'),
          const SizedBox(height: 24),
          _section('Location'),
          const SwitchRow(label: 'Share location while online', description: 'Required to receive jobs'),
          const SizedBox(height: 10),
          const SwitchRow(label: 'Share location while offline', description: 'Off by default', defaultOn: false),
          const SizedBox(height: 10),
          const RowTile(label: 'Trip location history', value: 'Kept for 90 days', icon: Icons.location_on_outlined),
          const SizedBox(height: 24),
          _section('Your data'),
          const RowTile(label: 'Download my data', icon: Icons.fingerprint_rounded),
          const SizedBox(height: 10),
          const RowTile(label: 'Delete account', icon: Icons.delete_outline_rounded, tone: RowTone.coral),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t.toUpperCase(), style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
      );
}
