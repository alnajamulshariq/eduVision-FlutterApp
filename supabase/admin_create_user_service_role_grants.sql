-- EduVision manual SQL fix for admin-create-user Edge Function writes.
-- Run in Supabase SQL Editor after supabase/schema.sql and supabase/rls_policies.sql.
--
-- Why this exists:
-- The admin-create-user Edge Function uses SUPABASE_SERVICE_ROLE_KEY server-side,
-- but PostgREST still requires object privileges for the service_role database role.
-- Without these grants, app_users insert/update can fail with:
-- 42501 | permission denied for table app_users
--
-- This does not grant anon/authenticated direct admin write access.
--
-- Note:
-- The current live database does not have public.system_activity_logs, so it is
-- intentionally not included here. Add a separate grant later if that table is
-- created in the live database.

grant usage on schema public to service_role;

grant insert on table
  public.app_users,
  public.students,
  public.teachers
to service_role;

grant select (id) on table public.app_users to service_role;

grant update (is_first_login, password_changed_once)
on table public.app_users
to service_role;

-- Required by admin-academic-write when it writes academic setup records
-- through the server-side service-role PostgREST client.
grant insert on table
  public.departments,
  public.batches,
  public.semesters,
  public.subjects,
  public.teacher_subjects,
  public.student_subjects
to service_role;

grant select (id) on table
  public.departments,
  public.batches,
  public.semesters,
  public.subjects,
  public.teacher_subjects,
  public.student_subjects
to service_role;

grant update (
  teacher_id,
  subject_id,
  department_id,
  batch_id,
  semester_id,
  is_active
)
on table public.teacher_subjects
to service_role;

grant update (
  student_id,
  subject_id,
  department_id,
  batch_id,
  semester_id,
  is_active
)
on table public.student_subjects
to service_role;
