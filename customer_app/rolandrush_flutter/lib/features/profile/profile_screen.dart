import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import '../../widgets/primitives.dart';
import '../../widgets/bottom_nav.dart';
import 'providers/customer_profile_provider.dart';
import 'providers/addresses_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/notifications_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(customerProfileProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final favourites = ref.watch(favouritesProvider);
    final unreadAsync = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                Text('Profile', style: AppTheme.display(size: 26, weight: FontWeight.w800)),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InitialsAvatar(name: profileAsync.value?.displayName.isNotEmpty == true ? profileAsync.value!.displayName : 'RolandRush', color: const Color(0xFFC2410C), size: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileAsync.value?.displayName.isNotEmpty == true ? profileAsync.value!.displayName : 'Complete your profile',
                              style: AppTheme.display(size: 17, weight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(profileAsync.value?.phone ?? '—', style: AppTheme.sans(size: 13, color: AppColors.ink35)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/profile/personal'),
                        child: Text('Edit', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/membership'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.card)),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: const Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RushPass', style: AppTheme.display(size: 15, weight: FontWeight.w800, color: Colors.white)),
                              Text('Membership perks & benefits', style: AppTheme.sans(size: 12, color: Colors.white.withOpacity(0.6))),
                            ],
                          ),
                        ),
                        Text('Manage', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/points'),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.coralSoft, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.coral, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RolandPoints', style: AppTheme.display(size: 15, weight: FontWeight.w800)),
                              Text('Earn points on every order', style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                            ],
                          ),
                        ),
                        Text('View', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionLabel(title: 'Account'),
                AppCard(
                  child: Column(
                    children: [
                      AppListRow(icon: Icons.person_outline_rounded, title: 'Personal information', hint: 'Name, phone, email', onTap: () => context.push('/profile/personal')),
                      const Divider(height: 1, color: AppColors.line),
                      AppListRow(
                        icon: Icons.location_on_outlined,
                        title: 'Saved addresses',
                        hint: addressesAsync.maybeWhen(data: (a) => '${a.length} saved', orElse: () => null),
                        onTap: () => context.push('/profile/addresses'),
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      AppListRow(icon: Icons.credit_card_outlined, title: 'Payment methods', onTap: () => context.push('/profile/payments')),
                      const Divider(height: 1, color: AppColors.line),
                      AppListRow(icon: Icons.favorite_border_rounded, title: 'Favourite restaurants', hint: '${favourites.length} vendors', onTap: () => context.push('/profile/favourites')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionLabel(title: 'Preferences'),
                AppCard(
                  child: Column(
                    children: [
                      AppListRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications inbox',
                        hint: unreadAsync.maybeWhen(data: (n) => n > 0 ? '$n unread' : null, orElse: () => null),
                        onTap: () => context.push('/notifications'),
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      AppListRow(icon: Icons.tune_rounded, title: 'Notification preferences', hint: 'Push, email and SMS', onTap: () => context.push('/profile/notifications')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionLabel(title: 'Support'),
                AppCard(
                  child: Column(
                    children: [
                      AppListRow(icon: Icons.help_outline_rounded, title: 'Help & support', hint: 'Chat with us, FAQs', onTap: () => context.push('/help')),
                      const Divider(height: 1, color: AppColors.line),
                      AppListRow(
                        icon: Icons.logout_rounded,
                        title: 'Log out',
                        danger: true,
                        onTap: () async {
                          await SupabaseService.client.auth.signOut();
                          if (context.mounted) context.go('/');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: Text('RolandRush v3.0 · Osogbo, Osun State', style: AppTheme.sans(size: 12, color: AppColors.ink35))),
              ],
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: AppBottomNav(currentPath: '/profile')),
        ],
      ),
    );
  }
}
