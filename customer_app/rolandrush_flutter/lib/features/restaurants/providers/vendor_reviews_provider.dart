import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';

class VendorReview {
  final int rating;
  final String? comment;
  const VendorReview({required this.rating, this.comment});

  factory VendorReview.fromSupabase(Map<String, dynamic> row) =>
      VendorReview(rating: row['rating'] as int, comment: row['comment'] as String?);
}

final vendorReviewsProvider = FutureProvider.family<List<VendorReview>, String>((ref, vendorId) async {
  final res = await SupabaseService.client.from('vendor_reviews').select().eq('vendor_id', vendorId);
  return (res as List).map((r) => VendorReview.fromSupabase(r as Map<String, dynamic>)).toList();
});
