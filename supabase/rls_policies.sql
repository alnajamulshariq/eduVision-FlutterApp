-- EduVision Supabase RLS Policies and Grants
-- Run this file after supabase/schema.sql.
-- Purpose: make manually applied Supabase grants/RLS reproducible.

-- =========================================================
-- BASIC GRANTS
-- =========================================================

grant usage on schema public to authenticated;

grant select on table
  public.app_users,
  public.departments,
  public.batches,
  public.semesters,
  public.subjects,
  public.students,
  public.teachers,
  public.face_embeddings,
  public.teacher_subjects,
  public.student_subjects,
  public.teacher_timetables,
  public.system_activity_logs
to authenticated;

grant insert on table
  public.system_activity_logs
to authenticated;

grant update (is_first_login, password_changed_once, updated_at)
on public.app_users
to authenticated;

grant select, insert, update on table
  public.attendance_sessions,
  public.attendance_records,
  public.gate_logs,
  public.anonymous_messages,
  public.message_reports
to authenticated;

-- =========================================================
-- ROLE HELPER FUNCTIONS
-- =========================================================

create or replace function public.current_app_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role
  from public.app_users
  where id = auth.uid()
    and is_active = true
  limit 1;
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_app_user_role() = 'admin', false);
$$;

create or replace function public.current_student_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id
  from public.students
  where user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_teacher_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id
  from public.teachers
  where user_id = auth.uid()
  limit 1;
$$;

revoke all on function public.current_app_user_role() from public;
revoke all on function public.is_admin() from public;
revoke all on function public.current_student_id() from public;
revoke all on function public.current_teacher_id() from public;

grant execute on function public.current_app_user_role() to authenticated;
grant execute on function public.is_admin() to authenticated;
grant execute on function public.current_student_id() to authenticated;
grant execute on function public.current_teacher_id() to authenticated;

-- =========================================================
-- ENABLE RLS
-- =========================================================

alter table public.app_users enable row level security;
alter table public.departments enable row level security;
alter table public.batches enable row level security;
alter table public.semesters enable row level security;
alter table public.subjects enable row level security;
alter table public.students enable row level security;
alter table public.teachers enable row level security;
alter table public.face_embeddings enable row level security;
alter table public.teacher_subjects enable row level security;
alter table public.student_subjects enable row level security;
alter table public.teacher_timetables enable row level security;
alter table public.attendance_sessions enable row level security;
alter table public.attendance_records enable row level security;
alter table public.gate_logs enable row level security;
alter table public.anonymous_messages enable row level security;
alter table public.message_reports enable row level security;
alter table public.system_activity_logs enable row level security;

-- =========================================================
-- DROP OLD POLICIES
-- =========================================================

drop policy if exists "ev_app_users_select_self_or_admin" on public.app_users;
drop policy if exists "ev_app_users_update_self_password_flags" on public.app_users;

drop policy if exists "ev_departments_select_authenticated" on public.departments;
drop policy if exists "ev_batches_select_authenticated" on public.batches;
drop policy if exists "ev_semesters_select_authenticated" on public.semesters;
drop policy if exists "ev_subjects_select_authenticated" on public.subjects;

drop policy if exists "ev_students_select_authenticated" on public.students;
drop policy if exists "ev_teachers_select_authenticated" on public.teachers;
drop policy if exists "ev_face_embeddings_select_admin_only" on public.face_embeddings;

drop policy if exists "ev_teacher_subjects_select_authenticated" on public.teacher_subjects;
drop policy if exists "ev_student_subjects_select_authenticated" on public.student_subjects;
drop policy if exists "ev_teacher_timetables_select_authenticated" on public.teacher_timetables;

drop policy if exists "ev_attendance_sessions_select_authenticated" on public.attendance_sessions;
drop policy if exists "ev_attendance_sessions_insert_teacher_or_admin" on public.attendance_sessions;
drop policy if exists "ev_attendance_sessions_update_teacher_or_admin" on public.attendance_sessions;

drop policy if exists "ev_attendance_records_select_authenticated" on public.attendance_records;
drop policy if exists "ev_attendance_records_insert_teacher_or_admin" on public.attendance_records;
drop policy if exists "ev_attendance_records_update_teacher_or_admin" on public.attendance_records;

drop policy if exists "ev_gate_logs_select_authenticated" on public.gate_logs;
drop policy if exists "ev_gate_logs_insert_admin" on public.gate_logs;
drop policy if exists "ev_gate_logs_update_admin" on public.gate_logs;

drop policy if exists "ev_anonymous_messages_select_authenticated" on public.anonymous_messages;
drop policy if exists "ev_anonymous_messages_insert_student" on public.anonymous_messages;
drop policy if exists "ev_anonymous_messages_update_teacher_or_admin" on public.anonymous_messages;

drop policy if exists "ev_message_reports_select_authenticated" on public.message_reports;
drop policy if exists "ev_message_reports_insert_teacher" on public.message_reports;
drop policy if exists "ev_message_reports_update_admin" on public.message_reports;

drop policy if exists "ev_system_activity_logs_select_admin" on public.system_activity_logs;
drop policy if exists "ev_system_activity_logs_insert_admin" on public.system_activity_logs;

-- =========================================================
-- APP USERS
-- =========================================================

create policy "ev_app_users_select_self_or_admin"
on public.app_users
for select
to authenticated
using (
  id = auth.uid()
  or public.is_admin()
);

create policy "ev_app_users_update_self_password_flags"
on public.app_users
for update
to authenticated
using (
  id = auth.uid()
  or public.is_admin()
)
with check (
  id = auth.uid()
  or public.is_admin()
);

-- =========================================================
-- ACADEMIC READ POLICIES
-- =========================================================

create policy "ev_departments_select_authenticated"
on public.departments
for select
to authenticated
using (true);

create policy "ev_batches_select_authenticated"
on public.batches
for select
to authenticated
using (true);

create policy "ev_semesters_select_authenticated"
on public.semesters
for select
to authenticated
using (true);

create policy "ev_subjects_select_authenticated"
on public.subjects
for select
to authenticated
using (true);

create policy "ev_students_select_authenticated"
on public.students
for select
to authenticated
using (true);

create policy "ev_teachers_select_authenticated"
on public.teachers
for select
to authenticated
using (true);

create policy "ev_face_embeddings_select_admin_only"
on public.face_embeddings
for select
to authenticated
using (public.is_admin());

create policy "ev_teacher_subjects_select_authenticated"
on public.teacher_subjects
for select
to authenticated
using (true);

create policy "ev_student_subjects_select_authenticated"
on public.student_subjects
for select
to authenticated
using (true);

create policy "ev_teacher_timetables_select_authenticated"
on public.teacher_timetables
for select
to authenticated
using (true);

-- =========================================================
-- ATTENDANCE
-- =========================================================

create policy "ev_attendance_sessions_select_authenticated"
on public.attendance_sessions
for select
to authenticated
using (true);

create policy "ev_attendance_sessions_insert_teacher_or_admin"
on public.attendance_sessions
for insert
to authenticated
with check (
  public.is_admin()
  or teacher_id = public.current_teacher_id()
);

create policy "ev_attendance_sessions_update_teacher_or_admin"
on public.attendance_sessions
for update
to authenticated
using (
  public.is_admin()
  or teacher_id = public.current_teacher_id()
)
with check (
  public.is_admin()
  or teacher_id = public.current_teacher_id()
);

create policy "ev_attendance_records_select_authenticated"
on public.attendance_records
for select
to authenticated
using (true);

create policy "ev_attendance_records_insert_teacher_or_admin"
on public.attendance_records
for insert
to authenticated
with check (
  public.is_admin()
  or exists (
    select 1
    from public.attendance_sessions s
    where s.id = attendance_records.session_id
      and s.teacher_id = public.current_teacher_id()
  )
);

create policy "ev_attendance_records_update_teacher_or_admin"
on public.attendance_records
for update
to authenticated
using (
  public.is_admin()
  or exists (
    select 1
    from public.attendance_sessions s
    where s.id = attendance_records.session_id
      and s.teacher_id = public.current_teacher_id()
  )
)
with check (
  public.is_admin()
  or exists (
    select 1
    from public.attendance_sessions s
    where s.id = attendance_records.session_id
      and s.teacher_id = public.current_teacher_id()
  )
);

-- =========================================================
-- GATE LOGS
-- =========================================================

create policy "ev_gate_logs_select_authenticated"
on public.gate_logs
for select
to authenticated
using (true);

create policy "ev_gate_logs_insert_admin"
on public.gate_logs
for insert
to authenticated
with check (public.is_admin());

create policy "ev_gate_logs_update_admin"
on public.gate_logs
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- =========================================================
-- ANONYMOUS MESSAGES
-- =========================================================
-- Note: Teacher-safe anonymous viewing should later use a view/RPC
-- that does not expose student_id to teachers.

create policy "ev_anonymous_messages_select_authenticated"
on public.anonymous_messages
for select
to authenticated
using (
  public.is_admin()
  or student_id = public.current_student_id()
  or teacher_id = public.current_teacher_id()
);

create policy "ev_anonymous_messages_insert_student"
on public.anonymous_messages
for insert
to authenticated
with check (
  student_id = public.current_student_id()
);

create policy "ev_anonymous_messages_update_teacher_or_admin"
on public.anonymous_messages
for update
to authenticated
using (
  public.is_admin()
  or teacher_id = public.current_teacher_id()
)
with check (
  public.is_admin()
  or teacher_id = public.current_teacher_id()
);

-- =========================================================
-- MESSAGE REPORTS
-- =========================================================

create policy "ev_message_reports_select_authenticated"
on public.message_reports
for select
to authenticated
using (
  public.is_admin()
  or reported_by_teacher_id = public.current_teacher_id()
);

create policy "ev_message_reports_insert_teacher"
on public.message_reports
for insert
to authenticated
with check (
  reported_by_teacher_id = public.current_teacher_id()
);

create policy "ev_message_reports_update_admin"
on public.message_reports
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- =========================================================
-- SYSTEM ACTIVITY LOGS
-- =========================================================

create policy "ev_system_activity_logs_select_admin"
on public.system_activity_logs
for select
to authenticated
using (public.is_admin());

create policy "ev_system_activity_logs_insert_admin"
on public.system_activity_logs
for insert
to authenticated
with check (
  public.is_admin()
  and (
    actor_user_id is null
    or actor_user_id = auth.uid()
  )
);
