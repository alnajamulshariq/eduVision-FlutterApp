# Future Scope

EduVision is currently a frontend demo/prototype. The following features can be added in future development phases.

## Backend Database

Connect the app to a backend database for storing users, attendance records, gate logs, academic data, anonymous messages, and reports.

Possible options:

- Supabase
- Firebase
- Custom REST API

## Authentication

Add real login and role-based access for:

- Students
- Teachers
- Admins

Authentication should include secure session handling, password reset, and account status management.

## Student, Teacher, and Admin Accounts

Implement real account creation and management for all roles. Admin should be able to create, update, disable, and review accounts.

## Real Dynamic QR

Generate secure dynamic QR codes for students. QR tokens should refresh automatically and expire after a short time to prevent misuse.

## QR Scanner Package

Integrate a real Flutter QR scanner package for teacher attendance backup and gate entry/exit scanning.

## Face Recognition Python API

Build a Python-based face recognition API for smart attendance. The Flutter app can send captured frames to the API and receive recognition results.

## Camera Integration

Add camera support for attendance sessions and face frame capture. Camera permissions and privacy handling should be implemented carefully.

## Admin Reports

Add real attendance reports with filters for:

- Department
- Batch
- Semester
- Subject
- Teacher
- Date range

Reports can later support PDF and CSV export.

## Parent Email Notifications

Add email notifications for gate entry and exit events. Parents can receive alerts when students enter or leave campus.

## Production Deployment

Prepare the system for production with:

- Secure environment configuration.
- Backend deployment.
- Web build deployment.
- Android release build.
- Testing and QA.
- Data privacy and access control review.
