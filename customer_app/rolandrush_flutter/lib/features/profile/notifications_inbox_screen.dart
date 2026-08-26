import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/primitives.dart';
import '../../widgets/error_view.dart';
import 'providers/notifications_provider.dart';

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: const AppScreenHeader(title: 'Notifications'),
      body: notificationsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No notifications yet', style: AppTheme.sans(size: 14, color: AppColors.ink50)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final n = list[i];
              return GestureDetector(
                onTap: () async {
                  if (!n.isRead) {
                    await markNotificationRead(n.id);
                    ref.invalidate(notificationsProvider);
                  }
                },
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(color: n.isRead ? Colors.transparent : AppColors.coral, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: AppTheme.sans(size: 14, weight: n.isRead ? FontWeight.w600 : FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(n.message, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
                            const SizedBox(height: 6),
                            Text(DateFormat('MMM d, h:mm a').format(n.createdAt), style: AppTheme.sans(size: 11, color: AppColors.ink35)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(notificationsProvider)),
      ),
    );
  }
}
