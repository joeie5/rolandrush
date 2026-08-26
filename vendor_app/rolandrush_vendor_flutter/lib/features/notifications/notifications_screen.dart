import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/error_view.dart';
import 'providers/vendor_notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vendorNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppScreenHeader(title: 'Notifications', onBack: () => context.pop()),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No notifications yet.\nOrders and account alerts will land here.', textAlign: TextAlign.center, style: AppTheme.sans(size: 14, color: AppColors.inkMuted)),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = list[i];
              return AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: BoxDecoration(color: n.isRead ? Colors.transparent : AppColors.coral, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(n.message, style: AppTheme.sans(size: 13, color: AppColors.inkMuted)),
                          const SizedBox(height: 4),
                          Text(relativeTime(n.createdAt), style: AppTheme.sans(size: 11, color: AppColors.inkSubtle)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(vendorNotificationsProvider)),
      ),
    );
  }
}
