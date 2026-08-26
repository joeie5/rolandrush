import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/primitives.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/floating_cart_button.dart';
import '../../widgets/error_view.dart';
import '../feed/providers/feed_provider.dart';
import '../restaurants/providers/restaurants_provider.dart';
import '../orders/providers/orders_provider.dart';

const _categories = ['Jollof', 'Suya', 'Swallow', 'Shawarma', 'Pizza', 'Drinks', 'Small chops'];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final activeOrderAsync = ref.watch(activeOrderProvider);
    final heroItem = feed.items.isNotEmpty ? feed.items.first : null;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(restaurantsProvider);
                await ref.read(feedProvider.notifier).refresh();
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DELIVER TO',
                                  style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.ink35)
                                      .copyWith(letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text('Oke Baale, Osogbo',
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.display(size: 19, weight: FontWeight.w800)),
                                  ),
                                  const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.ink50),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/notifications'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_none_rounded, size: 20),
                                Positioned(
                                  right: 9,
                                  top: 9,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: AppColors.coral, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GestureDetector(
                      onTap: () => context.push('/discover'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.btn), border: Border.all(color: AppColors.line)),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, size: 18, color: AppColors.ink35),
                            const SizedBox(width: 10),
                            Text('Search dishes, vendors, cuisines', style: AppTheme.sans(size: 14, color: AppColors.ink35)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GestureDetector(
                      onTap: () => context.push('/feed'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: SizedBox(
                          height: 260,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              heroItem?.videoUrl != null || heroItem?.imageUrl != null
                                  ? Image.network(
                                      heroItem!.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: AppColors.night),
                                    )
                                  : Container(color: AppColors.night),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Colors.black, Color(0x59000000), Color(0x1A000000)],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                top: 14,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(20)),
                                      child: Text('LIVE FEED',
                                          style: AppTheme.sans(size: 11, weight: FontWeight.w800, color: Colors.white).copyWith(letterSpacing: 0.6)),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(height: 10),
                                    Text("Swipe through tonight's kitchens",
                                        style: AppTheme.display(size: 24, weight: FontWeight.w800, color: Colors.white)),
                                    if (heroItem != null) ...[
                                      const SizedBox(height: 4),
                                      Text('${heroItem.name} · ${naira(heroItem.price)} · ${heroItem.vendorName}',
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.sans(size: 13, color: Colors.white.withOpacity(0.7))),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  activeOrderAsync.maybeWhen(
                    data: (order) => order == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: GestureDetector(
                              onTap: () => context.push('/tracking/${order.id}'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.line)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(color: AppColors.coralSoft, shape: BoxShape.circle),
                                      alignment: Alignment.center,
                                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Order in progress', style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                                          Text('${order.orderNumber} · ${order.restaurantName ?? ''}',
                                              overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                                        ],
                                      ),
                                    ),
                                    Text('Track', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => AppChip(label: _categories[i], onTap: () => context.push('/discover')),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: SectionLabel(
                      title: 'Popular near you',
                      action: GestureDetector(
                        onTap: () => context.push('/discover'),
                        child: Text('See all', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
                      ),
                    ),
                  ),
                  restaurantsAsync.when(
                    data: (list) => SizedBox(
                      height: 172,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => RestaurantTile(restaurant: list[i]),
                      ),
                    ),
                    loading: () => const SizedBox(height: 172, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => SizedBox(height: 100, child: AppErrorView(error: e, onRetry: () => ref.invalidate(restaurantsProvider))),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: GestureDetector(
                      onTap: () => context.push('/points'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.card)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('RolandPoints', style: AppTheme.display(size: 15, weight: FontWeight.w800, color: Colors.white)),
                                  Text('Earn points on every order', style: AppTheme.sans(size: 12, color: Colors.white.withOpacity(0.6))),
                                ],
                              ),
                            ),
                            Text('Redeem', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  restaurantsAsync.maybeWhen(
                    data: (list) => list.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel(title: 'Promoted in Osogbo'),
                                AppCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: list
                                        .take(3)
                                        .map((r) => RestaurantRow(restaurant: r, sponsored: r.isSponsored))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const FloatingCartButton(bottom: 96),
          Align(alignment: Alignment.bottomCenter, child: AppBottomNav(currentPath: '/home')),
        ],
      ),
    );
  }
}
