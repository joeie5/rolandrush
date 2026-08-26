import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Client-side only — no `vendor_favourites` table exists yet (see
/// ROLANDRUSH_CONSOLIDATED_BRIEF.md schema-gap notes). Mirrors the
/// feed's toggleLike pattern until a real table backs this.
class FavouritesNotifier extends StateNotifier<Set<String>> {
  FavouritesNotifier() : super({});

  void toggle(String vendorId) {
    final next = {...state};
    next.contains(vendorId) ? next.remove(vendorId) : next.add(vendorId);
    state = next;
  }
}

final favouritesProvider = StateNotifierProvider<FavouritesNotifier, Set<String>>(
  (ref) => FavouritesNotifier(),
);
