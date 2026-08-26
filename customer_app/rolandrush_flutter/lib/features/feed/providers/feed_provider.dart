import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/menu_item.dart';

const _pageSize = 8;

class FeedState {
  final List<MenuItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Set<String> likedItemIds; // client-side only until an engagement table exists
  final Set<String> followedVendorIds;
  final String? error;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.likedItemIds = const {},
    this.followedVendorIds = const {},
    this.error,
  });

  FeedState copyWith({
    List<MenuItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Set<String>? likedItemIds,
    Set<String>? followedVendorIds,
    String? error,
  }) {
    return FeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      likedItemIds: likedItemIds ?? this.likedItemIds,
      followedVendorIds: followedVendorIds ?? this.followedVendorIds,
      error: error,
    );
  }
}

/// Drives the vertical feed. Pulls from `menu_items` joined with
/// `vendor_profiles`, video-capable items only, sponsored vendors
/// interleaved every 3 posts (mirrors insertSponsoredContent() from the
/// Figma prototype, but driven by vendor_profiles.is_sponsored /
/// bid_amount instead of a separate mock ad list).
class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState()) {
    loadInitial();
  }

  int _offset = 0;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _fetchPage(offset: 0);
      _offset = items.length;
      state = state.copyWith(
        items: _interleaveSponsored(items),
        isLoading: false,
        hasMore: items.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final items = await _fetchPage(offset: _offset);
      _offset += items.length;
      state = state.copyWith(
        items: [...state.items, ..._interleaveSponsored(items)],
        isLoadingMore: false,
        hasMore: items.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    _offset = 0;
    await loadInitial();
  }

  Future<List<MenuItem>> _fetchPage({required int offset}) async {
    // vendor_profiles!inner() so the verification_status filter on the
    // embedded relation actually restricts rows (a plain embed can't be
    // filtered — Postgrest requires the inner-join form for that).
    final res = await SupabaseService.client
        .from('menu_items')
        .select('*, vendor_profiles!inner(restaurant_name, logo_url, rating, is_sponsored, verification_status)')
        .eq('is_available', true)
        .eq('vendor_profiles.verification_status', 'verified')
        .not('video_url', 'is', null)
        .order('created_at', ascending: false)
        .range(offset, offset + _pageSize - 1);

    return (res as List)
        .map((row) => MenuItem.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  List<MenuItem> _interleaveSponsored(List<MenuItem> items) {
    // Placeholder pass-through — real weighting by vendor bid_amount can be
    // added once ad campaign tracking (impressions/clicks/spend) exists.
    // For now, sponsored vendor items simply surface naturally since the
    // query already includes vendor_profiles.is_sponsored on each card,
    // which the UI uses to render the shimmer border.
    return items;
  }

  void toggleLike(String menuItemId) {
    final liked = {...state.likedItemIds};
    liked.contains(menuItemId) ? liked.remove(menuItemId) : liked.add(menuItemId);
    state = state.copyWith(likedItemIds: liked);
    // TODO: persist once a menu_item_likes / engagement table exists.
  }

  void toggleFollow(String vendorId) {
    final followed = {...state.followedVendorIds};
    followed.contains(vendorId) ? followed.remove(vendorId) : followed.add(vendorId);
    state = state.copyWith(followedVendorIds: followed);
    // TODO: persist once a vendor_follows table exists.
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);

/// Tracks which page index is currently on-screen so the feed widget
/// knows which single video controller to keep playing.
final currentFeedIndexProvider = StateProvider<int>((ref) => 0);
