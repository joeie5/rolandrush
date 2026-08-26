import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../dashboard/rider_status_provider.dart';

/// Ports VehicleDetails.tsx. `rider_profiles` only has `vehicle_type`, not
/// make/model/plate/colour/year — those fields shown in the React mock
/// have no backing columns, so only vehicle type is real; the rest is
/// flagged rather than fabricated.
class VehicleDetailsScreen extends ConsumerWidget {
  const VehicleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(riderStatusProvider).valueOrNull;
    final verified = profile?.verificationStatus == 'verified';

    return AppScreen(
      title: 'Vehicle',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Row(
              children: [
                Container(height: 64, width: 64, decoration: BoxDecoration(color: AppColors.coralSoft, borderRadius: BorderRadius.circular(AppRadius.btn)), child: const Icon(Icons.two_wheeler_rounded, color: AppColors.coral, size: 34)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(profile?.vehicleType ?? 'Not set', style: AppTheme.sans(size: 22, weight: FontWeight.w800, letterSpacing: -0.6)),
                      Row(children: [
                        Icon(verified ? Icons.check_circle_rounded : Icons.hourglass_bottom_rounded, size: 16, color: verified ? AppColors.online : AppColors.alert),
                        const SizedBox(width: 4),
                        Text(verified ? 'Approved for delivery' : 'Pending approval', style: AppTheme.sans(size: 15, weight: FontWeight.w700, color: verified ? AppColors.online : AppColors.alert)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _field('Vehicle type', profile?.vehicleType ?? '—'),
          const SizedBox(height: 10),
          _field('Verification status', profile?.verificationStatus ?? '—'),
          const SizedBox(height: 18),
          AppButton(variant: AppButtonVariant.secondary, onPressed: () {}, child: const Text('Request a change')),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
          Text(value, style: AppTheme.sans(size: 19, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
