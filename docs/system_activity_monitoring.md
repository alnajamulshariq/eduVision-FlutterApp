# System Activity Monitoring

EduVision records important backend events in `system_activity_logs` so Admins
can monitor recent secure operations.

## Logged Events

- Admin user creation
- Admin password reset
- Department, batch, semester, and subject creation
- Teacher assignment
- Student enrollment
- Parent gate email sent, failed, or skipped

## Table

`system_activity_logs` stores:

- `actor_user_id`
- `action`
- `target_type`
- `target_id`
- `description`
- `metadata`
- `created_at`

The table is admin-readable through RLS. Supabase Edge Functions insert records
with the service role key. Flutter does not log passwords, secrets, email body
content, or raw service responses.

## Flutter Screen

Admin Console -> System Activity shows the latest activity rows with:

- activity summary
- actor
- action
- target
- timestamp
- refresh action

## Deployment Notes

Apply updated SQL:

1. `supabase/schema.sql`
2. `supabase/rls_policies.sql`

Redeploy affected Edge Functions:

```bash
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
supabase functions deploy admin-academic-write
supabase functions deploy send-parent-gate-email
```
