import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/row_tile.dart';
import '../dashboard/rider_status_provider.dart';

/// Ports Profile.tsx off the real signed-in rider's profile + rating.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(riderStatusProvider).valueOrNull;
    final rating = ref.watch(riderRatingProvider).valueOrNull;
    final isOnline = profile?.isOnline ?? false;
    final initials = profile == null
        ? 'R'
        : [profile.firstName, profile.lastName].where((s) => s != null && s.isNotEmpty).map((s) => s![0]).join();

    return AppScreen(
      nav: true,
      navPath: '/profile',
      title: 'Account',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.coral),
                  child: Center(child: Text(initials, style: AppTheme.sans(size: 24, weight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(profile?.fullName ?? 'Rider', style: AppTheme.sans(size: 22, weight: FontWeight.w800, letterSpacing: -0.6), overflow: TextOverflow.ellipsis),
                      Text(profile?.phoneNumber ?? '', style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: AppColors.inkMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: isOnline ? AppColors.onlineSoft : AppColors.canvas, borderRadius: BorderRadius.circular(6)),
                  child: Text(isOnline ? 'ONLINE' : 'OFFLINE', style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: isOnline ? AppColors.online : AppColors.inkFaint)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Row(
              children: [
                Expanded(
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                      if (rating != null && rating.$1 != null) const Icon(Icons.star_rounded, size: 18, color: AppColors.alert),
                      Text(rating == null || rating.$1 == null ? '—' : rating.$1!.toStringAsFixed(1), style: AppTheme.sans(size: 22, weight: FontWeight.w800, letterSpacing: -0.5)),
                    ]),
                    Text('RATING', style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
                  ]),
                ),
                Container(height: 32, width: 1, color: AppColors.line),
                Expanded(
                  child: Column(children: [
                    Text('${rating?.$2 ?? 0}', style: AppTheme.sans(size: 22, weight: FontWeight.w800, letterSpacing: -0.5)),
                    Text('DELIVERIES', style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
                  ]),
                ),
                Container(height: 32, width: 1, color: AppColors.line),
                Expanded(
                  child: Column(children: [
                    Text(profile?.createdAt == null ? '—' : '${profile!.createdAt!.year}', style: AppTheme.sans(size: 22, weight: FontWeight.w800, letterSpacing: -0.5)),
                    Text('SINCE', style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          RowTile(label: 'Vehicle details', value: profile?.vehicleType, icon: Icons.two_wheeler_rounded, onTap: () => context.push('/profile/vehicle')),
          const SizedBox(height: 10),
          RowTile(label: 'Documents', value: 'Verification status', icon: Icons.description_outlined, tone: RowTone.alert, onTap: () => context.push('/profile/documents')),
          const SizedBox(height: 10),
          RowTile(label: 'Bank account', icon: Icons.account_balance_outlined, onTap: () => context.push('/profile/bank')),
          const SizedBox(height: 10),
          RowTile(label: 'Notifications', icon: Icons.notifications_outlined, onTap: () => context.push('/profile/notifications')),
          const SizedBox(height: 10),
          RowTile(label: 'Help & support', icon: Icons.support_agent_outlined, onTap: () => context.push('/profile/support')),
          const SizedBox(height: 10),
          RowTile(label: 'Privacy & security', icon: Icons.shield_outlined, onTap: () => context.push('/profile/privacy')),
          const SizedBox(height: 18),
          AppButton(
            variant: AppButtonVariant.secondary,
            onPressed: () async {
              await SupabaseService.client.auth.signOut();
              if (context.mounted) context.go('/');
            },
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout_rounded), SizedBox(width: 8), Text('Log out')]),
          ),
        ],
      ),
    );
  }
}
