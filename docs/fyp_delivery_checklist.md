# FYP Delivery Checklist

## Completed Modules

- Supabase Auth login with role-based dashboards
- Secure admin user creation through Edge Function
- Secure admin password reset through Edge Function
- First-login password change gate
- Admin academic writes through Edge Function
- Admin system activity monitoring
- Teacher attendance session flow
- Face Recognition API foundation with fallback
- Optional Python Face API demo scaffold
- Dynamic QR attendance
- Gate QR entry and exit
- Parent gate email notification status
- Anonymous student-to-teacher messaging
- Attendance and admin reports

## Demo Steps

1. Start the Flutter app with Supabase dart-defines.
2. Login as Admin.
3. Create a department, batch, semester, and subject.
4. Create a student, teacher, or admin account with a temporary password.
5. Login as the created user and complete first-login password change.
6. Reset that user's password as Admin and confirm first-login change is required again.
7. Assign a teacher and enroll a student.
8. Open System Activity and confirm recent admin actions appear.
9. Login as Teacher and create an attendance session.
10. Run Face Recognition attendance with fallback or Python API.
11. Run Dynamic QR attendance.
12. Scan student gate QR for entry and exit.
13. Confirm parent email status appears on gate screens.
14. Submit and review anonymous messages.
15. Open reports and confirm records are visible.

## Required Edge Function Deployments

```bash
supabase functions deploy send-parent-gate-email
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
supabase functions deploy admin-academic-write
```

## Required Supabase Secrets

```bash
supabase secrets set RESEND_API_KEY=your_resend_api_key
supabase secrets set PARENT_EMAIL_FROM=your_verified_sender
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

Never pass `SUPABASE_SERVICE_ROLE_KEY` to Flutter.

## Flutter Dart Defines

```bash
flutter run -d emulator-5554 ^
  --dart-define=SUPABASE_URL=your_supabase_url ^
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key ^
  --dart-define=FACE_API_URL=http://10.0.2.2:8000 ^
  --dart-define=APP_ENV=development ^
  --dart-define=USE_MOCK_DATA=false
```

`FACE_API_URL` is optional. Without it, Flutter uses the safe face-recognition
demo fallback.

## Python Face API Demo

```bash
cd python_api
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

## Manual Test Flow

- Auth: Admin, Teacher, and Student login route to correct dashboards.
- First-login: Created/reset users must change password before dashboard.
- Admin writes: Create users, departments, batches, semesters, subjects, assignments, and enrollments.
- Attendance session: Teacher creates a session for an active class.
- Face demo/API: Run face recognition and confirm attendance records save.
- Dynamic QR Attendance: Generate student QR and scan from teacher flow.
- Gate QR Entry/Exit: Scan student gate QR and confirm alternating entry/exit rows.
- Parent email status: Confirm sent, failed, or skipped status is shown.
- Anonymous messaging: Student sends message, teacher views/reports, admin reviews.
- Reports: Open admin and teacher report screens.
- System activity: Confirm admin writes and parent email events appear.

## Known Production Limitations

- Real OpenCV or face embedding service still needs production implementation.
- Real email provider domain and sender verification must be configured.
- Full device QA and edge-case testing remain pending.
- APK signing and release build setup remain pending.
- Anonymous message sender reveal should use a hardened audited RPC before production.

## Final SQL Order

Run updated SQL in this order:

1. `supabase/schema.sql`
2. `supabase/rls_policies.sql`
3. `supabase/seed_data.sql`
