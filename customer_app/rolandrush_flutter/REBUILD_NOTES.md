# RolandRush Flutter Rebuild — Notes

## What's in this first slice
- `lib/models/` — MenuItem, AddOn, CartItem mapped to your **real** Supabase
  columns (RolandRushApp, ref `wjtyasspkowlibvigtrt`), not the Figma mock data.
- `lib/features/feed/` — the TikTok-style feed: vertical `PageView.builder`,
  one active `VideoPlayerController` at a time (only the current page plays —
  this is the #1 perf mistake to avoid in a Flutter video feed), double-tap
  to like, action rail, add-ons bottom sheet with the 5-item cap and live
  price recalculation, matching the Figma prototype's behavior.
- `lib/features/cart/` — cart state shared across feed/restaurant/checkout,
  grouped by vendor for multi-restaurant checkout.
- `lib/core/supabase_service.dart` — client init.

## Before this compiles and runs
1. `flutter create .` in this folder to generate platform folders
   (android/ios/etc), then `flutter pub get`.
2. Wire `SupabaseService.init(...)` in `main.dart` with your project URL
   and anon key.
3. **Fix RLS first.** 16 tables — including `menu_items` — currently have
   Row Level Security disabled. The feed query above will work today
   because of that, but it also means anyone with the anon key can read/
   write everything. Policies need to go in before this goes near real
   users. I can draft the policy set when you're ready.

## Schema gaps found by comparing the Figma export to Supabase
The design has screens/features with no backing table yet:
- `RolandPointsScreen` → no `loyalty_points` / `points_transactions` table
- `MembershipScreen` → no `memberships` / subscription table
- Ad system (`AdCampaign`: budget, spent, impressions, clicks, priority)
  → no `ad_campaigns` table. `vendor_profiles.is_sponsored` and
  `bid_amount` exist, which covers *who* gets boosted, but not campaign
  tracking/spend.
- Feed engagement (likes/comments/shares) → no table at all currently.
  The React mock keeps these as in-memory counts. Recommend a
  `menu_item_engagement` table (menu_item_id, user_id, type: like/comment,
  content, created_at) before this is real.

## Not yet ported from the Figma export
Screens that still need Flutter equivalents (React source is in the
uploaded zip for reference): DiscoverScreen, RestaurantDetail,
VendorProfilePage, CartScreen, CheckoutScreen, OrderTracking,
OrdersScreen, ProfileScreen + 9 profile sub-screens, CustomerAuth/OTP/
Onboarding/Splash.
