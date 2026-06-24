# RLS Policy Planning

This document is a planning guide only. Final production Row Level Security policies should be written and tested after the real Supabase project, authentication flow, and role claims are finalized.

## Core Principles

- Enable RLS on all application tables before production.
- Use `app_users.role` as the application role source after Supabase Auth is connected.
- Keep admin-only operations behind server-side checks or secure RPC functions where needed.
- Avoid exposing student identity through anonymous messaging policies.
- Prefer narrow read/write policies per role rather than broad authenticated access.

## Admin Access

- Admin can manage all data needed for university operations.
- Admin can create and manage student, teacher, and admin records.
- Admin can create departments, batches, semesters, subjects, assignments, timetables, and enrollments.
- Admin can view attendance reports, gate logs, message reports, and audit-relevant records.
- Admin can reveal the sender only for anonymous messages that have been reported for review.

## Student Access

- Student can view only their own profile data.
- Student can view only their own attendance records and attendance summaries.
- Student can view only their own gate entry and exit history.
- Student can submit anonymous messages to assigned teachers.
- Student can view their own submitted messages if the UI later exposes message history.
- Student cannot view other students, teacher-only reports, admin reports, or message report review data.

## Teacher Access

- Teacher can view their own timetable and assigned subjects.
- Teacher can view students enrolled in their assigned classes.
- Teacher can create attendance sessions for assigned classes only.
- Teacher can create or update attendance records only for students in those assigned classes.
- Teacher can view gate status for students relevant to their assigned classes.
- Teacher can view anonymous messages sent to them.
- Teacher cannot see student identity in anonymous messages.
- Teacher can mark messages resolved or report messages to admin for review.

## Anonymous Messaging Rules

- Student identity is stored for accountability but hidden from teachers.
- Teacher-facing queries should use a view or RPC that excludes `student_id`.
- Reported messages should be reviewable by admin.
- Admin sender reveal should be limited to reported messages and ideally audited.
- Message report status should flow through `pending`, `reviewed`, `safe`, or `escalated`.

## Gate Monitoring Rules

- Students can view their own gate logs.
- Admin can view all gate logs.
- Teachers can view gate status for students in their assigned classes.
- A `gate_operator` role may be added later if the university needs dedicated gate staff accounts.
- Parent email notifications should be handled server-side later, not directly from the mobile app.

## Production Notes

- Final policies should be tested with separate student, teacher, and admin Supabase Auth users.
- Sensitive operations such as password reset, sender reveal, and parent email notification should be implemented with secure server-side functions.
- RLS should be finalized before real credentials, real users, or production data are added.
