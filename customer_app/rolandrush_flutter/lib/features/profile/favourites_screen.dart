import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/error_view.dart';
import '../restaurants/providers/restaurants_provider.dart';
import 'providers/favourites_provider.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouritesProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: const AppScreenHeader(title: 'Favourite restaurants'),
      body: restaurantsAsync.when(
        data: (all) {
          final list = all.where((r) => favourites.contains(r.id)).toList();
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Tap the heart on any vendor to save it here.', textAlign: TextAlign.center, style: AppTheme.sans(size: 14, color: AppColors.ink50)),
              ),
            );
          }
          return AppScreenBody(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: list.map((r) => RestaurantRow(restaurant: r)).toList()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(restaurantsProvider)),
      ),
    );
  }
}
