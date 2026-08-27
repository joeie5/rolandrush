import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../models/restaurant.dart';
import '../features/profile/providers/favourites_provider.dart';
import '../features/checkout/providers/checkout_provider.dart';
import 'primitives.dart';

const _accentPalette = [
  Color(0xFFFF7A59),
  Color(0xFF3B82F6),
  Color(0xFF0FA968),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
];

Color _accentFor(Restaurant r) => _accentPalette[r.accentSeed.abs() % _accentPalette.length];

class RestaurantRow extends ConsumerWidget {
  final Restaurant restaurant;
  final bool sponsored;
  const RestaurantRow({super.key, required this.restaurant, this.sponsored = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouritesProvider);
    final fav = favourites.contains(restaurant.id);
    final feeByCity = ref.watch(deliveryFeeByCityProvider).maybeWhen(data: (m) => m, orElse: () => <String, double>{});
    final displayedDeliveryFee = feeByCity[restaurant.city] ?? restaurant.deliveryFee;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push('/restaurant/${restaurant.id}'),
              child: Row(
                children: [
                  InitialsAvatar(name: restaurant.name, color: _accentFor(restaurant), size: 52, imageUrl: restaurant.logoUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(restaurant.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.display(size: 15, weight: FontWeight.w800)),
                            ),
                            if (sponsored) ...[const SizedBox(width: 6), const SponsoredTag()],
                          ],
                        ),
                        if (restaurant.cuisineType != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(restaurant.cuisineType!,
                                overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 13, color: AppColors.ink35)),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              RatingBadge(value: restaurant.rating),
                              const SizedBox(width: 10),
                              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.ink50),
                              const SizedBox(width: 3),
                              Text(restaurant.deliveryTime ?? '—', style: AppTheme.sans(size: 12, color: AppColors.ink50)),
                              const SizedBox(width: 10),
                              const Icon(Icons.pedal_bike_rounded, size: 12, color: AppColors.ink50),
                              const SizedBox(width: 3),
                              Text('₦${displayedDeliveryFee.toStringAsFixed(0)}',
                                  style: AppTheme.sans(size: 12, color: AppColors.ink50)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(favouritesProvider.notifier).toggle(restaurant.id),
            icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18, color: fav ? AppColors.coral : AppColors.ink35),
          ),
        ],
      ),
    );
  }
}

class RestaurantTile extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantTile({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: SizedBox(
        width: 168,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: SizedBox(
                height: 112,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    restaurant.coverUrl != null
                        ? Image.network(restaurant.coverUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: _accentFor(restaurant)))
                        : Container(color: _accentFor(restaurant)),
                    if (!restaurant.isOpen)
                      Container(
                        color: Colors.black.withOpacity(0.55),
                        alignment: Alignment.center,
                        child: Text('Closed', style: AppTheme.sans(size: 12, weight: FontWeight.w700, color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(restaurant.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.display(size: 14, weight: FontWeight.w800)),
            const SizedBox(height: 3),
            Row(
              children: [
                RatingBadge(value: restaurant.rating),
                const SizedBox(width: 4),
                Text('· ${restaurant.deliveryTime ?? '—'}', style: AppTheme.sans(size: 12, color: AppColors.ink35)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
