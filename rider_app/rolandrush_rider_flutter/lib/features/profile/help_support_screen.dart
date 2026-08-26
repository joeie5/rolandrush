import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/row_tile.dart';

/// Ports HelpSupport.tsx. Uses the same rider support line the React mock
/// hardcoded (+2348001234567) — no ticketing/chat backend exists, so this
/// stays a plain tel: link rather than a fake in-app support flow.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _supportPhone = '+2348001234567';

  static const _topics = [
    ('Problem with an order', 'Wrong items, waiting too long', Icons.two_wheeler_rounded),
    ('Payment or payout issue', 'Missing earnings, failed withdrawal', Icons.account_balance_wallet_outlined),
    ('Account & documents', 'Verification, licence updates', Icons.chat_bubble_outline_rounded),
  ];

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: _supportPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Help & support',
      onBack: () => context.pop(),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: _call,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Row(
                children: [
                  Container(height: 56, width: 56, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)), child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Emergency help', style: AppTheme.sans(size: 22, weight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                        Text('Accident, theft or unsafe situation', style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _call,
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Call rider support'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(72), side: const BorderSide(color: AppColors.line, width: 2), foregroundColor: AppColors.ink, textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft, child: Text('COMMON TOPICS', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4))),
          const SizedBox(height: 10),
          ..._topics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RowTile(label: t.$1, value: t.$2, icon: t.$3),
              )),
          const SizedBox(height: 8),
          Text('Support hours: 7am – 11pm daily · Osogbo hub', textAlign: TextAlign.center, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkFaint)),
        ],
      ),
    );
  }
}
