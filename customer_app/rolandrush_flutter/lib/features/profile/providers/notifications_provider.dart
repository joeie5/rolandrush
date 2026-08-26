import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/app_notification.dart';

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  final res = await SupabaseService.client
      .from('notifications')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  return (res as List).map((r) => AppNotification.fromSupabase(r as Map<String, dynamic>)).toList();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(notificationsProvider.future);
  return list.where((n) => !n.isRead).length;
});

Future<void> markNotificationRead(String id) async {
  await SupabaseService.client.from('notifications').update({'is_read': true}).eq('id', id);
}
