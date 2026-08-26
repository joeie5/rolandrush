import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/restaurant.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/floating_cart_button.dart';
import '../../widgets/error_view.dart';
import '../restaurants/providers/restaurants_provider.dart';

const _cuisines = ['All', 'Nigerian', 'Grills', 'Wraps', 'Burgers', 'Pizza', 'Drinks'];
const _sortOptions = ['Recommended', 'Fastest delivery', 'Top rated', 'Lowest delivery fee'];

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _controller = TextEditingController();
  String query = '';
  String cuisine = 'All';
  String sort = _sortOptions[0];
  bool openOnly = false;

  List<Restaurant> _filter(List<Restaurant> all) {
    var list = all.where((r) {
      final matchesQuery = query.isEmpty ||
          r.name.toLowerCase().contains(query.toLowerCase()) ||
          (r.cuisineType?.toLowerCase().contains(query.toLowerCase()) ?? false);
      final matchesCuisine = cuisine == 'All' || (r.cuisineType?.toLowerCase().contains(cuisine.toLowerCase()) ?? false);
      return matchesQuery && matchesCuisine && (!openOnly || r.isOpen);
    }).toList();

    switch (sort) {
      case 'Top rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Lowest delivery fee':
        list.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
        break;
      default:
        break;
    }
    return list;
  }

  void _openFilters(List<Restaurant> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filters', style: AppTheme.display(size: 18, weight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Text('Sort by', style: AppTheme.display(size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions
                        .map((s) => AppChip(label: s, active: sort == s, onTap: () => setSheetState(() => sort = s)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Availability', style: AppTheme.display(size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AppChip(label: 'Open now', active: openOnly, onTap: () => setSheetState(() => openOnly = true)),
                      const SizedBox(width: 8),
                      AppChip(label: 'Show all', active: !openOnly, onTap: () => setSheetState(() => openOnly = false)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.lg,
                          onPressed: () => setSheetState(() {
                            sort = _sortOptions[0];
                            openOnly = false;
                          }),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          size: AppButtonSize.lg,
                          onPressed: () {
                            setState(() {});
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: restaurantsAsync.when(
              data: (all) {
                final results = _filter(all);
                return ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Text('Discover', style: AppTheme.display(size: 26, weight: FontWeight.w800)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.btn), border: Border.all(color: AppColors.line)),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded, size: 18, color: AppColors.ink35),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      onChanged: (v) => setState(() => query = v),
                                      style: AppTheme.sans(size: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Jollof, suya, shawarma…',
                                        hintStyle: AppTheme.sans(size: 14, color: AppColors.ink35),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  if (query.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        query = '';
                                        _controller.clear();
                                      }),
                                      child: const Icon(Icons.close_rounded, size: 16, color: AppColors.ink35),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _openFilters(results),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.btn)),
                              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _cuisines.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => AppChip(
                            label: _cuisines[i],
                            active: cuisine == _cuisines[i],
                            onTap: () => setState(() => cuisine = _cuisines[i]),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: SectionLabel(
                        title: '${results.length} vendor${results.length == 1 ? '' : 's'} near you',
                        action: Text(sort, style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                      ),
                    ),
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          child: Column(
                            children: [
                              Text('Nothing matched "$query"', style: AppTheme.display(size: 15, weight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text('Try a dish name like jollof, asun or zobo.',
                                  textAlign: TextAlign.center, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
                              const SizedBox(height: 16),
                              AppButton(
                                variant: AppButtonVariant.secondary,
                                size: AppButtonSize.sm,
                                onPressed: () => setState(() {
                                  query = '';
                                  _controller.clear();
                                }),
                                child: const Text('Clear search'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              for (var i = 0; i < results.length; i++)
                                RestaurantRow(restaurant: results[i], sponsored: results[i].isSponsored),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(restaurantsProvider)),
            ),
          ),
          const FloatingCartButton(bottom: 96),
          Align(alignment: Alignment.bottomCenter, child: AppBottomNav(currentPath: '/discover')),
        ],
      ),
    );
  }
}
