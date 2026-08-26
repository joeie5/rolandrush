import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/job_card.dart';
import '../dashboard/rider_status_provider.dart';
import 'providers/available_orders_provider.dart';

/// Ports Jobs.tsx.
class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(riderStatusProvider).valueOrNull;
    final isOnline = profile?.isOnline ?? false;
    final state = ref.watch(availableOrdersProvider);
    final notifier = ref.read(availableOrdersProvider.notifier);
    final visible = state.filtered;

    return AppScreen(
      nav: true,
      navPath: '/jobs',
      title: 'Available orders',
      subtitle: '${visible.length} ready for pickup',
      child: !isOnline
          ? Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                child: Column(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.canvas),
                      child: const Icon(Icons.power_settings_new_rounded, color: AppColors.inkFaint, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text("You're offline", style: AppTheme.sans(size: 24, weight: FontWeight.w800, letterSpacing: -0.6)),
                    const SizedBox(height: 4),
                    Text('Go online to see orders around Osogbo.', style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: AppColors.inkMuted)),
                    const SizedBox(height: 24),
                    AppButton(
                      variant: AppButtonVariant.success,
                      fullWidth: false,
                      onPressed: profile == null ? null : () => ref.read(riderStatusProvider.notifier).setOnline(true),
                      child: const Text('Go online'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    for (final f in OrderFilter.values)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.btn),
                            onTap: () => notifier.setFilter(f),
                            child: Container(
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: state.filter == f ? AppColors.ink : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.btn),
                              ),
                              child: Text(_filterLabel(f), style: AppTheme.sans(size: 16, weight: FontWeight.w800, color: state.filter == f ? Colors.white : AppColors.inkMuted)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.isLoading) const Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator()),
                if (!state.isLoading && visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text('No orders match this filter yet.', style: AppTheme.sans(size: 18, weight: FontWeight.w700, color: AppColors.inkMuted)),
                  ),
                ...visible.map((job) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: JobCard(
                        order: job,
                        onAccept: () async {
                          if (profile == null) return;
                          final ok = await notifier.acceptOrder(job.id, profile.id);
                          if (!mounted) return;
                          if (ok) {
                            context.push('/delivery/active');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Another rider already took this one.')));
                          }
                        },
                      ),
                    )),
              ],
            ),
    );
  }

  String _filterLabel(OrderFilter f) => switch (f) { OrderFilter.all => 'All', OrderFilter.nearby => 'Nearby', OrderFilter.highPay => 'High-Pay' };
}
