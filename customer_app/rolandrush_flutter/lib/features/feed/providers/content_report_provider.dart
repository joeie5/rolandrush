import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';

class ContentReportNotifier {
  Future<bool> reportMenuItem({required String menuItemId, required String reason}) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return false;
    try {
      await SupabaseService.client.from('content_reports').insert({
        'reporter_user_id': userId,
        'content_type': 'menu_item',
        'content_id': menuItemId,
        'reason': reason,
        'status': 'pending',
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

final contentReportProvider = Provider((ref) => ContentReportNotifier());

const reportReasons = [
  'Inappropriate content',
  'Misleading listing',
  'Spam',
  'Wrong price or info',
  'Other',
];
