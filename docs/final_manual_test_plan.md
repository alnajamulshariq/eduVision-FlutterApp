# Final Manual Test Plan

Use this sequence for the final FYP presentation/demo. Keep real secrets out of
screenshots, terminal output, and commits.

## Fast Demo Sequence

1. Launch the app and confirm EduVision splash appears.
2. Confirm unauthenticated users land on Login.
3. Login as Student and verify Student dashboard opens.
4. Login as Teacher and verify Teacher dashboard opens.
5. Login as Admin and verify Admin Console opens.
6. Admin opens User Management and creates a test student, teacher, or admin.
7. Admin resets the test user's temporary password.
8. Login as the test user and confirm Change Password appears before dashboard.
9. Set a new password and confirm the user reaches the correct dashboard.
10. Admin creates department, batch, semester, and subject if demo data is missing.
11. Admin assigns a teacher to a subject/batch/semester.
12. Admin enrolls a student in the subject.
13. Teacher opens Start Attendance and confirms active timetable validation.
14. Teacher starts an attendance session.
15. Run Face Recognition demo/API flow and confirm records save.
16. Student opens My Dynamic QR and selects Attendance QR.
17. Teacher opens QR Scanner and marks Dynamic QR Attendance.
18. Student opens My Attendance and confirms the record appears.
19. Teacher/Admin opens Attendance Reports and verifies the session record.
20. Student opens My Dynamic QR and selects Gate Access QR.
21. Admin opens Gate QR Scanner and scans/pastes the Gate Access QR for Entry.
22. Admin scans/pastes the same Gate Access QR again for Exit.
23. Student opens Gate History and confirms entry/exit timeline.
24. Teacher opens Student Gate Monitoring and checks current status.
25. Admin opens Gate Logs and confirms parent email status.
26. Student sends an anonymous message to a teacher.
27. Teacher opens Anonymous Messages and marks a message resolved.
28. Teacher reports a message for admin review.
29. Admin opens Message Reports and reveals sender for investigation.
30. Admin opens System Activity and confirms admin writes/email events appear.

## Cleanup Notes

- Remove or ignore test users/records after the presentation if needed.
- Keep demo passwords temporary and non-production.
- Do not commit `.env`, `.env.local`, screenshots with secrets, or generated
  build outputs.
- APK build/signing is intentionally handled later by the user.
