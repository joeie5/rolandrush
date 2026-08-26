-- Fixes "infinite recursion detected in policy for relation admin_users":
-- the old policy sub-selected admin_users from within its own policy,
-- so every RLS check on the table re-triggered the same check.
-- A SECURITY DEFINER helper bypasses RLS internally, breaking the loop.

drop policy if exists "admins can view admin roster" on public.admin_users;

create or replace function public.is_active_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.admin_users au
    where au.user_id = auth.uid() and au.is_active
  );
$$;

create policy "admins can view admin roster"
on public.admin_users
for select
using ( public.is_active_admin() );
