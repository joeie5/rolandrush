import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';

class VendorNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const VendorNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory VendorNotification.fromSupabase(Map<String, dynamic> row) => VendorNotification(
        id: row['id'] as String,
        title: row['title'] as String? ?? '',
        message: row['message'] as String? ?? '',
        isRead: row['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}

/// No `notifications` table exists on the Partner project (per
/// ROLANDRUSH_CONSOLIDATED_BRIEF.md — RLS/schema-gap notes were written
/// against RolandRushApp's notifications table, not this project's). Reads
/// return empty gracefully rather than erroring until one is added.
final vendorNotificationsProvider = FutureProvider<List<VendorNotification>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  try {
    final res = await SupabaseService.client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (res as List).map((r) => VendorNotification.fromSupabase(r as Map<String, dynamic>)).toList();
  } catch (_) {
    return [];
  }
});

final vendorUnreadCountProvider = Provider<int>((ref) {
  final async = ref.watch(vendorNotificationsProvider);
  return async.maybeWhen(data: (list) => list.where((n) => !n.isRead).length, orElse: () => 0);
});
