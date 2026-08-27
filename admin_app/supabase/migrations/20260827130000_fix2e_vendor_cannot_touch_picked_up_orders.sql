-- Closes a real gap: the existing "Vendors can update their own orders"
-- policy only checked vendor_id ownership, with no constraint on the
-- order's current status. That meant a vendor could cancel (or otherwise
-- modify) an order via a direct API call even after a rider had already
-- picked it up — the UI-level `vendorCancellable` check in
-- order_detail_screen.dart is not a security boundary on its own, only
-- RLS is. Once status reaches picked_up/delivering/delivered, the order
-- is rider-owned; the vendor should have zero write access to it, not
-- just a hidden Cancel button.

drop policy if exists "Vendors can update their own orders" on public.orders;
create policy "Vendors can update their own orders"
on public.orders
for update
to authenticated
using (
  vendor_id in (select id from public.vendor_profiles where user_id = auth.uid())
  and status not in ('picked_up', 'delivering', 'delivered')
);
