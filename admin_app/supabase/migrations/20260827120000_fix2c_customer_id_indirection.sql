-- Corrects a wrong assumption baked into 20260826220000_fix2_rls_lockdown.sql:
-- is_order_participant() and the rider_reviews/vendor_reviews insert
-- checks all treated `orders.customer_id = auth.uid()` directly. That's
-- wrong — orders.customer_id foreign-keys to customer_profiles.id, a
-- separate generated PK, not the customer's auth user id. This was only
-- caught by actually tracing a real order through the schema end to end
-- (the checkout flow itself had the same wrong assumption — see the
-- matching fix in customer_app's checkout_provider.dart / orders_provider.dart /
-- customer_profile_provider.dart, committed alongside this).
--
-- vendor_id/rider_id were already correct (they reference vendor_profiles.id
-- / rider_profiles.id respectively, matching how the vendor/rider apps'
-- own code already resolves them) — only the customer side needed fixing.

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
        o.customer_id in (select id from public.customer_profiles where user_id = auth.uid())
        or o.vendor_id in (select id from public.vendor_profiles where user_id = auth.uid())
        or o.rider_id in (select id from public.rider_profiles where user_id = auth.uid())
      )
  );
$$;

drop policy if exists "the ordering customer can leave a rider review" on public.rider_reviews;
create policy "the ordering customer can leave a rider review"
on public.rider_reviews for insert
to authenticated
with check (
  exists (
    select 1 from public.orders o
    where o.id = order_id
      and o.customer_id in (select id from public.customer_profiles where user_id = auth.uid())
  )
);

drop policy if exists "the ordering customer can leave a vendor review" on public.vendor_reviews;
create policy "the ordering customer can leave a vendor review"
on public.vendor_reviews for insert
to authenticated
with check (
  exists (
    select 1 from public.orders o
    where o.id = order_id
      and o.customer_id in (select id from public.customer_profiles where user_id = auth.uid())
  )
);
