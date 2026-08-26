import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_screen.dart';
import '../dashboard/providers/vendor_session_provider.dart';
import '../orders/providers/vendor_orders_provider.dart';
import '../menu/providers/menu_manager_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorId = ref.watch(vendorSessionProvider)?.id ?? '';
    final orders = vendorId.isEmpty ? const <dynamic>[] : ref.watch(vendorOrdersProvider(vendorId)).orders;
    final menu = vendorId.isEmpty ? const <dynamic>[] : ref.watch(menuManagerProvider(vendorId)).items;

    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dailyTotals = days.map((d) {
      return orders.where((o) => o.createdAt.year == d.year && o.createdAt.month == d.month && o.createdAt.day == d.day).fold<double>(0, (s, o) => s + o.totalAmount);
    }).toList();
    final maxVal = dailyTotals.isEmpty ? 1.0 : (dailyTotals.reduce((a, b) => a > b ? a : b)).clamp(1, double.infinity);
    final totalRevenue = dailyTotals.fold<double>(0, (s, v) => s + v);

    final itemCounts = <String, int>{};
    for (final o in orders) {
      for (final line in o.items) {
        itemCounts[line.name] = (itemCounts[line.name] ?? 0) + (line.quantity as int);
      }
    }
    final topItems = itemCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppScreenHeader(title: 'Insights', subtitle: 'Last 7 days', onBack: () => context.pop()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REVENUE', style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                Text(naira(totalRevenue), style: AppTheme.num(size: 36, weight: FontWeight.w800)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxVal * 1.2,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final i = v.toInt();
                              if (i < 0 || i >= days.length) return const SizedBox.shrink();
                              const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              return Padding(padding: const EdgeInsets.only(top: 6), child: Text(labels[days[i].weekday - 1], style: AppTheme.sans(size: 10, weight: FontWeight.w600, color: AppColors.inkSubtle)));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(dailyTotals.length, (i) {
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(toY: dailyTotals[i], color: AppColors.coral, width: 18, borderRadius: BorderRadius.circular(4)),
                        ]);
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Top sellers', style: AppTheme.num(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (topItems.isEmpty)
            AppCard(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('No sales data yet', style: AppTheme.sans(size: 13, color: AppColors.inkMuted))))
          else
            AppCard(
              flush: true,
              child: Column(
                children: [
                  for (var i = 0; i < topItems.take(5).length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text('${i + 1}', style: AppTheme.num(size: 13, weight: FontWeight.w800, color: AppColors.inkSubtle)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(topItems[i].key, style: AppTheme.sans(size: 14, weight: FontWeight.w600))),
                          Text('${topItems[i].value} sold', style: AppTheme.num(size: 13, weight: FontWeight.w700, color: AppColors.inkMuted)),
                        ],
                      ),
                    ),
                    if (i != topItems.take(5).length - 1) const Divider(height: 1, color: AppColors.line),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu_rounded, size: 18, color: AppColors.inkMuted),
                const SizedBox(width: 10),
                Expanded(child: Text('${menu.length} menu items · ${menu.where((i) => !(i.isAvailable as bool)).length} sold out', style: AppTheme.sans(size: 13, color: AppColors.inkMuted))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
