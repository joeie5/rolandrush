import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../dashboard/rider_status_provider.dart';

/// Ports Documents.tsx. `rider_profiles` has no per-document columns
/// (licence/NIN/vehicle-reg/insurance/photo) — only the single overall
/// `verification_status` field exists. No file storage infrastructure
/// exists for rider documents either (the only presigned-upload Edge
/// Function, `generate-upload-url`, is vendor-only, gated to
/// vendor_profiles/menu media). So this shows the one real status the
/// schema has, plus a picker-only "re-upload" affordance that previews a
/// local filename but doesn't persist anywhere — same gap noted on the
/// Signup screen. Real per-document tracking is a backend follow-up.
class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(riderStatusProvider).valueOrNull;
    final status = profile?.verificationStatus ?? 'pending';
    final verified = status == 'verified';
    final rejected = status == 'rejected';

    return AppScreen(
      title: 'Documents',
      subtitle: 'Keep these valid to stay online',
      onBack: () => context.pop(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Row(
              children: [
                Container(height: 48, width: 48, decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(AppRadius.btn)), child: const Icon(Icons.description_outlined)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Overall verification', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: verified ? AppColors.onlineSoft : (rejected ? AppColors.coralSoft : AppColors.alertSoft), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: verified ? AppColors.online : (rejected ? AppColors.coral : AppColors.alert)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Per-document tracking (licence, NIN, vehicle registration, insurance, photo) isn\'t in the database yet — only one overall status exists.',
              style: AppTheme.sans(size: 14, weight: FontWeight.w600, color: AppColors.inkFaint),
            ),
          ),
          if (!verified) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.btn), border: Border.all(color: AppColors.line, width: 2)),
              child: const Center(child: Text('Re-upload document', style: TextStyle(fontWeight: FontWeight.w800))),
            ),
          ],
        ],
      ),
    );
  }
}
