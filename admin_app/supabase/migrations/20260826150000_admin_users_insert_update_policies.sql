-- Completes the admin_users RLS fix from 20260826000539_fix_admin_users_rls.sql.
-- That migration correctly fixed the infinite-recursion bug on SELECT
-- using a SECURITY DEFINER helper (is_active_admin(), reused as-is
-- below) — but only ever added a SELECT policy. With RLS enabled and no
-- INSERT/UPDATE policy, every write to this table is denied by default,
-- which silently breaks two things the admin app's AdminTeam.tsx already
-- does: inviting a new admin (insert) and disabling/restoring one
-- (update). This migration adds exactly those two policies. Nothing
-- above is being redone — is_active_admin() and the existing SELECT
-- policy are untouched.

-- ---------------- INSERT: an active admin can invite another admin ----------------
-- Note the deliberate asymmetry: this only lets you create a row for
-- SOMEONE ELSE (a new admin's user_id), not silently grant yourself a
-- higher role by inserting your own row a second time — combined with
-- the UNIQUE constraint already on admin_users.user_id, a user already
-- present can't insert again for themselves regardless.
create policy "active admins can invite new admins"
on public.admin_users
for insert
to authenticated
with check ( public.is_active_admin() );

-- ---------------- UPDATE: an active admin can disable/restore another admin, or edit a role ----------------
-- Same is_active_admin() gate on both sides (using + with check) so an
-- admin who is disabled mid-session can't use a request that was
-- already in flight to reactivate themselves or edit their own row
-- after the fact.
create policy "active admins can update admin records"
on public.admin_users
for update
to authenticated
using ( public.is_active_admin() )
with check ( public.is_active_admin() );

-- No DELETE policy added deliberately — disabling via is_active = false
-- (already supported by the UPDATE policy above) is the intended way to
-- revoke access, preserving the row for audit_log history. If hard
-- deletion is genuinely needed later, that's a separate decision to make
-- on purpose, not a default to fall into.

-- ---------------- Bootstrapping note (operational, not a policy) ----------------
-- If admin_users ever has zero rows, is_active_admin() can never return
-- true for anyone, so the very first admin can't be created through the
-- app itself — that first row must be inserted once manually (Supabase
-- SQL editor or a service-role script), e.g.:
--
--   insert into public.admin_users (user_id, role, is_active)
--   values ('<the founder's auth.users id>', 'super_admin', true);
--
-- This is expected and only needs to happen once per environment.
