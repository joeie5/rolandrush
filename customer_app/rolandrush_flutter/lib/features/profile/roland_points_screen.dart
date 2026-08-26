import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/primitives.dart';

/// No `loyalty_points` / `points_transactions` table exists yet (see
/// ROLANDRUSH_CONSOLIDATED_BRIEF.md schema-gap notes) — this is the visual
/// shell, honestly showing zero rather than fabricating a balance.
class RolandPointsScreen extends StatelessWidget {
  const RolandPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppScreenHeader(title: 'RolandPoints'),
      body: AppScreenBody(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.coral, AppColors.coral700]),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your balance', style: AppTheme.sans(size: 12, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 6),
                  Text('0 pts', style: AppTheme.display(size: 32, weight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Earn 1 point per ₦100 spent', style: AppTheme.sans(size: 12, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionLabel(title: 'Activity'),
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 32, color: AppColors.ink35),
                  const SizedBox(height: 12),
                  Text('Points tracking is coming soon',
                      textAlign: TextAlign.center, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Place orders once this is wired up to start earning.',
                      textAlign: TextAlign.center, style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
