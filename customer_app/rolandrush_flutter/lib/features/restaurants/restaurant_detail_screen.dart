import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/menu_item.dart';
import '../../widgets/primitives.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/floating_cart_button.dart';
import '../../widgets/error_view.dart';
import '../cart/providers/cart_provider.dart';
import '../feed/widgets/add_ons_sheet.dart';
import 'providers/restaurants_provider.dart';
import 'providers/vendor_menu_provider.dart';
import '../profile/providers/favourites_provider.dart';
import '../checkout/providers/checkout_provider.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String vendorId;
  const RestaurantDetailScreen({super.key, required this.vendorId});

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  String? category;

  Future<void> _openAddOns(MenuItem item) async {
    final cart = ref.read(cartProvider.notifier);
    final existing = cart.forMenuItem(item.id);
    final result = await showModalBottomSheet<({int quantity, List addOns})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (_) => AddOnsSheet(item: item, initialQuantity: existing?.quantity ?? 1, initialSelection: existing?.selectedAddOns ?? const []),
    );
    if (result != null) {
      cart.addOrUpdate(item, quantity: result.quantity, addOns: result.addOns.cast());
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(restaurantByIdProvider(widget.vendorId));
    final menuAsync = ref.watch(vendorMenuProvider(widget.vendorId));
    final favourites = ref.watch(favouritesProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          restaurantAsync.when(
            data: (restaurant) {
              if (restaurant == null) return const Center(child: Text('Vendor not found'));
              final fav = favourites.contains(restaurant.id);
              return menuAsync.when(
                data: (items) {
                  final categories = items.map((i) => i.category ?? 'Menu').toSet().toList();
                  category ??= categories.isNotEmpty ? categories.first : null;
                  final shown = items.where((i) => (i.category ?? 'Menu') == category).toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      SizedBox(
                        height: 196,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            restaurant.coverUrl != null
                                ? Image.network(restaurant.coverUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.night))
                                : Container(color: AppColors.night),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x8C000000), Colors.transparent, Color(0x59000000)]),
                              ),
                            ),
                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _roundIconButton(Icons.chevron_left, () => context.pop()),
                                    GestureDetector(
                                      onTap: () => ref.read(favouritesProvider.notifier).toggle(restaurant.id),
                                      child: _roundIconWrap(Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          color: fav ? AppColors.coral : Colors.white, size: 18)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(restaurant.name, style: AppTheme.display(size: 21, weight: FontWeight.w800)),
                                          const SizedBox(height: 4),
                                          Text('${restaurant.cuisineType ?? ''} · ${restaurant.city ?? ''}',
                                              style: AppTheme.sans(size: 13, color: AppColors.ink35)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: restaurant.isOpen ? AppColors.mint.withOpacity(0.1) : AppColors.canvas,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(restaurant.isOpen ? 'Open now' : 'Closed',
                                          style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: restaurant.isOpen ? AppColors.mint : AppColors.ink35)),
                                    ),
                                  ],
                                ),
                                Container(margin: const EdgeInsets.symmetric(vertical: 12), height: 1, color: AppColors.line),
                                Row(
                                  children: [
                                    RatingBadge(value: restaurant.rating, reviews: restaurant.reviewCount),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.ink50),
                                    const SizedBox(width: 4),
                                    Text(restaurant.deliveryTime ?? '—', style: AppTheme.sans(size: 12, color: AppColors.ink50)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.pedal_bike_rounded, size: 14, color: AppColors.ink50),
                                    const SizedBox(width: 4),
                                    Text(
                                      naira(
                                        ref.watch(deliveryFeeByCityProvider).maybeWhen(
                                              data: (m) => m[restaurant.city] ?? restaurant.deliveryFee,
                                              orElse: () => restaurant.deliveryFee,
                                            ),
                                      ),
                                      style: AppTheme.sans(size: 12, color: AppColors.ink50),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => context.push('/vendor/${restaurant.id}'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.ink50),
                                        const SizedBox(width: 8),
                                        Text('Vendor profile, hours & reviews', style: AppTheme.sans(size: 13, weight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (categories.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) =>
                                  AppChip(label: categories[i], active: category == categories[i], onTap: () => setState(() => category = categories[i])),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: shown
                              .map((item) => Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.name, style: AppTheme.display(size: 15, weight: FontWeight.w800)),
                                              if (item.description != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Text(naira(item.price), style: AppTheme.display(size: 16, weight: FontWeight.w800)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(14),
                                              child: item.imageUrl != null
                                                  ? Image.network(item.imageUrl!, width: 84, height: 84, fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => Container(width: 84, height: 84, color: AppColors.line))
                                                  : Container(width: 84, height: 84, color: AppColors.line),
                                            ),
                                            Positioned(
                                              right: -8,
                                              bottom: -8,
                                              child: GestureDetector(
                                                onTap: () => _openAddOns(item),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle, boxShadow: AppShadows.float),
                                                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(vendorMenuProvider(widget.vendorId))),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(restaurantByIdProvider(widget.vendorId))),
          ),
          const FloatingCartButton(bottom: 24),
          Align(alignment: Alignment.bottomCenter, child: AppBottomNav(currentPath: '/discover')),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap, child: _roundIconWrap(Icon(icon, color: Colors.white, size: 20)));

  Widget _roundIconWrap(Widget child) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: child,
      );
}
