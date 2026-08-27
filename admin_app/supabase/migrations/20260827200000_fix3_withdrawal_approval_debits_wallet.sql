-- Fixes a real, previously undiscovered bug: approving a withdrawal in
-- the admin dashboard only ever flipped withdrawal_requests.status —
-- it never actually deducted the vendor/rider's wallets.balance or
-- recorded a transaction. A vendor could get 3 withdrawals "approved"
-- and their available balance would never move. Found by comparing the
-- admin dashboard's Withdrawals page (3 approved) against the vendor
-- app's own wallet screen (still showing the original balance, "Total
-- Withdrawn" stuck at ₦0).
--
-- Also fixes: wallets.total_withdrawn does not exist as a column in the
-- live schema at all — the vendor app's VendorWallet model assumed it
-- did (a stale assumption from earlier in the project, never actually
-- true), which is the other reason that stat was always 0 regardless of
-- anything. Adding it for real here rather than leaving the Dart model
-- pointed at a column that doesn't exist.

alter table public.wallets add column if not exists total_withdrawn numeric not null default 0;

-- ============================================================
-- The RPC: atomically approves a withdrawal request AND debits the
-- requester's wallet. SECURITY DEFINER so it can write to someone
-- else's wallet (the admin approving is not the wallet owner) — the
-- is_active_admin() check inside is what makes that safe, same pattern
-- as complete_delivery_and_credit().
-- ============================================================

create or replace function public.approve_withdrawal_and_debit(p_withdrawal_id uuid, p_admin_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request record;
begin
  if not public.is_active_admin() then
    raise exception 'Only an active admin can approve a withdrawal.';
  end if;

  select * into v_request from public.withdrawal_requests where id = p_withdrawal_id for update;

  if v_request.id is null then
    raise exception 'Withdrawal request not found.';
  end if;

  if v_request.status <> 'pending' then
    raise exception 'This withdrawal has already been decided.';
  end if;

  -- Lock the wallet row for the duration of this transaction so a
  -- double-click / concurrent approval can't double-debit.
  perform 1 from public.wallets where user_id = v_request.user_id for update;

  update public.wallets
  set balance = balance - v_request.amount,
      total_withdrawn = total_withdrawn + v_request.amount
  where user_id = v_request.user_id;

  update public.withdrawal_requests
  set status = 'approved',
      reviewed_by = p_admin_id,
      reviewed_at = now()
  where id = p_withdrawal_id;

  -- type must be 'debit' (not 'withdrawal') — the vendor/rider wallet
  -- screens key their outgoing/incoming styling off `tx.type == 'debit'`
  -- exactly; anything else silently renders an outgoing withdrawal as if
  -- it were an incoming credit.
  insert into public.transactions (user_id, amount, type)
  values (v_request.user_id, v_request.amount, 'debit');
end;
$$;

revoke all on function public.approve_withdrawal_and_debit(uuid, uuid) from public;
grant execute on function public.approve_withdrawal_and_debit(uuid, uuid) to authenticated;
