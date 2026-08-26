# RolandRush Rider — Flutter Rebuild Notes

## What's in this slice
- **Models**: `DeliveryOrder` (public.orders, rider view), `RiderProfile`
  (public.rider_profiles), `Wallet` + `WithdrawalRequest` (public.wallets /
  withdrawal_requests).
- **HomeDashboardScreen**: online/offline toggle wired to
  `rider_profiles.is_online` (the Figma mock's Switch had no backing logic —
  this one persists).
- **AvailableOrdersScreen**: job board querying real `orders` where
  `status = 'pending'` and `rider_id is null`, with All/Nearby/High-Pay
  filter chips (Nearby currently a no-op — needs a distance calc, see below).
- **ActiveDeliveryScreen**: the 4-step state machine
  (En Route → Pickup → Delivering → Delivered), backed by
  `orders.current_step`, writing breadcrumb rows to `order_tracking` on
  each step change.

## One deliberate change from the Figma design
The mock `ActiveDelivery.tsx` completes delivery on a plain button tap.
I added an **OTP confirmation step** (`delivery_otp_sheet.dart`) instead —
your schema already has `orders.delivery_otp` sitting unused, and
OTP-on-handoff is the standard way delivery apps prevent a rider marking
an order delivered before it's actually handed over. This is new
behavior, not a port of something that existed — flag if you'd rather
keep it as a plain tap-through for v1 and add OTP later.

## Known gaps / TODOs baked into the code as comments
1. **Order acceptance race condition** — `acceptOrder()` does a plain
   client-side update guarded by `rider_id is null`. Two riders tapping
   "Accept" at the same moment could both think they got it. Should
   become a Postgres function (`accept_order(order_id, rider_id)`) using
   `SELECT ... FOR UPDATE` or an atomic `UPDATE ... WHERE rider_id IS NULL
   RETURNING *` checked for a returned row, called via RPC.
2. **Nearby filter** — needs rider lat/lng vs. order pickup lat/lng
   distance calc. `rider_locations` already uses PostGIS `geography`, so
   this is a good candidate for a `nearby_orders(lat, lng, radius)`
   Postgres function rather than client-side math.
3. **Rider payout bank details** — `WithdrawFundsScreen` currently has a
   placeholder for bank account info. `rider_profiles` doesn't have bank
   fields (vendor_profiles does: bank_name, account_number, account_name).
   Need to either add those columns to rider_profiles or create a
   `rider_bank_accounts` table.
4. **Rider "level"/tier** (Gold/Silver in the mock) — not in schema.
   Could be computed client-side from a completed-orders count rather
   than stored, unless you want tier-based incentives (bonus per
   delivery at higher tiers), in which case it needs a real column.

## Not yet ported (source in the uploaded zip for reference)
OTPVerification, PhoneInput, Onboarding, SplashScreen (auth flow —
likely close to identical logic to the customer app's equivalents, worth
sharing code between the two apps rather than duplicating), OrderHistory,
Earnings (distinct from WithdrawFunds — Earnings looks like it's the
stats/breakdown view; WithdrawFunds is the payout action), Profile + 8
profile sub-pages (BankAccount, Documents, HelpSupport,
NotificationSettings, PersonalInformation, PrivacySecurity,
TermsConditions, VehicleDetails), TipsCard, FloatingHelpButton,
DeliverySuccessModal, MockMap/MapPlaceholder (need a real
google_maps_flutter implementation).

## Still true from the customer app notes
RLS is disabled on 16 tables including ones this app reads/writes
(orders, transactions, withdrawal_requests, rider_locations). Same
caveat applies — fine for development, not for real riders.
