import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import 'providers/earnings_provider.dart';

/// Ports Earnings.tsx off real `transactions` rows instead of mock data.
/// "Distance"/"Online hours" stats from the mock have no backing columns
/// (no odometer or session-length tracking in the schema) — omitted
/// rather than fabricated; see earnings_provider.dart's doc comment.
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  EarningsRange range = EarningsRange.today;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);
    final totals = state.totalsFor(range);
    final bars = state.last7DaysBars;
    final maxBar = bars.isEmpty ? 1.0 : bars.reduce((a, b) => a > b ? a : b);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return AppScreen(
      nav: true,
      navPath: '/earnings',
      title: 'Earnings',
      subtitle: 'Osogbo zone',
      child: Column(
        children: [
          Row(
            children: EarningsRange.values.map((r) {
              final active = range == r;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                    onTap: () => setState(() => range = r),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: active ? AppColors.ink : AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.btn)),
                      child: Text(_rangeLabel(r), style: AppTheme.sans(size: 16, weight: FontWeight.w800, color: active ? Colors.white : AppColors.inkMuted)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(range == EarningsRange.today ? 'EARNED TODAY' : 'EARNED THIS ${_rangeLabel(range).toUpperCase()}',
                    style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
                Text(naira(totals.amount), style: AppTheme.sans(size: 46, weight: FontWeight.w800, color: AppColors.online, letterSpacing: -1.4)),
                if (range != EarningsRange.today) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(bars.length, (i) {
                        final isLast = i == bars.length - 1;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 90 * (maxBar == 0 ? 0 : bars[i] / maxBar),
                                  decoration: BoxDecoration(
                                    color: isLast ? AppColors.coral : AppColors.online,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(dayLabels[i], style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: AppColors.inkFaint)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(height: 1, color: AppColors.line),
                const SizedBox(height: 14),
                Row(children: [Expanded(child: _Metric(icon: Icons.inventory_2_outlined, label: 'Trips', value: '${totals.trips}'))]),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppButton(onPressed: () => context.push('/withdraw'), child: const Text('Withdraw to bank')),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('RECENT DELIVERIES', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
          ),
          const SizedBox(height: 10),
          if (state.recentDeliveries.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text('No completed deliveries yet.', style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: AppColors.inkFaint))),
          ...state.recentDeliveries.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(d.restaurantName, style: AppTheme.sans(size: 17, weight: FontWeight.w700)),
                            Text('${d.deliveryAddress ?? ''} · ${DateFormat('h:mm a').format(d.createdAt)}',
                                overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                      Text('+${naira(d.deliveryFee)}', style: AppTheme.sans(size: 20, weight: FontWeight.w800, color: AppColors.online, letterSpacing: -0.4)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  String _rangeLabel(EarningsRange r) => switch (r) { EarningsRange.today => 'Today', EarningsRange.week => 'Week', EarningsRange.month => 'Month' };
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Metric({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: AppColors.inkMuted),
          const SizedBox(width: 6),
          Text(value, style: AppTheme.sans(size: 21, weight: FontWeight.w800, letterSpacing: -0.4)),
        ]),
        Text(label.toUpperCase(), style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
      ],
    );
  }
}
