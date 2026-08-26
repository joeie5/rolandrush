import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/error_view.dart';
import '../cart/providers/cart_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/content_report_provider.dart';
import 'widgets/add_ons_sheet.dart';
import 'widgets/feed_video_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  final void Function(String vendorId) onVendorTap;

  const FeedScreen({super.key, required this.onVendorTap});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _pageController = PageController();
  int _tab = 1; // 0 = Following, 1 = For you

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(currentFeedIndexProvider.notifier).state = index;
    final feed = ref.read(feedProvider);
    // Load more when 2 items from the end, mirrors the React
    // infinite-scroll trigger (scrollTop + clientHeight near scrollHeight).
    if (index >= feed.items.length - 2) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  Future<void> _openAddOns(BuildContext context, WidgetRef ref, item) async {
    final cart = ref.read(cartProvider.notifier);
    final existing = cart.forMenuItem(item.id);

    final result = await showModalBottomSheet<({int quantity, List addOns})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddOnsSheet(
        item: item,
        initialQuantity: existing?.quantity ?? 1,
        initialSelection: existing?.selectedAddOns ?? const [],
      ),
    );

    if (result != null) {
      cart.addOrUpdate(item, quantity: result.quantity, addOns: result.addOns.cast());
    }
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Comments', style: AppTheme.display(size: 16, weight: FontWeight.w800)),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Comments aren\'t wired up yet — needs a menu_item_engagement table.',
                    textAlign: TextAlign.center,
                    style: AppTheme.sans(size: 13, color: AppColors.ink35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openShare(BuildContext context) {
    const targets = [
      ('WhatsApp', Icons.chat_bubble_rounded, Color(0xFF25D366)),
      ('Instagram', Icons.camera_alt_rounded, Color(0xFFE1306C)),
      ('X', Icons.close_rounded, Color(0xFF111111)),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share this dish', style: AppTheme.display(size: 16, weight: FontWeight.w800)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: targets
                    .map((t) => Column(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: t.$3, shape: BoxShape.circle),
                              child: Icon(t.$2, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 6),
                            Text(t.$1, style: AppTheme.sans(size: 12, color: AppColors.ink50)),
                          ],
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReport(BuildContext context, WidgetRef ref, String menuItemId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report this dish', style: AppTheme.display(size: 16, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Tell us what\'s wrong with this listing.', style: AppTheme.sans(size: 13, color: AppColors.ink50)),
              const SizedBox(height: 16),
              for (final reason in reportReasons)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(reason, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final ok = await ref.read(contentReportProvider).reportMenuItem(menuItemId: menuItemId, reason: reason);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Report submitted — thanks for flagging this.' : 'Could not submit report.')),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final cartItems = ref.watch(cartProvider);
    final cartCount = ref.watch(cartCountProvider);

    Widget body;
    if (feed.isLoading && feed.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (feed.error != null && feed.items.isEmpty) {
      body = AppErrorView(
        error: feed.error!,
        dark: true,
        onRetry: () => ref.read(feedProvider.notifier).refresh(),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: _onPageChanged,
          itemCount: feed.items.length,
          itemBuilder: (context, index) {
            final item = feed.items[index];
            final currentIndex = ref.watch(currentFeedIndexProvider);
            final cartQty = cartItems
                .where((c) => c.menuItemId == item.id)
                .fold(0, (sum, c) => sum + c.quantity);

            return FeedVideoCard(
              item: item,
              isActive: index == currentIndex,
              isLiked: feed.likedItemIds.contains(item.id),
              isFollowing: feed.followedVendorIds.contains(item.vendorId),
              cartQuantity: cartQty,
              onLike: () => ref.read(feedProvider.notifier).toggleLike(item.id),
              onFollow: () => ref.read(feedProvider.notifier).toggleFollow(item.vendorId),
              onComment: () => _openComments(context),
              onShare: () => _openShare(context),
              onAddToCart: () => _openAddOns(context, ref, item),
              onVendorTap: () => widget.onVendorTap(item.vendorId),
              onFullMenu: () => context.push('/restaurant/${item.vendorId}'),
              onReport: () => _openReport(context, ref, item.id),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xA6000000), Colors.transparent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Osogbo', style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
                          const Icon(Icons.expand_more_rounded, size: 16, color: Colors.white70),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _tabButton('Following', 0),
                          const SizedBox(width: 20),
                          _tabButton('For you', 1),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/cart'),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                            if (cartCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  alignment: Alignment.center,
                                  child: Text('$cartCount', style: AppTheme.display(size: 10, weight: FontWeight.w800, color: Colors.white)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: AppBottomNav(currentPath: '/feed', dark: true)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTheme.display(size: 15, weight: FontWeight.w800, color: active ? Colors.white : Colors.white.withOpacity(0.5))),
          const SizedBox(height: 4),
          Container(width: 20, height: 2.5, decoration: BoxDecoration(color: active ? AppColors.coral : Colors.transparent, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }
}
