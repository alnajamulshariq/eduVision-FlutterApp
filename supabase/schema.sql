-- EduVision Supabase schema draft.
-- Planning only: this file is not connected to the Flutter app yet.
-- Review RLS policies, auth integration, and production security before applying.

create extension if not exists pgcrypto;

create table if not exists app_users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  university_email text not null unique,
  role text not null check (role in ('student', 'teacher', 'admin')),
  is_first_login boolean not null default true,
  password_changed_once boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists departments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists batches (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  year integer not null check (year >= 2000),
  department_id uuid not null references departments(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name, department_id)
);

create table if not exists semesters (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  number integer not null check (number between 1 and 12),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (number)
);

create table if not exists subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  department_id uuid not null references departments(id) on delete restrict,
  semester_id uuid not null references semesters(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists students (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references app_users(id) on delete cascade,
  roll_no text not null unique,
  name text not null,
  department_id uuid not null references departments(id) on delete restrict,
  batch_id uuid not null references batches(id) on delete restrict,
  semester_id uuid not null references semesters(id) on delete restrict,
  parent_email text,
  face_embedding_id uuid,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists teachers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references app_users(id) on delete cascade,
  employee_id text not null unique,
  name text not null,
  department_id uuid not null references departments(id) on delete restrict,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists face_embeddings (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references students(id) on delete cascade,
  embedding_reference text not null,
  provider text not null default 'python_face_api',
  model_version text,
  captured_at timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table students
  drop constraint if exists students_face_embedding_id_fkey;

alter table students
  add constraint students_face_embedding_id_fkey
  foreign key (face_embedding_id) references face_embeddings(id) on delete set null;

create table if not exists teacher_subjects (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references teachers(id) on delete cascade,
  subject_id uuid not null references subjects(id) on delete cascade,
  department_id uuid not null references departments(id) on delete restrict,
  batch_id uuid not null references batches(id) on delete restrict,
  semester_id uuid not null references semesters(id) on delete restrict,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (teacher_id, subject_id, department_id, batch_id, semester_id)
);

create table if not exists student_subjects (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references students(id) on delete cascade,
  subject_id uuid not null references subjects(id) on delete cascade,
  department_id uuid not null references departments(id) on delete restrict,
  batch_id uuid not null references batches(id) on delete restrict,
  semester_id uuid not null references semesters(id) on delete restrict,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, subject_id, department_id, batch_id, semester_id)
);

create table if not exists teacher_timetables (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references teachers(id) on delete cascade,
  subject_id uuid not null references subjects(id) on delete cascade,
  department_id uuid not null references departments(id) on delete restrict,
  batch_id uuid not null references batches(id) on delete restrict,
  semester_id uuid not null references semesters(id) on delete restrict,
  day text not null check (
    day in (
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    )
  ),
  start_time time not null,
  end_time time not null,
  room text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_time < end_time)
);

create table if not exists attendance_sessions (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references teachers(id) on delete restrict,
  subject_id uuid not null references subjects(id) on delete restrict,
  department_id uuid not null references departments(id) on delete restrict,
  batch_id uuid not null references batches(id) on delete restrict,
  semester_id uuid not null references semesters(id) on delete restrict,
  session_date date not null,
  start_time time not null,
  end_time time not null,
  status text not null default 'active'
    check (status in ('active', 'completed', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_time < end_time)
);

create table if not exists attendance_records (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references attendance_sessions(id) on delete cascade,
  student_id uuid not null references students(id) on delete cascade,
  attendance_percentage numeric(5,2) not null
    check (attendance_percentage >= 0 and attendance_percentage <= 100),
  attendance_method text not null
    check (attendance_method in ('face_recognition', 'dynamic_qr', 'manual')),
  attendance_status text not null
    check (attendance_status in ('present', 'absent')),
  frames_detected integer check (frames_detected >= 0),
  total_frames integer check (total_frames >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (session_id, student_id),
  check (
    frames_detected is null
    or total_frames is null
    or frames_detected <= total_frames
  )
);

create table if not exists gate_logs (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references students(id) on delete cascade,
  log_date date not null,
  log_time time not null,
  status text not null check (status in ('entry', 'exit')),
  gate_location text not null,
  parent_email_sent boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists anonymous_messages (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references students(id) on delete cascade,
  teacher_id uuid not null references teachers(id) on delete cascade,
  subject_id uuid references subjects(id) on delete set null,
  message text not null,
  status text not null default 'new'
    check (status in ('new', 'resolved', 'reported')),
  is_reported boolean not null default false,
  report_reason text,
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists message_reports (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references anonymous_messages(id) on delete cascade,
  reported_by_teacher_id uuid not null references teachers(id) on delete restrict,
  reason text not null,
  status text not null default 'pending'
    check (status in ('pending', 'reviewed', 'safe', 'escalated')),
  admin_reviewer_id uuid references app_users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_app_users_updated_at on app_users;
create trigger set_app_users_updated_at
before update on app_users
for each row execute function set_updated_at();

drop trigger if exists set_departments_updated_at on departments;
create trigger set_departments_updated_at
before update on departments
for each row execute function set_updated_at();

drop trigger if exists set_batches_updated_at on batches;
create trigger set_batches_updated_at
before update on batches
for each row execute function set_updated_at();

drop trigger if exists set_semesters_updated_at on semesters;
create trigger set_semesters_updated_at
before update on semesters
for each row execute function set_updated_at();

drop trigger if exists set_subjects_updated_at on subjects;
create trigger set_subjects_updated_at
before update on subjects
for each row execute function set_updated_at();

drop trigger if exists set_students_updated_at on students;
create trigger set_students_updated_at
before update on students
for each row execute function set_updated_at();

drop trigger if exists set_teachers_updated_at on teachers;
create trigger set_teachers_updated_at
before update on teachers
for each row execute function set_updated_at();

drop trigger if exists set_face_embeddings_updated_at on face_embeddings;
create trigger set_face_embeddings_updated_at
before update on face_embeddings
for each row execute function set_updated_at();

drop trigger if exists set_teacher_subjects_updated_at on teacher_subjects;
create trigger set_teacher_subjects_updated_at
before update on teacher_subjects
for each row execute function set_updated_at();

drop trigger if exists set_student_subjects_updated_at on student_subjects;
create trigger set_student_subjects_updated_at
before update on student_subjects
for each row execute function set_updated_at();

drop trigger if exists set_teacher_timetables_updated_at on teacher_timetables;
create trigger set_teacher_timetables_updated_at
before update on teacher_timetables
for each row execute function set_updated_at();

drop trigger if exists set_attendance_sessions_updated_at on attendance_sessions;
create trigger set_attendance_sessions_updated_at
before update on attendance_sessions
for each row execute function set_updated_at();

drop trigger if exists set_attendance_records_updated_at on attendance_records;
create trigger set_attendance_records_updated_at
before update on attendance_records
for each row execute function set_updated_at();

drop trigger if exists set_gate_logs_updated_at on gate_logs;
create trigger set_gate_logs_updated_at
before update on gate_logs
for each row execute function set_updated_at();

drop trigger if exists set_anonymous_messages_updated_at on anonymous_messages;
create trigger set_anonymous_messages_updated_at
before update on anonymous_messages
for each row execute function set_updated_at();

drop trigger if exists set_message_reports_updated_at on message_reports;
create trigger set_message_reports_updated_at
before update on message_reports
for each row execute function set_updated_at();

create index if not exists app_users_university_email_idx
  on app_users (university_email);

create index if not exists students_user_id_idx
  on students (user_id);

create index if not exists teachers_user_id_idx
  on teachers (user_id);

create index if not exists attendance_records_student_id_idx
  on attendance_records (student_id);

create index if not exists attendance_records_session_id_idx
  on attendance_records (session_id);

create index if not exists gate_logs_student_id_idx
  on gate_logs (student_id);

create index if not exists anonymous_messages_teacher_id_idx
  on anonymous_messages (teacher_id);

create index if not exists anonymous_messages_student_id_idx
  on anonymous_messages (student_id);

create index if not exists message_reports_message_id_idx
  on message_reports (message_id);

create index if not exists teacher_timetables_teacher_id_idx
  on teacher_timetables (teacher_id);

create index if not exists teacher_subjects_teacher_id_idx
  on teacher_subjects (teacher_id);

create index if not exists student_subjects_student_id_idx
  on student_subjects (student_id);

create index if not exists attendance_sessions_lookup_idx
  on attendance_sessions (
    teacher_id,
    subject_id,
    department_id,
    batch_id,
    semester_id,
    session_date
  );
