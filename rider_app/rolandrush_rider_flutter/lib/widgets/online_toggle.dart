import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../features/dashboard/rider_status_provider.dart';

/// Ports components/OnlineToggle.tsx, wired to rider_profiles.is_online.
class OnlineToggle extends ConsumerWidget {
  const OnlineToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(riderStatusProvider).valueOrNull;
    final isOnline = profile?.isOnline ?? false;

    return Material(
      color: isOnline ? AppColors.online : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: profile == null ? null : () => ref.read(riderStatusProvider.notifier).setOnline(!isOnline),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: isOnline ? null : Border.all(color: AppColors.line, width: 2),
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isOnline ? Colors.white.withOpacity(0.2) : AppColors.canvas),
                child: Icon(Icons.power_settings_new_rounded, color: isOnline ? Colors.white : AppColors.inkFaint, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isOnline ? "You're online" : "You're offline",
                        style: AppTheme.sans(size: 27, weight: FontWeight.w800, color: isOnline ? Colors.white : AppColors.ink, letterSpacing: -0.8)),
                    Text(
                      isOnline ? 'Tap to stop receiving jobs' : 'Tap to start receiving jobs',
                      style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: isOnline ? Colors.white.withOpacity(0.85) : AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isOnline,
                onChanged: profile == null ? null : (v) => ref.read(riderStatusProvider.notifier).setOnline(v),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
