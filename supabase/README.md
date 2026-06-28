# EduVision Supabase Backend Setup

This folder contains the SQL setup files and Edge Function source used by the
EduVision Flutter backend.

## File Order

Run SQL files in this order inside the Supabase SQL Editor or migration
workflow:

1. `schema.sql`
2. `rls_policies.sql`
3. `seed_data.sql` if demo seed data is needed

## Current Backend Status

Completed in the repository:

- Database schema for auth profiles, academics, attendance, gate logs,
  anonymous messages, message reports, and system activity logs
- Row Level Security policy SQL with helper role functions
- Secure admin write Edge Functions
- Parent gate email Edge Function
- Face Recognition API Flutter contract and optional Python demo scaffold
- Android backend testing support through Flutter dart-defines

Deployment still needs to be performed manually against the target Supabase
project.

## Required Edge Functions

```bash
supabase functions deploy send-parent-gate-email
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
supabase functions deploy admin-academic-write
```

## Required Function Secrets

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
supabase secrets set RESEND_API_KEY=your_resend_api_key
supabase secrets set PARENT_EMAIL_FROM=your_verified_sender
```

Do not commit real `.env`, `.env.local`, anon keys, email keys, or service role
keys. The Flutter app must never contain the Supabase service role key.

## Flutter Backend Testing

Example Android emulator run command:

```bash
flutter run -d emulator-5554 ^
  --dart-define=SUPABASE_URL=your_supabase_url ^
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key ^
  --dart-define=APP_ENV=development ^
  --dart-define=USE_MOCK_DATA=false
```

Optional Face API:

```bash
--dart-define=FACE_API_URL=http://10.0.2.2:8000
```

## Production Notes

- Review SQL before applying to a project with real data.
- Back up existing data before running migrations.
- Verify Resend or email provider sender/domain before live email tests.
- Replace the Python demo scaffold with a real CV/embedding service before
  production use.
- Run full manual device QA before APK release work.
