-- FIX 2, PART 2: transactions + withdrawal_requests + wallets.
--
-- APPLY THIS AFTER 20260826220000_fix2_rls_lockdown.sql, AND ONLY AFTER
-- updating the rider app's delivery-completion code
-- (active_delivery_provider.dart's confirmDeliveryWithOtp/advanceStep) to
-- call the RPC below via
-- `supabase.rpc('complete_delivery_and_credit', {p_order_id: orderId, p_otp: enteredOtp})`
-- INSTEAD OF directly inserting into transactions / updating wallets.
-- If that app-code change isn't made first, delivery completion will
-- start failing outright once this runs, because the direct cross-user
-- writes it currently does will be blocked by the RLS policies below.
--
-- WHY THIS NEEDS AN RPC AND NOT JUST A POLICY: the rider crediting the
-- VENDOR's wallet (and their own) on delivery completion is a legitimate
-- cross-user write, but there is no safe RLS policy that expresses "a
-- user may write to a DIFFERENT user's wallet, but only this specific
-- amount, only once, only for an order they're actually delivering, and
-- only if they can prove the customer actually received it." That logic
-- has to live in a function, not a policy.

-- ============================================================
-- The RPC: does the vendor + rider payout atomically, with its own
-- internal authorization AND anti-fraud check (this function bypasses
-- RLS via SECURITY DEFINER, so everything inside it IS the security
-- boundary — there is no policy backing it up).
-- ============================================================

create or replace function public.complete_delivery_and_credit(p_order_id uuid, p_otp text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order record;
  v_commission numeric;
  v_vendor_payout numeric;
  v_rider_payout numeric;
begin
  -- Lock the order row for the duration of this transaction so two
  -- near-simultaneous calls (e.g. a double-tap on "complete delivery")
  -- can't both pass the checks below.
  select o.*, rp.user_id as rider_user_id, vp.user_id as vendor_user_id
  into v_order
  from public.orders o
  join public.rider_profiles rp on rp.id = o.rider_id
  join public.vendor_profiles vp on vp.id = o.vendor_id
  where o.id = p_order_id
  for update of o;

  if v_order.id is null then
    raise exception 'Order not found, or has no vendor/rider assigned yet.';
  end if;

  -- Authorization boundary #1: only the rider actually assigned to this
  -- order may trigger its payout.
  if v_order.rider_user_id is distinct from auth.uid() then
    raise exception 'Only the assigned rider can complete this delivery.';
  end if;

  -- Authorization boundary #2 — the anti-fraud check the OTP field
  -- exists for in the first place: the client-side confirmDeliveryWithOtp
  -- check alone isn't a security boundary, since this function bypasses
  -- RLS and could be called directly (e.g. via the REST/RPC endpoint)
  -- without ever going through the app's own OTP screen. Re-verify here.
  if v_order.delivery_otp is null or v_order.delivery_otp is distinct from p_otp then
    raise exception 'Incorrect delivery code.';
  end if;

  -- Idempotency: refuse to pay out twice if this is called again
  -- (network retry, double-tap, etc).
  if v_order.status = 'delivered' then
    raise exception 'This order has already been marked delivered.';
  end if;

  -- coalesce(subtotal, 0) rather than falling back to summing `items`
  -- (as the Dart-side DeliveryOrder.effectiveSubtotal does) — every order
  -- placed through the current checkout flow sets subtotal, so this only
  -- matters for pre-existing orders from before that was wired up, which
  -- would pay the vendor 0 rather than the item-derived estimate the app
  -- would show. Acceptable for now since it only affects legacy rows,
  -- but flagged rather than silently assumed equivalent.
  v_commission := coalesce(v_order.subtotal, 0) * coalesce(v_order.commission_rate_applied, 0.15);
  v_vendor_payout := coalesce(v_order.subtotal, 0) - v_commission;
  v_rider_payout := coalesce(v_order.delivery_fee, 0);

  update public.orders
  set status = 'delivered',
      commission_amount = v_commission,
      delivered_at = now()
  where id = p_order_id;

  -- Vendor payout
  insert into public.transactions (user_id, order_id, amount, type)
  values (v_order.vendor_user_id, p_order_id, v_vendor_payout, 'vendor_payout');

  insert into public.wallets (user_id, balance, total_earned)
  values (v_order.vendor_user_id, v_vendor_payout, v_vendor_payout)
  on conflict (user_id) do update
    set balance = public.wallets.balance + excluded.balance,
        total_earned = public.wallets.total_earned + excluded.total_earned;

  -- Rider payout
  insert into public.transactions (user_id, order_id, amount, type)
  values (v_order.rider_user_id, p_order_id, v_rider_payout, 'rider_payout');

  insert into public.wallets (user_id, balance, total_earned)
  values (v_order.rider_user_id, v_rider_payout, v_rider_payout)
  on conflict (user_id) do update
    set balance = public.wallets.balance + excluded.balance,
        total_earned = public.wallets.total_earned + excluded.total_earned;
end;
$$;

-- Deliberately narrow: only authenticated users can call this at all,
-- and the internal checks above narrow it further to the actual
-- assigned rider with the correct OTP. Nobody else (including anon)
-- gets execute access.
revoke all on function public.complete_delivery_and_credit(uuid, text) from public;
grant execute on function public.complete_delivery_and_credit(uuid, text) to authenticated;

-- NOTE: this assumes wallets.user_id has a unique constraint (required
-- for the ON CONFLICT upsert above to work — without one, this function
-- will fail at the first insert). Confirm this before running; add
-- `alter table public.wallets add constraint wallets_user_id_key unique (user_id);`
-- first if it's missing.

-- ============================================================
-- Now safe to lock down the tables — direct cross-user writes are no
-- longer needed by any app; they go through the RPC above instead.
-- ============================================================

alter table public.transactions enable row level security;
alter table public.withdrawal_requests enable row level security;

-- ---------------- transactions: owning user can read; writes only via the RPC above ----------------
create policy "users view their own transactions"
on public.transactions for select
to authenticated
using (user_id = auth.uid());

-- No direct INSERT policy for regular users on purpose — the only
-- legitimate way a transaction row gets created for someone else's
-- payout is complete_delivery_and_credit(), which bypasses RLS via
-- SECURITY DEFINER. transactions should only ever be created by trusted
-- server-side/RPC logic, never by a client inserting its own record of
-- what happened.

create policy "admins can view all transactions"
on public.transactions for select
to authenticated
using (public.is_active_admin());

-- ---------------- withdrawal_requests: owner + admin ----------------
create policy "users view their own withdrawal requests"
on public.withdrawal_requests for select
to authenticated
using (user_id = auth.uid());

create policy "users create their own withdrawal requests"
on public.withdrawal_requests for insert
to authenticated
with check (user_id = auth.uid());

create policy "admins can view all withdrawal requests"
on public.withdrawal_requests for select
to authenticated
using (public.is_active_admin());

create policy "admins can update all withdrawal requests"
on public.withdrawal_requests for update
to authenticated
using (public.is_active_admin())
with check (public.is_active_admin());
