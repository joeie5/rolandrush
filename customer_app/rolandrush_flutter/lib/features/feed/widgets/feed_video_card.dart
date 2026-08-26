import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme.dart';
import '../../../core/format.dart';
import '../../../models/menu_item.dart';
import '../../../widgets/primitives.dart';

/// One full-screen feed post, ported 1:1 from the Magic Patterns
/// FeedPost.tsx + ActionRail.tsx design. Only ever instantiated for the
/// page that's current, ±1 neighbor (PageView keeps a small window alive)
/// — video playback is started/stopped by [isActive], driven by the
/// parent's PageView onPageChanged, not by widget lifecycle alone.
class FeedVideoCard extends StatefulWidget {
  final MenuItem item;
  final bool isActive;
  final bool isLiked;
  final bool isFollowing;
  final int cartQuantity;
  final VoidCallback onLike;
  final VoidCallback onFollow;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onAddToCart;
  final VoidCallback onVendorTap;
  final VoidCallback onFullMenu;
  final VoidCallback onReport;

  const FeedVideoCard({
    super.key,
    required this.item,
    required this.isActive,
    required this.isLiked,
    required this.isFollowing,
    required this.cartQuantity,
    required this.onLike,
    required this.onFollow,
    required this.onComment,
    required this.onShare,
    required this.onAddToCart,
    required this.onVendorTap,
    required this.onFullMenu,
    required this.onReport,
  });

  @override
  State<FeedVideoCard> createState() => _FeedVideoCardState();
}

class _FeedVideoCardState extends State<FeedVideoCard> {
  VideoPlayerController? _controller;
  bool _showHeart = false;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    if (widget.item.hasVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.item.videoUrl!))
        ..setLooping(true)
        ..initialize().then((_) {
          if (mounted && widget.isActive) _controller!.play();
          setState(() {});
        });
    }
  }

  @override
  void didUpdateWidget(covariant FeedVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive && _controller != null) {
      widget.isActive ? _controller!.play() : _controller!.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < const Duration(milliseconds: 300)) {
      if (!widget.isLiked) widget.onLike();
      setState(() => _showHeart = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _showHeart = false);
      });
    }
    _lastTap = now;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(item),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xD9000000), Color(0x1A000000), Color(0x73000000)],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          if (item.vendorIsSponsored) _buildSponsoredBorder(),
          AnimatedOpacity(
            opacity: _showHeart ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: const Center(
              child: Icon(Icons.favorite_rounded, color: AppColors.coral, size: 110),
            ),
          ),
          Positioned(
            left: 16,
            right: 96,
            bottom: 104,
            child: _buildInfoOverlay(item),
          ),
          Positioned(right: 12, bottom: 108, child: _buildActionRail(item)),
        ],
      ),
    );
  }

  Widget _buildBackground(MenuItem item) {
    if (_controller != null && _controller!.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    }
    if (item.imageUrl != null) {
      return Image.network(item.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900));
    }
    return Container(color: Colors.grey.shade900);
  }

  Widget _buildSponsoredBorder() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.amber.withOpacity(0.6), width: 3)),
      ),
    );
  }

  Widget _buildInfoOverlay(MenuItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.vendorIsSponsored)
          const Padding(padding: EdgeInsets.only(bottom: 10), child: SponsoredTag(dark: true)),
        Row(
          children: [
            GestureDetector(
              onTap: widget.onVendorTap,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: InitialsAvatar(name: item.vendorName, color: const Color(0xFFC2410C), size: 34, imageUrl: item.vendorLogoUrl),
                  ),
                  const SizedBox(width: 10),
                  Text(item.vendorName,
                      style: AppTheme.display(size: 15, weight: FontWeight.w800, color: Colors.white),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: widget.onFollow,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.isFollowing ? Colors.transparent : Colors.white.withOpacity(0.12),
                  border: Border.all(color: widget.isFollowing ? Colors.white.withOpacity(0.4) : Colors.white),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(widget.isFollowing ? 'Following' : 'Follow',
                    style: AppTheme.sans(size: 12, weight: FontWeight.w700, color: widget.isFollowing ? Colors.white.withOpacity(0.8) : Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.display(size: 26, weight: FontWeight.w800, color: Colors.white).copyWith(height: 1.1)),
        if (item.description != null) ...[
          const SizedBox(height: 6),
          Text(item.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sans(size: 13, color: Colors.white.withOpacity(0.75))),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Text(naira(item.price), style: AppTheme.display(size: 24, weight: FontWeight.w800, color: Colors.white)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onFullMenu,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('Full menu', style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (item.vendorRating > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
              const SizedBox(width: 4),
              Text('${item.vendorRating.toStringAsFixed(1)} rating',
                  style: AppTheme.sans(size: 11, color: Colors.white.withOpacity(0.55))),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionRail(MenuItem item) {
    return Column(
      children: [
        _railButton(
          icon: widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: widget.isLiked ? AppColors.coral : Colors.white,
          count: item.likeCount + (widget.isLiked ? 1 : 0),
          onTap: widget.onLike,
          size: 27,
        ),
        const SizedBox(height: 14),
        _railButton(icon: Icons.chat_bubble_outline_rounded, count: item.commentCount, onTap: widget.onComment, size: 26),
        const SizedBox(height: 14),
        _railButton(icon: Icons.send_rounded, count: item.shareCount, onTap: widget.onShare, size: 24),
        const SizedBox(height: 14),
        _railButton(icon: Icons.flag_outlined, onTap: widget.onReport, size: 22),
        const SizedBox(height: 14),
        Column(
          children: [
            GestureDetector(
              onTap: widget.onAddToCart,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle, boxShadow: AppShadows.float),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20)),
                    if (widget.cartQuantity > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('${widget.cartQuantity}', style: AppTheme.sans(size: 9, weight: FontWeight.w800, color: AppColors.coral)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('Add', style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _railButton({required IconData icon, required VoidCallback onTap, int? count, Color color = Colors.white, double size = 26}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size, shadows: const [Shadow(blurRadius: 6, color: Colors.black45)]),
          if (count != null) ...[
            const SizedBox(height: 2),
            Text(compact(count), style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: Colors.white)),
          ],
        ],
      ),
    );
  }
}
