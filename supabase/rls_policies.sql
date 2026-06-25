-- EduVision Supabase RLS policies.
-- This file contains real SQL policies for the Supabase backend.
-- Run this only after schema.sql has been applied successfully.

-- ============================================================
-- ROLE HELPER FUNCTIONS
-- ============================================================

create or replace function public.current_app_user_role()
returns text
language sql
security definer
set search_path = public
stable
as $$
  select role
  from public.app_users
  where id = auth.uid()
    and is_active = true
  limit 1
$$;

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(public.current_app_user_role() = 'admin', false)
$$;

revoke all on function public.current_app_user_role() from public;
revoke all on function public.is_admin() from public;

grant execute on function public.current_app_user_role() to authenticated;
grant execute on function public.is_admin() to authenticated;