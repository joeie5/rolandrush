# RolandRush Vendor Partner — Flutter Rebuild Notes

## Scope of this slice
Vendor Owner core loop only, per your call — Kitchen Staff and Agent
modules dropped for now:
- **VendorDashboardScreen** — balance + active order count, quick nav
- **VendorOrdersScreen** — Active/History tabs, status progression
  (pending → preparing → ready → delivered), realtime via Supabase
  channel so new orders appear without a manual pull-to-refresh
- **MenuManagerScreen + AddMenuItemSheet** — list, availability toggle,
  delete, and a basic add-item form (text fields only — no image/video
  upload wired yet, see below)
- **VendorWalletScreen** — balance, total earned/withdrawn, withdrawal
  request, transaction history

## The backend situation (flagging again since it's structural)
This app points at a **separate Supabase project** (`epvbhtfycoqqwzstrlno`)
from the customer/rider apps (`RolandRushApp`, `wjtyasspkowlibvigtrt`).
You chose to keep them separate for now — noted, not re-litigating it —
but a few concrete consequences worth having in view whenever you do
revisit it:

1. **The React app itself is inconsistent about which storage it uses.**
   Vendor signup/auth goes through a KV store (`kv_store_ab68c07a`, a
   single key→jsonb table) via a Hono Edge Function
   (`/make-server-ab68c07a/vendor-profile`), while the dashboard reads
   real relational tables (`getOrders`, `getMenuItems`, etc. in
   `utils/supabase/database.ts`). **This Flutter rebuild assumes the
   real tables from `COMPLETE_DATABASE_SCHEMA.sql` are the source of
   truth** and talks to them directly via `supabase_flutter` — it does
   NOT call the KV Edge Function. If vendor signup in production is
   still KV-only, new vendors created there won't have a row in the
   relational `vendor_profiles` table this app expects, and vice versa.
   Worth deciding which path is canonical before shipping either side.

2. **Schema drift vs. RolandRushApp.** Even setting the KV question
   aside, this project's `orders`/`menu_items`/`wallets` tables are
   *not* the same shape as RolandRushApp's. Notably:
   - This `orders` table has no `rider_id`/`current_step`/`delivery_otp`
     — it uses a simpler pending→preparing→ready→delivered status and
     an `agent_id` instead. There's no obvious link between an order
     placed in the *customer* app (RolandRushApp) and an order a
     *vendor* sees here — they're structurally different tables in
     different databases. This needs a real answer before a customer's
     order can flow through to a vendor and a rider end-to-end.
   - `subscription_tier` has a check constraint accepting both
     `'STANDARD'/'standard'` and `'PREMIUM'/'gold'/'platinum'` —
     evidence of two naming conventions merged without cleanup.
   - `wallets` here has `total_withdrawn` in addition to
     RolandRushApp's `balance`/`total_earned`.

3. **RLS**: same caveat as the other two apps — check this project's
   RLS status before real vendor data goes in it.

## Not yet wired
- **Image/video upload for menu items** — needs Supabase Storage bucket
  setup + upload flow, mirroring `uploadMenuItemImage`/
  `uploadMenuItemVideo` in the React app's `database.ts`.
- **Order status → rider/agent handoff** — `RiderHandoverScreen.tsx` and
  `verifyPickupCode()` in the React app suggest a pickup-code handoff
  step between "Ready" and "Delivered" that this rebuild doesn't
  implement yet (mirrors the delivery OTP gap we filled on the rider
  side — worth the same treatment here).
- **Insights/analytics, Ads/campaigns, Staff management, Notifications,
  Subscription screen** — all present in the React source (62 screens
  total) but out of scope for this pass per your call to focus on the
  core loop.
