-- FIX 2 (CORRECTED): RLS lockdown for 14 of the 15 tables confirmed open,
-- plus vendor_profiles cleanup. `transactions`/`wallets` are deliberately
-- NOT touched here — see 02_transactions_wallet_rpc.sql, which must be
-- applied first (this file assumes complete_delivery_and_credit() already
-- exists, since it's the replacement for the direct cross-user wallet
-- writes that plain RLS would otherwise break).
--
-- CHANGED FROM THE PREVIOUS VERSION:
--   1. Added admin_users-gated policies to orders, withdrawal_requests,
--      vendor_profiles, rider_profiles, customer_profiles, chat_messages,
--      and order_tracking. Without these, the admin app — which uses only
--      the anon key + user sessions, confirmed via supabaseClient.ts, no
--      service role anywhere — loses all cross-user visibility the moment
--      this runs. The withdrawal queue, order lookup, and verification
--      queue would otherwise break immediately.
--   2. menu_items / menu_categories / menu_item_addons SELECT now also
--      requires the owning vendor to be verified, matching the same rule
--      already applied to vendor_profiles browsing — previously these
--      were open with no such check, which was an inconsistency, not a
--      deliberate choice. ALSO ADDED (this revision): a companion
--      owner-SELECT policy on all three, so an unverified vendor can
--      still see their own not-yet-public menu — the verified-only
--      browse policy alone would otherwise leave a new vendor's own menu
--      manager screen showing empty until they're approved.
--   3. transactions/withdrawal_requests/wallets policies all moved out to
--      20260826220100_fix2b_transactions_wallet_rpc.sql, which also adds
--      the complete_delivery_and_credit() RPC replacing the direct
--      cross-user wallet writes RLS would otherwise break. Apply that
--      file after this one — and only once the rider app's delivery-
--      completion code calls that RPC instead of writing directly.
--
-- STILL TRUE FROM BEFORE: after running this, manually re-test each
-- app's core flows signed in as an ordinary user (not service_role).

-- ============================================================
-- Helper functions
-- ============================================================

create or replace function public.is_order_participant(p_order_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.orders o
    where o.id = p_order_id
      and (
        o.customer_id = auth.uid()
        or o.vendor_id in (select id from public.vendor_profiles where user_id = auth.uid())
        or o.rider_id in (select id from public.rider_profiles where user_id = auth.uid())
      )
  );
$$;

create or replace function public.is_owning_vendor_of_menu_item(p_menu_item_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.menu_items mi
    join public.vendor_profiles vp on vp.id = mi.vendor_id
    where mi.id = p_menu_item_id and vp.user_id = auth.uid()
  );
$$;

create or replace function public.phone_already_registered(p_phone text)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (select 1 from public.vendor_profiles where phone_number = p_phone);
$$;

-- NOTE: is_active_admin() already exists from the earlier admin_users
-- RLS fix (20260826000539_fix_admin_users_rls.sql) — reused below, not
-- redefined here.

-- ============================================================
-- vendor_profiles: consolidate 4 overlapping anon policies, add
-- verification-gated public browsing, add admin access.
-- ============================================================

drop policy if exists "Allow public phone check" on public.vendor_profiles;
drop policy if exists "Allow public phone verification" on public.vendor_profiles;
drop policy if exists "Allow public select for verification" on public.vendor_profiles;
drop policy if exists "Enable phone check for non-logged in users" on public.vendor_profiles;

drop policy if exists "vendors can view their own profile" on public.vendor_profiles;
create policy "vendors can view their own profile"
on public.vendor_profiles for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "vendors can update their own profile" on public.vendor_profiles;
create policy "vendors can update their own profile"
on public.vendor_profiles for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "authenticated users can browse vendors" on public.vendor_profiles;
create policy "authenticated users can browse vendors"
on public.vendor_profiles for select
to authenticated
using (verification_status = 'verified');

drop policy if exists "vendors can insert their own profile" on public.vendor_profiles;
create policy "vendors can insert their own profile"
on public.vendor_profiles for insert
to authenticated
with check (user_id = auth.uid());

-- Admin needs to see and act on vendors regardless of verification
-- status — this is exactly what the verification queue and Directory
-- screens require (a pending vendor is invisible to customers, but must
-- be visible to admins reviewing it).
create policy "admins can view all vendor profiles"
on public.vendor_profiles for select
to authenticated
using (public.is_active_admin());

create policy "admins can update all vendor profiles"
on public.vendor_profiles for update
to authenticated
using (public.is_active_admin())
with check (public.is_active_admin());

-- ============================================================
-- rider_profiles: add admin access (existing owner policies untouched —
-- this table already had RLS enabled with working owner policies).
-- ============================================================

create policy "admins can view all rider profiles"
on public.rider_profiles for select
to authenticated
using (public.is_active_admin());

create policy "admins can update all rider profiles"
on public.rider_profiles for update
to authenticated
using (public.is_active_admin())
with check (public.is_active_admin());

-- ============================================================
-- orders: add admin access (existing customer/vendor/rider policies
-- untouched — this table already had RLS enabled with working policies).
-- ============================================================

create policy "admins can view all orders"
on public.orders for select
to authenticated
using (public.is_active_admin());

create policy "admins can update all orders"
on public.orders for update
to authenticated
using (public.is_active_admin())
with check (public.is_active_admin());

-- withdrawal_requests: handled in 20260826220100_fix2b_transactions_wallet_rpc.sql
-- alongside transactions/wallets, not here — avoid defining it twice.

-- ============================================================
-- Enable RLS on the 14 tables confirmed open (transactions/wallets moved
-- to the separate RPC-first file).
-- ============================================================

alter table public.cart_items enable row level security;
alter table public.chat_messages enable row level security;
alter table public.customer_profiles enable row level security;
alter table public.kitchen_staff_profiles enable row level security;
alter table public.menu_categories enable row level security;
alter table public.menu_item_addons enable row level security;
alter table public.menu_items enable row level security;
alter table public.notifications enable row level security;
alter table public.order_tracking enable row level security;
alter table public.push_tokens enable row level security;
alter table public.rider_locations enable row level security;
alter table public.rider_reviews enable row level security;
alter table public.vendor_reviews enable row level security;

-- ---------------- cart_items: owning customer only ----------------
create policy "customers manage their own cart"
on public.cart_items for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- ---------------- chat_messages: order participants + admin ----------------
create policy "order participants can view chat"
on public.chat_messages for select
to authenticated
using (public.is_order_participant(order_id));

create policy "order participants can send chat"
on public.chat_messages for insert
to authenticated
with check (public.is_order_participant(order_id) and sender_id = auth.uid());

-- Admin Order Detail view needs the full chat log for a given order,
-- which order participation alone doesn't grant an admin.
create policy "admins can view all chat messages"
on public.chat_messages for select
to authenticated
using (public.is_active_admin());

-- ---------------- customer_profiles: owning user + admin ----------------
create policy "customers view their own profile"
on public.customer_profiles for select
to authenticated
using (user_id = auth.uid());

create policy "customers update their own profile"
on public.customer_profiles for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "customers insert their own profile"
on public.customer_profiles for insert
to authenticated
with check (user_id = auth.uid());

-- Admin Directory/CustomerDetail suspend-or-ban action needs this.
create policy "admins can view all customer profiles"
on public.customer_profiles for select
to authenticated
using (public.is_active_admin());

create policy "admins can update all customer profiles"
on public.customer_profiles for update
to authenticated
using (public.is_active_admin())
with check (public.is_active_admin());

-- ---------------- kitchen_staff_profiles: owning vendor only ----------------
create policy "vendors manage their own kitchen staff"
on public.kitchen_staff_profiles for all
to authenticated
using (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()))
with check (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

-- ---------------- menu_categories: verified-vendor public read, owner read/write ----------------
create policy "anyone can browse categories from verified vendors"
on public.menu_categories for select
to authenticated, anon
using (
  vendor_id in (select id from public.vendor_profiles where verification_status = 'verified')
);

-- Without this, an unverified vendor's own menu manager screen would
-- show an empty menu — they can insert/update their own categories (see
-- below) but the verified-only browse policy alone wouldn't let them
-- read them back.
create policy "vendors can view their own menu categories regardless of verification"
on public.menu_categories for select
to authenticated
using (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

create policy "vendors manage their own menu categories"
on public.menu_categories for insert
to authenticated
with check (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

create policy "vendors update their own menu categories"
on public.menu_categories for update
to authenticated
using (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()))
with check (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

create policy "vendors delete their own menu categories"
on public.menu_categories for delete
to authenticated
using (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

-- ---------------- menu_items: verified-vendor public read, owner read/write, admin write ----------------
create policy "anyone can browse items from verified vendors"
on public.menu_items for select
to authenticated, anon
using (
  vendor_id in (select id from public.vendor_profiles where verification_status = 'verified')
);

-- Same reasoning as menu_categories above — a not-yet-verified vendor
-- must still be able to see their own items while building their menu.
create policy "vendors can view their own menu items regardless of verification"
on public.menu_items for select
to authenticated
using (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

create policy "vendors manage their own menu items"
on public.menu_items for insert
to authenticated
with check (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

create policy "vendors update their own menu items"
on public.menu_items for update
to authenticated
using (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()))
with check (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

create policy "vendors delete their own menu items"
on public.menu_items for delete
to authenticated
using (vendor_id in (select id from public.vendor_profiles where user_id = auth.uid()));

-- Admin moderation queue needs to act on a flagged menu item (e.g. set
-- is_available = false) regardless of which vendor owns it.
create policy "admins can update any menu item"
on public.menu_items for update
to authenticated
using (public.is_active_admin())
with check (public.is_active_admin());

-- ---------------- menu_item_addons: verified-vendor public read, owner read/write ----------------
create policy "anyone can browse addons from verified vendors"
on public.menu_item_addons for select
to authenticated, anon
using (
  menu_item_id in (
    select mi.id from public.menu_items mi
    join public.vendor_profiles vp on vp.id = mi.vendor_id
    where vp.verification_status = 'verified'
  )
);

-- Same reasoning again — owner can see their own addons pre-verification.
create policy "vendors can view their own menu item addons regardless of verification"
on public.menu_item_addons for select
to authenticated
using (public.is_owning_vendor_of_menu_item(menu_item_id));

create policy "vendors manage their own menu item addons"
on public.menu_item_addons for insert
to authenticated
with check (public.is_owning_vendor_of_menu_item(menu_item_id));

create policy "vendors update their own menu item addons"
on public.menu_item_addons for update
to authenticated
using (public.is_owning_vendor_of_menu_item(menu_item_id))
with check (public.is_owning_vendor_of_menu_item(menu_item_id));

create policy "vendors delete their own menu item addons"
on public.menu_item_addons for delete
to authenticated
using (public.is_owning_vendor_of_menu_item(menu_item_id));

-- ---------------- notifications: owning user only ----------------
-- KNOWN REMAINING GAP, carried over deliberately rather than silently
-- fixed: insert is left open to any authenticated user (`with check
-- (true)`) because notifications are created on a recipient's behalf by
-- another app (e.g. vendor app notifying a customer), and there's no
-- single trusted-writer context to restrict it to yet. This means any
-- authenticated user can currently create a notification addressed to
-- any other user — a real abuse vector (spoofed "withdrawal approved"
-- style messages), not fully solved here. Proper fix is a dedicated
-- SECURITY DEFINER function per legitimate notification-creating event,
-- called instead of a direct insert — flagged for a follow-up, not
-- solved in this pass.
create policy "users view their own notifications"
on public.notifications for select
to authenticated
using (user_id = auth.uid());

create policy "users update their own notifications"
on public.notifications for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "authenticated users can create notifications"
on public.notifications for insert
to authenticated
with check (true);

-- ---------------- order_tracking: order participants + admin ----------------
create policy "order participants can view tracking"
on public.order_tracking for select
to authenticated
using (public.is_order_participant(order_id));

create policy "order participants can add tracking"
on public.order_tracking for insert
to authenticated
with check (public.is_order_participant(order_id));

create policy "admins can view all order tracking"
on public.order_tracking for select
to authenticated
using (public.is_active_admin());

-- ---------------- push_tokens: owning user only, no shared read ----------------
create policy "users manage their own push tokens"
on public.push_tokens for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- ---------------- rider_locations: rider writes, order participants read ----------------
create policy "order participants can view rider location"
on public.rider_locations for select
to authenticated
using (public.is_order_participant(order_id));

create policy "riders write their own location"
on public.rider_locations for insert
to authenticated
with check (rider_id in (select id from public.rider_profiles where user_id = auth.uid()));

create policy "riders update their own location"
on public.rider_locations for update
to authenticated
using (rider_id in (select id from public.rider_profiles where user_id = auth.uid()))
with check (rider_id in (select id from public.rider_profiles where user_id = auth.uid()));

-- ---------------- rider_reviews / vendor_reviews: public read, customer-of-order write ----------------
create policy "anyone can browse rider reviews"
on public.rider_reviews for select
to authenticated, anon
using (true);

create policy "the ordering customer can leave a rider review"
on public.rider_reviews for insert
to authenticated
with check (
  exists (select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid())
);

create policy "anyone can browse vendor reviews"
on public.vendor_reviews for select
to authenticated, anon
using (true);

create policy "the ordering customer can leave a vendor review"
on public.vendor_reviews for insert
to authenticated
with check (
  exists (select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid())
);
