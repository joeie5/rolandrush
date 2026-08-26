# RolandRush — Consolidated Build Brief
*For Antigravity — covers the Customer, Rider, and Vendor Partner apps together*

RolandRush is a food delivery platform based in Osun State, Nigeria. Its
defining feature is a **TikTok-style vertical video feed** for browsing
restaurant menu items, instead of the list/grid format used by
Chowdeck, Glovo, etc. There are three Flutter apps in scope:

1. **Customer app** — browse the feed, order, track delivery
2. **Rider app** — accept jobs, run deliveries, get paid
3. **Vendor Partner app** — restaurant owners manage menu/orders/payouts

Each was rebuilt from a Figma Make React/TypeScript export (original
Flutter source was lost) plus, where available, the live Supabase
schema. Three separate zips were handed off:
`rolandrush_flutter_feed_starter.zip` (customer),
`rolandrush_rider_flutter_starter.zip` (rider),
`rolandrush_vendor_flutter_starter.zip` (vendor). This document is the
context that ties them together — read this before diving into any one
zip's own `REBUILD_NOTES.md`.

---

## 1. The backend split (read this first — it's the biggest open issue)

There are **two separate Supabase projects** in play, and they are not
connected:

| | Project ref | Used by | Storage style |
|---|---|---|---|
| **RolandRushApp** | `wjtyasspkowlibvigtrt` | Customer app, Rider app | Real relational Postgres tables |
| **Partner project** | `epvbhtfycoqqwzstrlno` | Vendor app | Mixed — see below |

The Vendor app's own React source is internally inconsistent about
which storage it uses:
- Vendor **signup/auth** goes through a KV (key-value) store — a single
  `kv_store_ab68c07a` table holding `key/value jsonb` pairs — accessed
  via a Hono Edge Function (`/make-server-ab68c07a/vendor-profile`).
  This was a workaround for `PGRST205` errors (Supabase's API not
  recognizing newly created tables — usually just a schema-cache reload
  away from being fixed) that instead abandoned proper tables entirely.
- The **vendor dashboard** reads real relational tables via
  `utils/supabase/database.ts` (`getOrders`, `getMenuItems`, `getWallet`,
  etc.), backed by a genuine schema in `COMPLETE_DATABASE_SCHEMA.sql`.

**The Vendor Flutter starter was built against the real relational
tables**, not the KV store, since that's the only viable long-term
foundation. But this means: if vendor signup in production is still
KV-only, a vendor created through signup won't have a row in the
relational `vendor_profiles` table the dashboard (and this Flutter app)
expects. **This needs to be resolved — either point signup at the real
tables too, or migrate KV data over — before the Vendor app is usable
end to end.**

### The bigger structural gap: no shared order model

Even setting the KV question aside, **RolandRushApp's `orders` table
and the Partner project's `orders` table are different shapes in
different databases**, with no defined relationship between them:

- RolandRushApp `orders`: has `rider_id`, `current_step` (1–4:
  en route/pickup/delivering/delivered), `delivery_otp`,
  `delivery_lat/lng` — built for the customer↔rider handoff.
- Partner project `orders`: has `agent_id` instead of `rider_id`, a
  simpler `pending → preparing → ready → delivered` status, no
  `current_step`, no `delivery_otp`.

**There is currently no path for "customer places an order in the feed
app → vendor sees it on their dashboard → rider picks it up and
delivers it."** These are three apps that don't yet talk to each other
for the one workflow that matters most. This is the single most
important architectural decision outstanding — bigger than the RLS
question below. Options, roughly in order of how much rework they cost:

- **(a)** Consolidate onto one Supabase project and one `orders` table
  that has every column all three apps need (rider_id AND agent_id AND
  current_step AND vendor-side status AND delivery_otp).
- **(b)** Keep two projects, but have order-placement write to both (or
  have a sync job / webhook bridge them) — more moving parts, more ways
  for the two records to drift out of sync.
- **(c)** Keep two projects, and only ever treat RolandRushApp's `orders`
  as canonical — the Partner app would need to be repointed to read/write
  RolandRushApp instead of its own project's `orders` table.

This wasn't decided during the rebuild — surfacing it here so it gets
picked up explicitly rather than assumed away.

---

## 2. RolandRushApp schema (Customer + Rider apps)

Project ref `wjtyasspkowlibvigtrt`, region eu-west-2. Key tables:

- `customer_profiles`, `vendor_profiles`, `rider_profiles`,
  `kitchen_staff_profiles` — one row per user role
- `menu_items` — has `video_url` (feed-ready), `dietary_info`,
  `allergens`, `add_ons` jsonb, `spicy_level`, `comments` jsonb
- `menu_categories`, `menu_item_addons`
- `orders` — `order_number` (auto `RR-###`), `current_step` (1–4),
  `delivery_otp`, live `delivery_lat/lng`
- `order_tracking` — status/lat/lng breadcrumb trail per order
- `rider_locations` — PostGIS `geography` type, for live rider position
- `cart_items`, `chat_messages` (in-order chat)
- `wallets`, `transactions`, `withdrawal_requests`
- `vendor_reviews`, `rider_reviews`, `notifications`, `push_tokens`
- `customer_addresses`

### ⚠️ Security: RLS disabled on 16 tables
Supabase flagged this directly: **16 tables have Row Level Security
disabled**, including `menu_items`, `transactions`,
`withdrawal_requests`, `chat_messages`, `notifications`,
`cart_items`, `rider_locations`, and more. Anyone with the app's public
anon key can currently read or write **every row** in those tables —
other users' orders, chats, withdrawal requests, everything. This has
been flagged repeatedly through the build and deliberately not
auto-fixed (enabling RLS without policies would lock out all access) —
**policies need to be written before any of these three apps goes near
real users.** Full list of affected tables and the enable-RLS SQL are
in the Customer app's `REBUILD_NOTES.md`.

### Schema gaps found vs. the Figma design (Customer app)
The customer app's design has screens with no backing table yet:
- `RolandPointsScreen` → no `loyalty_points`/`points_transactions` table
- `MembershipScreen` → no `memberships`/subscription table
- Ad system (`AdCampaign`: budget, spent, impressions, clicks, priority)
  → no `ad_campaigns` table. `vendor_profiles.is_sponsored` and
  `bid_amount` exist (covers *who* gets boosted) but nothing tracks
  campaign spend/performance.
- Feed engagement (likes/comments/shares) → no table at all. Currently
  client-side only in the Flutter starter (`FeedNotifier.toggleLike`
  etc.) — recommend a `menu_item_engagement` table
  (menu_item_id, user_id, type, content, created_at) before this is real.

---

## 3. Partner project schema (Vendor app)

Project ref `epvbhtfycoqqwzstrlno`. Real tables (from
`COMPLETE_DATABASE_SCHEMA.sql`), Kitchen Staff and Agent tables exist
in the schema but were **deliberately excluded from this build pass**
per direction — Vendor Owner only for now:

- `vendor_profiles` — similar shape to RolandRushApp's version but not
  identical; `subscription_tier` check constraint accepts **both**
  `'STANDARD'/'standard'` and `'PREMIUM'/'gold'/'platinum'` — two naming
  conventions merged without cleanup, worth picking one.
- `vendor_agent_profiles`, `agent_employments` — **out of scope this pass**
- `kitchen_staff` — **out of scope this pass**
- `menu_categories`, `menu_items` — has `media_type`
  (image/video/none), `video_thumbnail_url`, `tags[]` on top of what
  RolandRushApp's customer-facing `menu_items` has — close but not
  identical column sets.
- `orders` — see the shared-order-model gap in section 1.
- `wallets` — has `total_withdrawn` in addition to
  RolandRushApp's `balance`/`total_earned`.
- `transactions` — generic credit/debit ledger with `status` and
  `metadata` jsonb (richer than RolandRushApp's transactions table).
- `staff_shifts`, `staff_performance_logs`, `order_assignments`,
  `staff_achievements` — **out of scope this pass**

### RLS
Same caveat as RolandRushApp — check and fix before real vendor data
goes in. One of the fix files bundled in the original zip
(`DISABLE_RLS_FOR_DEV.sql`) explicitly turned RLS off as a "quick fix,"
which is fine for local dev but should not be the production state.

---

## 4. What's built in each Flutter starter

### Customer app (`rolandrush_flutter_feed_starter.zip`)
- **FeedScreen** — vertical `PageView.builder`, real video playback via
  `video_player` with only the current page's controller ever playing
  (avoids the common Flutter-feed mistake of every video playing at
  once), double-tap-to-like, action rail, add-ons bottom sheet (5-item
  cap, live price recalculation, matches the Figma UX), pull-to-refresh,
  infinite scroll.
- Models (`MenuItem`, `AddOn`, `CartItem`) mapped to real Supabase
  columns, not the Figma mock data.
- Cart provider shared across feed/cart/checkout, grouped by vendor for
  multi-restaurant checkout (per `CART_MULTI_RESTAURANT_CHECKOUT.md` in
  the original export).
- **Not yet ported**: DiscoverScreen, RestaurantDetail,
  VendorProfilePage, CartScreen, CheckoutScreen, OrderTracking,
  OrdersScreen, ProfileScreen + 9 profile sub-screens, auth flow
  (Splash/Onboarding/Auth/OTP).

### Rider app (`rolandrush_rider_flutter_starter.zip`)
- **HomeDashboardScreen** — online/offline toggle that persists to
  `rider_profiles.is_online` (the Figma mock's toggle had no backing
  logic).
- **AvailableOrdersScreen** — job board querying real `orders` where
  `status = 'pending'` and `rider_id is null`, with All/Nearby/High-Pay
  filters (Nearby is currently a no-op — needs a distance calc).
- **ActiveDeliveryScreen** — the 4-step state machine (En Route → Pickup
  → Delivering → Delivered), backed by `orders.current_step`, writing
  breadcrumb rows to `order_tracking` on each transition.
- **WithdrawFundsScreen** — balance + withdrawal request.
- **Deliberate addition vs. the Figma design**: delivery completion now
  requires the customer's `delivery_otp` (a 4-digit code entry sheet)
  instead of a plain button tap. The schema already had
  `orders.delivery_otp` sitting unused; the mock never read it. This is
  new behavior, not a port — confirm this is the intended flow before
  shipping, or revert to a plain tap-through (one-line change, noted in
  the file).
- **Known issues flagged in code comments**:
  - `acceptOrder()` race condition — two riders could both accept the
    same job; needs to become an atomic Postgres function
    (`SELECT ... FOR UPDATE` or `UPDATE ... WHERE rider_id IS NULL
    RETURNING *`), not a plain client-side update.
  - Rider payout bank details have nowhere to live —
    `vendor_profiles` has bank fields, `rider_profiles` doesn't.
  - Rider "level"/tier (Gold/Silver in the mock) isn't in the schema.
- **Not yet ported**: auth flow (likely shareable with the customer
  app's), OrderHistory, Earnings (stats view, distinct from
  WithdrawFunds), Profile + 8 sub-pages, TipsCard, FloatingHelpButton,
  DeliverySuccessModal, real map (currently a placeholder — needs
  `google_maps_flutter` wired with API keys).

### Vendor app (`rolandrush_vendor_flutter_starter.zip`)
- **VendorDashboardScreen** — balance + active order count, quick nav.
- **VendorOrdersScreen** — Active/History tabs, status progression
  (pending → preparing → ready → delivered), **realtime** via a
  Supabase channel subscription so new orders appear without a manual
  refresh.
- **MenuManagerScreen + AddMenuItemSheet** — list, availability toggle,
  delete, basic add-item form (text fields only).
- **VendorWalletScreen** — balance, total earned/withdrawn, withdrawal
  request, transaction history.
- **Known gaps flagged in code comments**:
  - No image/video upload wired for menu items yet — needs Supabase
    Storage bucket + upload flow (mirrors `uploadMenuItemImage`/
    `uploadMenuItemVideo` in the original React `database.ts`).
  - No pickup-code handoff step between "Ready" and "Delivered" —
    the original React source references `RiderHandoverScreen.tsx` and
    `verifyPickupCode()`, suggesting the same OTP-style handoff pattern
    added on the rider side should exist here too, but doesn't yet.
  - Withdrawal request writes a transaction + expects balance to update
    — needs to be one atomic Postgres function in production, not two
    separate client calls.
- **Deliberately out of scope this pass**: Kitchen Staff module, Vendor
  Agent/commission module, Insights/analytics, Ads/campaign creation,
  Staff management, Notifications, Subscription screen — all exist in
  the original 62-screen React source if/when needed.

---

## 5. Priority open decisions (for whoever picks this up next)

Roughly in order of how much they block a working end-to-end flow:

1. **Shared order model** (section 1) — without this, an order placed
   by a customer has no defined path to a vendor's dashboard or a
   rider's job board. Blocks any real end-to-end test.
2. **RLS policies** on both Supabase projects — currently wide open.
   Blocks going anywhere near real user data.
3. **Vendor signup backend** (KV store vs. real tables) — a vendor
   created today may not appear on their own dashboard depending on
   which code path ran.
4. **Two-Supabase-projects decision** — deferred once already; the
   longer it stays deferred, the more schema drift accumulates (see
   the subscription_tier naming split as an early example).
5. Smaller items: rider payout bank fields, order-accept race condition,
   pickup-code handoff for vendor→rider, nearby-orders distance calc.

---

## 6. File manifest

```
rolandrush_flutter_feed_starter.zip   — Customer app
rolandrush_rider_flutter_starter.zip  — Rider app
rolandrush_vendor_flutter_starter.zip — Vendor Partner app
```

Each zip has its own `REBUILD_NOTES.md` at the root with file-level
detail. This document is the cross-app context that doesn't live in
any single zip.
