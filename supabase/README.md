# Supabase Planning

This folder contains the future Supabase database planning files for EduVision. The Flutter app is still using mock frontend data and is not connected to Supabase yet.

## Files

- `schema.sql` defines the draft tables, constraints, relationships, indexes, and `updated_at` trigger pattern.
- `seed_data.sql` contains safe demo records that mirror the current frontend preview data.
- `rls_policies.md` describes the intended Row Level Security rules before production policies are written.

## How This Will Be Used Later

When the real Supabase project is created, `schema.sql` can be reviewed, adjusted, and applied in the Supabase SQL editor or migration workflow. After that, `seed_data.sql` can be refined and used to load a small demo dataset for testing.

RLS policies should be finalized before production data is used. The current RLS file is a planning document, not a final security implementation.

## Security Notes

- Do not commit real Supabase credentials.
- Do not commit `.env` values.
- Do not connect production data until RLS and auth flows are reviewed.
- Parent email notifications, sender reveal, and admin password reset should be handled server-side later.

## Current App Status

Supabase integration is planned but not connected yet. The premium Flutter demo screens, mock data, repository stubs, and service stubs remain unchanged.


## EduVision Supabase Backend Setup

This folder contains the SQL setup files required for the EduVision Flutter backend.

### File Order

Run the SQL files in this order inside the Supabase SQL Editor:

1. `schema.sql`
2. `rls_policies.sql`
3. `seed_data.sql`

### Current Backend Status

The Supabase backend has been configured for the Android backend testing phase.

Completed:

- Database schema created
- Row Level Security enabled
- Helper functions added for role checks
- Grants added for authenticated users
- RLS policies added for app users, academics, attendance, gate logs, anonymous messages, message reports, and system activity logs
- Demo auth users created manually in Supabase Auth
- `app_users` profiles linked with real Supabase Auth user IDs
- Demo academic data inserted
- Real login tested successfully on Android emulator

Verified roles:

- Admin opens Admin dashboard
- Teacher opens Teacher dashboard
- Student opens Student dashboard

### Important Security Notes

Do not commit `.env`, `.env.local`, publishable keys, anon keys, or service role keys.

The Flutter app must never contain the Supabase service role key.

Admin account creation and password reset should later be handled using a secure server-side function or Supabase Edge Function.

### Android Real Backend Testing

Use Android emulator only for backend testing.

Do not run web or Chrome for now because the previous passkeys/web issue may return.

Example run command:

```bash
flutter run -d emulator-5554 ^
  --dart-define=SUPABASE_URL=https://tyscmqltxcuyndkhcvea.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY="YOUR_LOCAL_PUBLISHABLE_KEY" ^
  --dart-define=APP_ENV=development ^
  --dart-define=USE_MOCK_DATA=false
