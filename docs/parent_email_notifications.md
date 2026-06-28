# Parent Email Notifications

Parent email notification is part of the EduVision SRS for Gate Entry/Exit.
When a student enters or exits the university, the gate log should be saved and
the parent should be notified by email.

## Security Model

Flutter does not send email directly and does not store SMTP, Resend, or service
role secrets. The app saves the `gate_logs` row and then invokes a Supabase Edge
Function with safe identifiers only:

- `gateLogId`
- `studentId`

The Edge Function fetches the student, parent email, and gate log server-side,
sends the email through the provider, and marks `gate_logs.parent_email_sent`
as `true` only after successful delivery.

## Edge Function

Function name:

```bash
send-parent-gate-email
```

Deploy placeholder:

```bash
supabase functions deploy send-parent-gate-email
```

## Required Function Secrets

Set these in the Supabase function environment:

```bash
supabase secrets set RESEND_API_KEY=your_key_here
supabase secrets set PARENT_EMAIL_FROM=noreply@yourdomain.com
```

Supabase also provides the project URL and service role environment values to
the Edge Function runtime. Do not put the service role key in Flutter.

## Missing Provider Behavior

If `RESEND_API_KEY` or `PARENT_EMAIL_FROM` is missing:

- the gate log still saves,
- the function returns `emailSent: false`,
- the app shows Parent Email as pending/provider not configured,
- `gate_logs.parent_email_sent` remains `false`.

## Testing Steps

1. Deploy `send-parent-gate-email`.
2. Set `RESEND_API_KEY` and `PARENT_EMAIL_FROM` in Supabase secrets.
3. Login as Admin.
4. Open Admin Gate Logs.
5. Open Gate QR Scanner.
6. Process a student Gate Access QR.
7. Confirm the gate log saves.
8. Confirm the scanner shows Parent Email as Sent or a safe pending status.
9. If provider secrets are configured, confirm `parent_email_sent` becomes
   `true` on the new `gate_logs` row.

Real provider/domain setup is required before live email delivery.
