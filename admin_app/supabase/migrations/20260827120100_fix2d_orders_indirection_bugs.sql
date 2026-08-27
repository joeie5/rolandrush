-- Fixes pre-existing bugs in `orders`' own INSERT/SELECT/UPDATE policies
-- (not written as part of Fix 2 — these predate it and were never
-- touched by 20260826220000_fix2_rls_lockdown.sql, which only ADDED
-- admin policies to this table). Found by actually tracing a real order
-- through checkout -> vendor -> rider end to end, per both fixes' own
-- "verify by testing" instructions.
--
-- Bug 1: "Customers can create orders" / "Customers can view own orders"
-- both check `auth.uid() = customer_id`. But orders.customer_id
-- foreign-keys to customer_profiles.id — a separate generated PK, not
-- the customer's auth user id. Every real checkout attempt fails this
-- INSERT check outright (confirmed by testing it directly). Matching
-- app-code fix: customer_app's checkout_provider.dart / orders_provider.dart
-- now resolve customer_profiles.id via ensureCustomerProfileId() instead
-- of writing/querying by auth.uid().
--
-- Bug 2: "Riders can view available orders" / "Riders can claim and
-- update orders" both check `rider_id = auth.uid() OR rider_id IS NULL`.
-- orders.rider_id foreign-keys to rider_profiles.id, not auth.uid()
-- directly (same shape of bug as #1, on the rider side). The `rider_id
-- IS NULL` half is why accepting a job appeared to work in earlier
-- testing — but once a rider is assigned, rider_id holds their
-- rider_profiles.id, which never equals their auth.uid(), so the rider
-- can claim a job but can NEVER advance it past step 1 through a plain
-- client update (active_delivery_provider.dart's advanceStep for steps
-- 2-3) — this was a live, blocking bug in the delivery flow.
--
-- Note: vendor_id's existing policies already correctly resolve through
-- vendor_profiles (checked, not touched here) — only customer_id and
-- rider_id had this bug.

drop policy if exists "Customers can create orders" on public.orders;
create policy "Customers can create orders"
on public.orders
for insert
to authenticated
with check (
  customer_id in (select id from public.customer_profiles where user_id = auth.uid())
);

drop policy if exists "Customers can view own orders" on public.orders;
create policy "Customers can view own orders"
on public.orders
for select
to authenticated
using (
  customer_id in (select id from public.customer_profiles where user_id = auth.uid())
);

drop policy if exists "Riders can view available orders" on public.orders;
create policy "Riders can view available orders"
on public.orders
for select
to authenticated
using (
  rider_id in (select id from public.rider_profiles where user_id = auth.uid())
  or rider_id is null
);

drop policy if exists "Riders can claim and update orders" on public.orders;
create policy "Riders can claim and update orders"
on public.orders
for update
to authenticated
using (
  rider_id in (select id from public.rider_profiles where user_id = auth.uid())
  or rider_id is null
);
