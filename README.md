# EduVision

## Smart University Attendance & Monitoring System

EduVision is a premium Flutter-based university monitoring demo app built for an expo/FYP presentation. It demonstrates how a university can manage smart attendance, campus gate movement, role-based dashboards, academic setup, reporting, and safe anonymous feedback through a polished mobile interface.

## Project Purpose

EduVision is designed to help universities preview a modern digital system for:

- Managing class attendance and attendance reports.
- Monitoring student entry and exit activity at campus gates.
- Supporting anonymous academic communication between students and teachers.
- Giving admins a control center for users, academics, reports, and moderation.

The current app is a frontend demo/prototype. It uses mock data to explain the system flow before backend services and hardware integrations are added.

## Key Features

### Student

- Dynamic QR preview.
- Attendance report.
- Gate history.
- Anonymous message.

### Teacher

- Timetable preview.
- Start attendance demo.
- QR scanner simulation.
- Anonymous messages.
- Student gate monitoring.

### Admin

- User management.
- Academic management.
- Attendance reports.
- Gate logs.
- Message reports.

## Smart Attendance Logic

The Smart Attendance demo shows how a future production system can validate and calculate attendance.

- Timetable validation confirms the teacher is starting attendance during the assigned class window.
- Face recognition preview shows the planned camera-based attendance flow.
- Dynamic QR backup is shown for students whose faces may not be clearly visible because of masks, veils, niqabs, or other face coverings.
- 75% or above = Present.
- Below 75% = Absent.

This is a frontend preview only. Real face recognition, camera capture, and attendance saving are not connected yet.

## Gate Monitoring Logic

The Gate Entry and Exit Monitoring demo shows how student movement can be tracked using a dynamic QR scan.

- Dynamic QR scan controls campus entry and exit.
- 1st scan = Entry.
- 2nd scan = Exit.
- 3rd scan = Entry.
- Parent email notification preview is shown for every entry and exit.

This is a mock frontend flow. Real QR scanning, database saving, and email notification services are not connected yet.

## Anonymous Messaging Logic

The Anonymous Messaging module demonstrates a safe academic feedback flow.

- Student identity is hidden from teachers.
- Teacher can mark messages resolved or report them to admin.
- Admin can review reported messages.
- Admin can reveal the sender only for investigation preview.

This protects normal student feedback while still showing an accountability process for reported messages.

## Tech Stack

- Flutter
- Dart
- Material 3
- Riverpod
- GoRouter
- Shared Preferences
- url_launcher
- Google Fonts
- flutter_animate
- Premium glassmorphism UI
- Light and dark mode

## Project Status

EduVision is currently a frontend demo/prototype.

Not connected yet:

- Real backend.
- Real database.
- Real authentication.
- Real camera integration.
- Real QR scanning.
- Real QR generation.
- Real face recognition.
- Real PDF/CSV export.
- Real email notification service.

## Technical Partner

Technical Partner: Zentherix

Website: https://www.zentherix.com/

Email: [info@zentherix.com](mailto:info@zentherix.com)

## How to Run

```bash
flutter pub get
flutter run
```

## Build

```bash
flutter build web
```

## Future Enhancements

- Supabase or Firebase backend.
- Real authentication.
- Real QR generation.
- Real QR scanner.
- Camera integration.
- Python face recognition API.
- PDF/CSV exports.
- Email notifications.
