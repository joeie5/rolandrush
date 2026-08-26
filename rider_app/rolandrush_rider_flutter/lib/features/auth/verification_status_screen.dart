import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';

/// Ports VerificationStatus.tsx — real check against
/// `rider_profiles.verification_status` on refresh instead of the mock's
/// local toggle.
class VerificationStatusScreen extends ConsumerStatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  ConsumerState<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends ConsumerState<VerificationStatusScreen> {
  bool checking = false;
  bool approved = false;

  Future<void> _refresh() async {
    setState(() => checking = true);
    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      final row = await SupabaseService.client.from('rider_profiles').select('verification_status').eq('user_id', userId).maybeSingle();
      if (mounted) setState(() => approved = row?['verification_status'] == 'verified');
    }
    if (mounted) setState(() => checking = false);
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  static const _checks = ['Personal details', "Driver's licence", 'NIN verification', 'Payout account'];

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(color: approved ? AppColors.online : AppColors.alertSoft, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: approved ? Colors.white.withOpacity(0.2) : AppColors.alert),
                    child: Icon(approved ? Icons.check_rounded : Icons.access_time_rounded, size: approved ? 44 : 40, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(approved ? "You're approved!" : 'Under review',
                      style: AppTheme.sans(size: 30, weight: FontWeight.w800, color: approved ? Colors.white : AppColors.ink, letterSpacing: -0.8)),
                  const SizedBox(height: 8),
                  Text(
                    approved ? 'Go online and start accepting jobs in Osogbo.' : "We usually approve riders within 24 hours. We'll text you.",
                    textAlign: TextAlign.center,
                    style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: approved ? Colors.white.withOpacity(0.85) : AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._checks.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                    child: Row(
                      children: [
                        Container(
                          height: 36,
                          width: 36,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.onlineSoft),
                          child: const Icon(Icons.check_rounded, color: AppColors.online, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(c, style: AppTheme.sans(size: 17, weight: FontWeight.w700))),
                        Text('Done', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.online)),
                      ],
                    ),
                  ),
                )),
            const Spacer(),
            if (approved)
              AppButton(size: AppButtonSize.xl, variant: AppButtonVariant.success, onPressed: () => context.go('/home'), child: const Text('Start riding'))
            else ...[
              AppButton(
                size: AppButtonSize.xl,
                onPressed: checking ? null : _refresh,
                child: checking
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Refresh status'),
              ),
              const SizedBox(height: 8),
              AppButton(size: AppButtonSize.md, variant: AppButtonVariant.ghost, onPressed: () => context.push('/profile/support'), child: const Text('Contact support')),
            ],
          ],
        ),
      ),
    );
  }
}
