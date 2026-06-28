# Final Deployment Notes

This document is for deployment readiness only. Do not commit real secrets.

## Supabase SQL Setup

Apply SQL in this order in the Supabase SQL Editor or your migration workflow:

1. `supabase/schema.sql`
2. `supabase/rls_policies.sql`
3. `supabase/seed_data.sql` if demo seed data is needed

Review the SQL against the target Supabase project before applying. If the
project already has data, take a backup first.

## Edge Function Deployment

Deploy the required functions:

```bash
supabase functions deploy send-parent-gate-email
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
supabase functions deploy admin-academic-write
```

Do not deploy automatically from this repo unless the Supabase CLI is linked,
secrets are already configured, and no destructive migration is required.

## Required Supabase Secrets

Set these in Supabase Function secrets:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
supabase secrets set RESEND_API_KEY=your_resend_api_key
supabase secrets set PARENT_EMAIL_FROM=your_verified_sender
```

Never pass `SUPABASE_SERVICE_ROLE_KEY` to Flutter or commit it to the repo.

## Flutter Dart Defines

Use these names when running the app:

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

`FACE_API_BASE_URL` is also accepted as a backward-compatible alias.

## Python API Demo

Run the optional FastAPI demo service locally:

```bash
cd python_api
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

For Android emulator, use `FACE_API_URL=http://10.0.2.2:8000`.

## Parent Email Provider Notes

- Configure a Resend account or equivalent provider.
- Verify the sender domain/address used in `PARENT_EMAIL_FROM`.
- Keep provider keys only in Supabase Function secrets.
- If email secrets are missing, gate logs still save and Flutter shows a safe
  pending/provider-not-configured status.

## Known Production Limitations

- Real CV/embedding deployment is still pending beyond the demo scaffold.
- Full device QA and regression testing remain required.
- Production sender reveal for anonymous messages should be hardened and
  audited with a secure RPC.
- APK build/signing is intentionally not part of this delivery pass.

## Do Not Commit

- `.env`
- `.env.local`
- Supabase service role keys
- email provider keys
- dart-define command history containing secrets
- generated build outputs
- APK/release artifacts
