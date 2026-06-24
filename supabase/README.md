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
