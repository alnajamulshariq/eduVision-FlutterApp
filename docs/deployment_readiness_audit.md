# Deployment Readiness Audit

Audit scope: final FYP deployment-readiness review only. No APK work, SQL
execution, Edge Function deployment, or secret inspection was performed.

## Current Git Verification

- Branch: `backend-supabase-setup`
- Working tree before audit: clean
- Latest verified commit before this audit: `e419b8e Add final SRS completion docs`
- Remote state: local branch was up to date with `origin/backend-supabase-setup`

## Deployment Readiness Status

The repository is FYP-demo ready after manual Supabase setup, Edge Function
deployment, and optional Python API startup. Production readiness still requires
real email provider configuration, real CV/embedding deployment, and full manual
device QA.

No critical blocker was found in the reviewed files. One documentation mismatch
was noted: the header comments in `supabase/schema.sql` still describe the file
as a planning draft, while final docs correctly treat it as the setup SQL to
review and apply manually. The safer interpretation is: review before applying,
then use it as the current setup source.

## Required Supabase SQL Checklist

Apply and verify these files manually:

1. `supabase/schema.sql`
2. `supabase/rls_policies.sql`
3. `supabase/seed_data.sql` if demo data is needed

Required tables and critical columns:

- `app_users`: `id`, `name`, `university_email`, `role`,
  `is_first_login`, `password_changed_once`, `is_active`, timestamps
- `departments`: `id`, `name`, `code`, timestamps
- `batches`: `id`, `name`, `year`, `department_id`, timestamps
- `semesters`: `id`, `name`, `number`, timestamps
- `subjects`: `id`, `name`, `code`, `department_id`, `semester_id`, timestamps
- `students`: `id`, `user_id`, `roll_no`, `name`, `department_id`,
  `batch_id`, `semester_id`, `parent_email`, `face_embedding_id`, `is_active`,
  timestamps
- `teachers`: `id`, `user_id`, `employee_id`, `name`, `department_id`,
  `is_active`, timestamps
- `face_embeddings`: `id`, `student_id`, `embedding_reference`, `provider`,
  `model_version`, `captured_at`, `is_active`, timestamps
- `teacher_subjects`: teacher, subject, department, batch, semester assignment
  columns plus `is_active` and timestamps
- `student_subjects`: student, subject, department, batch, semester enrollment
  columns plus `is_active` and timestamps
- `teacher_timetables`: teacher/class identifiers, `day`, `start_time`,
  `end_time`, `room`, `is_active`, timestamps
- `attendance_sessions`: class identifiers, `session_date`, `start_time`,
  `end_time`, `status`, timestamps
- `attendance_records`: `session_id`, `student_id`, `attendance_percentage`,
  `attendance_method`, `attendance_status`, `frames_detected`, `total_frames`,
  timestamps
- `gate_logs`: `student_id`, `log_date`, `log_time`, `status`,
  `gate_location`, `parent_email_sent`, timestamps
- `anonymous_messages`: `student_id`, `teacher_id`, `subject_id`, `message`,
  `status`, `is_reported`, `report_reason`, `resolved_at`, timestamps
- `message_reports`: `message_id`, `reported_by_teacher_id`, `reason`,
  `status`, `admin_reviewer_id`, `reviewed_at`, timestamps
- `system_activity_logs`: `actor_user_id`, `action`, `target_type`,
  `target_id`, `description`, `metadata`, `created_at`

Required schema helpers:

- `pgcrypto` extension
- `set_updated_at()` trigger function and table triggers
- indexes for auth lookup, attendance lookup, gate logs, messages, and system
  activity

## Required RLS Policies Checklist

Apply `supabase/rls_policies.sql` and verify these policy groups exist:

- Helper functions: `current_app_user_role()`, `is_admin()`,
  `current_student_id()`, `current_teacher_id()`
- `app_users`: self/admin select, self/admin password flag update
- Academic reads: authenticated select for departments, batches, semesters,
  subjects, students, teachers, teacher subjects, student subjects, and teacher
  timetables
- `face_embeddings`: admin-only select
- Attendance: authenticated select; teacher/admin insert and update for
  sessions and records
- `gate_logs`: authenticated select; admin insert and update
- `anonymous_messages`: student/teacher/admin select, student insert,
  teacher/admin update
- `message_reports`: admin or reporting teacher select, teacher insert,
  admin update
- `system_activity_logs`: admin select, admin insert with actor safety check

Risk note: teacher-facing anonymous message privacy is handled in Flutter query
selection, but production hardening should move sender-safe teacher views to a
dedicated view/RPC.

## Required Edge Functions Checklist

Deploy these functions manually:

```bash
supabase functions deploy send-parent-gate-email
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
supabase functions deploy admin-academic-write
```

Function purposes:

- `send-parent-gate-email`: verifies `gate_logs` and `students`, sends parent
  email through provider, updates `gate_logs.parent_email_sent`, and writes
  system activity rows for sent/failed/skipped statuses.
- `admin-create-user`: verifies signed-in admin caller, creates Supabase Auth
  user, inserts `app_users`, creates role profile rows, sets first-login flags,
  and writes system activity.
- `admin-reset-password`: verifies signed-in admin caller, resets Auth password,
  sets first-login flags again, and writes system activity.
- `admin-academic-write`: verifies signed-in admin caller, creates academic
  records, assigns teachers, enrolls students, and writes system activity.

## Required Secrets Checklist

Set these as Supabase Function secrets. Use placeholder names only in docs and
terminal examples:

- `SUPABASE_SERVICE_ROLE_KEY`
- `RESEND_API_KEY`
- `PARENT_EMAIL_FROM`

Do not put these values in Flutter, `.env`, `.env.local`, screenshots, logs, or
commits.

## Manual Deployment Commands

SQL setup:

```bash
# Run manually in Supabase SQL Editor or migration workflow:
supabase/schema.sql
supabase/rls_policies.sql
supabase/seed_data.sql
```

Secrets:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
supabase secrets set RESEND_API_KEY=your_resend_api_key
supabase secrets set PARENT_EMAIL_FROM=your_verified_sender
```

Functions:

```bash
supabase functions deploy send-parent-gate-email
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
supabase functions deploy admin-academic-write
```

Flutter emulator run:

```bash
flutter run -d emulator-5554 ^
  --dart-define=SUPABASE_URL=your_supabase_url ^
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key ^
  --dart-define=APP_ENV=development ^
  --dart-define=USE_MOCK_DATA=false
```

Optional Face API dart-define:

```bash
--dart-define=FACE_API_URL=http://10.0.2.2:8000
```

## Parent Email Setup Checklist

- Create or verify email provider account.
- Verify sender/domain used by `PARENT_EMAIL_FROM`.
- Set `RESEND_API_KEY` and `PARENT_EMAIL_FROM` in Supabase Function secrets.
- Deploy `send-parent-gate-email`.
- Scan a Gate Access QR.
- Confirm the gate log saves even if provider secrets are missing.
- Confirm `parent_email_sent` becomes `true` only after successful email.
- Confirm System Activity shows sent, failed, or skipped parent email event.

## Python API Demo And Production Checklist

Demo service:

```bash
cd python_api
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

Demo checks:

- `GET /health` returns `{"status":"ok"}`.
- `POST /attendance/process-session` accepts the documented contract.
- Flutter uses `FACE_API_URL=http://10.0.2.2:8000` on Android emulator.
- If the API is unavailable, Flutter fallback still saves attendance records.

Production replacement:

- Add real frame capture/upload handling.
- Add face detection and embedding generation.
- Add stored embedding lookup and similarity matching.
- Keep service secrets out of Flutter and this repo.

## Manual QA Priority Order

1. Auth launch: splash, unauthenticated login redirect, role dashboards.
2. Admin login.
3. Admin creates a user with temporary password.
4. First-login password change gate.
5. Admin password reset and forced password-change repeat.
6. Admin creates department, batch, semester, subject.
7. Admin assigns teacher and enrolls student.
8. Teacher active timetable validation.
9. Teacher creates attendance session.
10. Face Recognition demo/API flow.
11. Dynamic QR Attendance flow.
12. Student My Attendance verification.
13. Student Gate Access QR.
14. Admin Gate QR entry scan.
15. Admin Gate QR exit scan.
16. Student Gate History.
17. Teacher Gate Monitoring.
18. Parent email status.
19. Anonymous message send, resolve, report, and admin reveal.
20. Admin System Activity Monitoring.

## Mismatches And Risks Before FYP Demo

- `supabase/schema.sql` header still says planning/draft, but current docs use
  it as the manual setup source. Review before applying to the target project.
- Edge Function deployment and secret configuration are manual and not yet
  verified from this audit.
- Parent email live delivery depends on provider/domain verification.
- Python API is demo-only; production CV/embedding service is pending.
- Full manual emulator/device QA is still required.
- No APK build/signing was performed and none should be done in this pass.

## Final Recommendation

The next safe step is manual backend preparation: review and apply SQL to the
target Supabase project, configure secrets, deploy the four Edge Functions, then
run the manual QA priority order above. Do not start APK work until the manual
QA sequence passes.
