# Secure Admin Writes

EduVision admin write operations must not use the Supabase service role key in
Flutter. The Flutter app calls Supabase Edge Functions with the signed-in admin
session. The functions verify the caller is an active admin, then use
server-side Supabase Admin APIs and database writes.

## Edge Functions

- `admin-create-user`
- `admin-reset-password`
- `admin-academic-write`

Deploy placeholders:

```bash
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
supabase functions deploy admin-academic-write
```

## Required Supabase Secrets

The functions require the service role key in the Supabase function
environment:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

Do not put the service role key in Flutter source, `.env`, dart-defines, or any
mobile build configuration.

## Supported Operations

User management:

- Create student account and profile
- Create teacher account and profile
- Create admin account
- Reset a user's temporary password
- Mark created and reset users for first-login password change

Academic management:

- Create department
- Create batch
- Create semester
- Create subject
- Assign teacher to subject/batch/semester
- Enroll student in subject

## Security Checks

Each function:

- requires a bearer token from the signed-in caller,
- verifies the caller exists in `app_users`,
- requires `role = admin` and `is_active = true`,
- uses `SUPABASE_SERVICE_ROLE_KEY` only server-side,
- returns safe success/error messages,
- does not log passwords or secrets.

## Testing Steps

1. Deploy the three admin functions.
2. Set `SUPABASE_SERVICE_ROLE_KEY` in Supabase secrets.
3. Login as Admin in the Flutter app.
4. Open Admin User Management.
5. Create a test student and a test teacher.
6. Reset the temporary password for a test user.
7. Open Admin Academic Management.
8. Create a department, batch, semester, and subject.
9. Assign a teacher and enroll a student.
10. Confirm lists refresh and the created records appear.
11. Confirm the created user can log in with the known temporary password.
12. Confirm the created user is routed to Change Password before dashboard.
13. Confirm the user can set a new password once, then reaches dashboard.
14. Reset the user password as Admin and confirm the first-login flow is required again.

## First-Login Password Flow

Admin-created accounts and admin password resets set:

- `app_users.is_first_login = true`
- `app_users.password_changed_once = false`

After the user signs in with the temporary password, Flutter routes them to
`/change-password`. The user can set a new password once through Supabase Auth,
then Flutter updates the profile flags to:

- `app_users.is_first_login = false`
- `app_users.password_changed_once = true`

The app router keeps first-login users away from role dashboards until these
flags are finalized. Forgotten passwords remain admin-reset only.

## Current Limitations

The functions create the rows supported by the current schema. There is no
separate `admins` table in the schema, so admin accounts are represented by
`app_users.role = admin`.
