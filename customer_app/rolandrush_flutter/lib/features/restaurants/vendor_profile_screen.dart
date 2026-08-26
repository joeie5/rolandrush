import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/primitives.dart';
import '../../widgets/error_view.dart';
import '../../widgets/app_button.dart';
import '../feed/providers/feed_provider.dart';
import 'providers/restaurants_provider.dart';
import 'providers/vendor_reviews_provider.dart';

const _accentPalette = [Color(0xFFFF7A59), Color(0xFF3B82F6), Color(0xFF0FA968), Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFFEC4899)];

class VendorProfileScreen extends ConsumerWidget {
  final String vendorId;
  const VendorProfileScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantByIdProvider(vendorId));
    final reviewsAsync = ref.watch(vendorReviewsProvider(vendorId));
    final following = ref.watch(feedProvider).followedVendorIds.contains(vendorId);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: restaurantAsync.when(
        data: (restaurant) {
          if (restaurant == null) return const Center(child: Text('Vendor not found'));
          final accent = _accentPalette[restaurant.accentSeed.abs() % _accentPalette.length];

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    restaurant.coverUrl != null
                        ? Image.network(restaurant.coverUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: accent))
                        : Container(color: accent),
                    Container(color: Colors.black.withOpacity(0.25)),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _roundBtn(Icons.chevron_left, () => context.pop()),
                            _roundBtn(Icons.share_outlined, () {}),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -36),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                            child: InitialsAvatar(name: restaurant.name, color: accent, size: 74, imageUrl: restaurant.logoUrl),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                AppButton(
                                  variant: AppButtonVariant.secondary,
                                  size: AppButtonSize.sm,
                                  onPressed: () {},
                                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.call_outlined, size: 15), SizedBox(width: 6), Text('Call')]),
                                ),
                                const SizedBox(width: 8),
                                AppButton(
                                  variant: following ? AppButtonVariant.secondary : AppButtonVariant.primary,
                                  size: AppButtonSize.sm,
                                  onPressed: () => ref.read(feedProvider.notifier).toggleFollow(restaurant.id),
                                  child: Text(following ? 'Following' : 'Follow'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(restaurant.name, style: AppTheme.display(size: 22, weight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('${restaurant.cuisineType ?? ''}', style: AppTheme.sans(size: 13, color: AppColors.ink35)),
                          if (restaurant.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(restaurant.description!, style: AppTheme.sans(size: 14, color: AppColors.ink70)),
                            ),
                          const SizedBox(height: 16),
                          if (restaurant.address != null)
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.ink50),
                                const SizedBox(width: 8),
                                Expanded(child: Text(restaurant.address!, style: AppTheme.sans(size: 13, color: AppColors.ink50))),
                              ],
                            ),
                          const SizedBox(height: 20),
                          reviewsAsync.when(
                            data: (reviews) {
                              final counts = List.filled(5, 0);
                              for (final r in reviews) {
                                if (r.rating >= 1 && r.rating <= 5) counts[r.rating - 1]++;
                              }
                              final total = reviews.length;
                              return AppCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        RatingBadge(value: restaurant.rating, reviews: restaurant.reviewCount),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    for (var star = 5; star >= 1; star--)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 14, child: Text('$star', style: AppTheme.sans(size: 12, color: AppColors.ink50))),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: total == 0 ? 0 : counts[star - 1] / total,
                                                  minHeight: 6,
                                                  backgroundColor: AppColors.line,
                                                  color: AppColors.coral,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (total == 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text('No reviews yet', style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                                      ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
                            error: (e, _) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(restaurantByIdProvider(vendorId))),
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}
