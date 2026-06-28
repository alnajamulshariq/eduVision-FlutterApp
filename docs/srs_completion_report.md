# SRS Completion Report

This report maps the EduVision SRS modules to the current Flutter, Supabase,
Edge Function, and Python demo implementation on `backend-supabase-setup`.

Status meanings:

- Complete: implemented in Flutter/backend code for FYP flow.
- Demo-ready: usable for FYP presentation with mock/demo fallback.
- Backend-ready: code exists, but Supabase SQL/functions must be applied/deployed.
- Pending external deployment: requires external provider, secrets, or hosted service.
- Pending production hardening: works for FYP, but should be hardened before real production data.

## Module Coverage

| SRS module | Requirement | Current status | Implementation files/commits | Remaining notes |
| --- | --- | --- | --- | --- |
| Authentication | Splash checks auth and routes to login/dashboard | Complete | `lib/features/splash/splash_screen.dart`, `lib/app/router.dart`; `d9bacf6` | Full device QA still required. |
| Authentication | University email/password login only | Complete | `lib/features/auth/login_screen.dart`, `lib/data/repositories/auth_repository.dart`; `719448d`, `d9bacf6` | No public signup screen is present. |
| Authentication | No-signup policy | Complete | `lib/features/auth/login_screen.dart`, admin-only creation in `supabase/functions/admin-create-user/index.ts`; `cf4fe42` | Admin-created accounts require deployed Edge Function. |
| Account Management | Admin creates students, teachers, and admins | Backend-ready | `lib/features/admin/screens/admin_users_screen.dart`, `lib/data/repositories/admin_repository.dart`, `supabase/functions/admin-create-user/index.ts`; `cf4fe42` | Requires `admin-create-user` deployment and `SUPABASE_SERVICE_ROLE_KEY`. |
| Account Management | Admin assigns temporary password | Backend-ready | `AdminCreateUserRequestModel`, `admin-create-user`; `cf4fe42` | Temporary passwords are never stored in app database. |
| Account Management | First-login password change once | Complete | `lib/features/auth/change_password_screen.dart`, `auth_repository.dart`, `app_user_model.dart`, router gate; `d9bacf6` | Uses `app_users.is_first_login` and `password_changed_once`. |
| Account Management | Forgotten password reset by Admin only | Backend-ready | `lib/features/admin/screens/admin_users_screen.dart`, `supabase/functions/admin-reset-password/index.ts`; `cf4fe42`, `d9bacf6` | Requires `admin-reset-password` deployment. |
| Academic Management | Create departments, batches, semesters, subjects | Backend-ready | `admin_academics_screen.dart`, `admin_repository.dart`, `admin-academic-write`; `cf4fe42` | Requires `admin-academic-write` deployment. |
| Academic Management | Assign teachers and enroll students | Backend-ready | `admin_academics_screen.dart`, `admin-academic-write`; `cf4fe42` | Requires current schema and RLS applied. |
| Smart Attendance | Teacher timetable validation | Complete | `lib/data/repositories/attendance_repository.dart`, `teacher_provider.dart`, `teacher_start_attendance_screen.dart`; `719448d`, `099c04e` | Depends on seeded/real timetable rows. |
| Smart Attendance | Attendance session creation | Complete | `attendance_repository.dart`, `teacher_start_attendance_screen.dart`; `719448d`, `099c04e` | Backend table exists in `supabase/schema.sql`. |
| Smart Attendance | Face recognition frame/percentage result support | Demo-ready | `face_api_service.dart`, `face_recognition_result_model.dart`, `attendance_repository.dart`; `099c04e`, `75aa7b4` | Real Python CV/embedding service remains pending. |
| Smart Attendance | Python API contract and demo scaffold | Demo-ready | `docs/face_recognition_api_contract.md`, `python_api/main.py`, `python_api/README.md`; `75aa7b4` | Optional local FastAPI demo; production CV must replace demo scoring. |
| Smart Attendance | Dynamic QR attendance fallback | Complete | `student_qr_screen.dart`, `teacher_qr_scanner_screen.dart`, `qr_token_service.dart`, `attendance_repository.dart`; `3064cb2`, `5682b2e`, `7a42c99` | Device camera/manual payload QA still required. |
| Gate Monitoring | Student dynamic Gate Access QR | Complete | `student_qr_screen.dart`, `qr_token_service.dart`; `7a42c99` | QR expiry/validation supported. |
| Gate Monitoring | Entry/exit alternation | Complete | `gate_repository.dart`, `admin_gate_qr_scanner_screen.dart`; `7a42c99`, `69c95ba` | Alternation uses previous gate activity. |
| Gate Monitoring | Parent email notification | Backend-ready, Pending external deployment | `gate_repository.dart`, `send-parent-gate-email`, `docs/parent_email_notifications.md`; `69c95ba`, `0a38e1b` | Requires Edge Function deployment, `RESEND_API_KEY`, `PARENT_EMAIL_FROM`, and verified email domain. |
| Gate Monitoring | Student Gate History | Complete | `student_gate_history_screen.dart`, `student_provider.dart`, `gate_repository.dart`; `7a42c99` | Backend data required for real history. |
| Gate Monitoring | Teacher Gate Monitoring | Complete | `teacher_gate_monitoring_screen.dart`, `teacher_provider.dart`, `gate_repository.dart`; `7a42c99` | Filtering is based on teacher/student academic relationships. |
| Anonymous Messaging | Student sends anonymous message | Complete | `student_anonymous_message_screen.dart`, `message_repository.dart`; `db7e109` | Real data requires RLS SQL applied. |
| Anonymous Messaging | Teacher reads anonymously | Complete | `teacher_anonymous_messages_screen.dart`, `_teacherMessageSelect` excludes student identity; `db7e109` | Production should use a hardened view/RPC to further protect identity. |
| Anonymous Messaging | Teacher resolves/reports | Complete | `teacher_anonymous_messages_screen.dart`, `message_repository.dart`; `db7e109` | Report rows stored in `message_reports`. |
| Anonymous Messaging | Admin investigates reported message and reveals sender | Complete, Pending production hardening | `admin_message_reports_screen.dart`, `message_repository.dart`; `db7e109` | FYP-ready; production sender reveal should be audited through secure RPC. |
| Reports | Attendance reports | Complete | `attendance_reports_content.dart`, `admin_attendance_reports_screen.dart`, `teacher_attendance_reports_screen.dart`; `719448d` | Full data QA still required. |
| Reports | Gate logs | Complete | `admin_gate_logs_screen.dart`, `gate_repository.dart`; `7a42c99` | Parent email status shown when function returns result. |
| Reports | Anonymous message reports | Complete | `admin_message_reports_screen.dart`, `message_repository.dart`; `db7e109` | Production sender reveal audit recommended. |
| Monitoring | Admin system activity monitoring | Backend-ready | `admin_system_activity_screen.dart`, `system_activity_log_model.dart`, `system_activity_logs` SQL, Edge Function log inserts; `0a38e1b` | Requires updated SQL and Edge Functions redeployed. |

## Honest Remaining Work

- Deploy Supabase Edge Functions: `send-parent-gate-email`,
  `admin-create-user`, `admin-reset-password`, `admin-academic-write`.
- Configure Supabase secrets: `SUPABASE_SERVICE_ROLE_KEY`, `RESEND_API_KEY`,
  and `PARENT_EMAIL_FROM`.
- Apply updated SQL/RLS if the deployed Supabase project does not already have
  the latest schema.
- Configure real Resend/email provider sender and verified domain.
- Replace the FastAPI demo scoring with a real Python OpenCV/embedding service
  for production.
- Run full manual device QA.
- APK build/signing is intentionally not part of this pass.
