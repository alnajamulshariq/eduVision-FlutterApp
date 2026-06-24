# SRS Implementation Plan

EduVision is currently a premium Flutter frontend demo/prototype for a Smart University Attendance and Monitoring System. This document explains what exists now and what still needs to be connected for a production-ready implementation.

## What Is Already Done

- Flutter app structure with Student, Teacher, and Admin dashboards.
- Premium Material 3 glassmorphism UI.
- Light and dark mode.
- GoRouter route setup.
- Riverpod setup for app-level state.
- Shared Preferences for theme preference.
- Mock frontend flows for:
  - Smart Attendance.
  - Dynamic QR preview.
  - Gate Entry and Exit Monitoring.
  - Anonymous Messaging.
  - Attendance Reports.
  - Admin User Management.
  - Admin Academic Management.
- Backend-ready model classes for SRS entities.
- Repository stubs for future data access.
- Service stubs for Supabase, dynamic QR, and Python face API integration.
- Placeholder Riverpod providers for future repository/service injection.
- Supabase database planning files under `supabase/`.

## What Is Still Mock

- Login currently works as a demo role selector.
- Student, Teacher, and Admin screen data is hardcoded mock data.
- Smart Attendance uses preview calculations only.
- Dynamic QR is a visual preview only.
- QR scanner is simulated.
- Gate logs are mock records.
- Anonymous messages are mock records.
- Admin user creation and academic setup are preview-only forms.
- Report export buttons only show SnackBars.

## What Needs Real Implementation

- Supabase project setup.
- Database tables and row-level security policies.
- Real university email/password login.
- Role detection after login.
- Admin-only user creation.
- First-login temporary password change.
- Admin password reset.
- Real dynamic QR token generation and verification.
- Real QR scanning package integration.
- Camera integration.
- Python face recognition API.
- Attendance session persistence.
- Attendance records persistence.
- Gate log persistence.
- Anonymous message persistence.
- Parent email notification service.
- PDF/CSV report exports.

## Database Planning Completed

- Supabase schema draft created in `supabase/schema.sql`.
- RLS planning document created in `supabase/rls_policies.md`.
- Seed data draft created in `supabase/seed_data.sql`.
- Supabase README created in `supabase/README.md`.
- Next step will be real Supabase project creation and connection after review.
- No real credentials are committed, and the Flutter app is not connected to Supabase yet.

## Required Supabase Tables

Suggested tables for the SRS:

- `app_users`
  - `id`
  - `name`
  - `university_email`
  - `role`
  - `is_first_login`
  - `password_changed_once`
  - `created_at`
  - `updated_at`
- `students`
  - `id`
  - `user_id`
  - `roll_no`
  - `name`
  - `department_id`
  - `batch_id`
  - `semester_id`
  - `parent_email`
  - `face_embedding_id`
  - `is_active`
- `teachers`
  - `id`
  - `user_id`
  - `employee_id`
  - `name`
  - `department_id`
  - `is_active`
- `departments`
  - `id`
  - `name`
  - `code`
- `batches`
  - `id`
  - `name`
  - `year`
  - `department_id`
- `semesters`
  - `id`
  - `name`
  - `number`
- `subjects`
  - `id`
  - `name`
  - `code`
  - `department_id`
  - `semester_id`
- `teacher_subject_assignments`
  - `id`
  - `teacher_id`
  - `subject_id`
  - `department_id`
  - `batch_id`
  - `semester_id`
- `student_subject_enrollments`
  - `id`
  - `student_id`
  - `subject_id`
  - `department_id`
  - `batch_id`
  - `semester_id`
- `timetables`
  - `id`
  - `teacher_id`
  - `subject_id`
  - `department_id`
  - `batch_id`
  - `semester_id`
  - `day`
  - `start_time`
  - `end_time`
- `attendance_sessions`
  - `id`
  - `teacher_id`
  - `subject_id`
  - `department_id`
  - `batch_id`
  - `semester_id`
  - `date`
  - `start_time`
  - `end_time`
  - `status`
- `attendance_records`
  - `id`
  - `session_id`
  - `student_id`
  - `attendance_percentage`
  - `attendance_method`
  - `attendance_status`
  - `frames_detected`
  - `total_frames`
  - `created_at`
- `gate_logs`
  - `id`
  - `student_id`
  - `date`
  - `time`
  - `status`
  - `gate_location`
  - `parent_email_sent`
- `anonymous_messages`
  - `id`
  - `student_id`
  - `teacher_id`
  - `subject_id`
  - `message`
  - `status`
  - `is_reported`
  - `report_reason`
  - `created_at`
  - `resolved_at`

## Python API Required

The future Python face recognition API should support:

- Student face embedding registration.
- Attendance frame processing.
- Student recognition results per frame.
- Attendance percentage support data.
- Secure API authentication between Flutter/backend and Python service.

The Flutter app should not directly store face vectors in UI code. It should use secure backend/API references.

## Future APK Step

Do not build the APK yet. APK generation should happen only after:

- Backend is connected.
- Authentication is implemented.
- Required data flows are tested.
- QR and camera integrations are completed or intentionally scoped.
- App QA is complete.
- Production configuration is ready.
