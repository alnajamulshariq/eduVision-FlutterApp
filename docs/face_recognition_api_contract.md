# Face Recognition API Contract

EduVision Flutter does not run computer vision or embedding comparison locally.
The app can call a future Python service when `FACE_API_URL` is configured
through dart-defines or the existing dotenv pattern. `FACE_API_BASE_URL` is also
accepted as a backward-compatible alias.

If no API URL is configured, or if the API times out, returns invalid JSON, or is
not reachable, the Flutter app uses a demo fallback and still saves normal
`attendance_records` for the current attendance session.

## Process Session

`POST /attendance/process-session`

Request:

```json
{
  "sessionId": "attendance-session-id",
  "subjectId": "subject-id",
  "teacherId": "teacher-id",
  "enrolledStudentIds": ["student-id-1", "student-id-2"],
  "totalFrames": 20
}
```

Expected response:

```json
{
  "status": "completed",
  "message": "Face recognition processing completed.",
  "totalFrames": 20,
  "results": [
    {
      "studentId": "student-id-1",
      "framesDetected": 18,
      "totalFrames": 20,
      "attendancePercentage": 90,
      "attendanceStatus": "present",
      "confidence": 0.92
    }
  ]
}
```

The Flutter app maps each result into `attendance_records` using:

- `attendance_method`: `face_recognition`
- `attendance_status`: `present` or `absent`
- `attendance_percentage`: percentage returned by API or calculated from frames
- `frames_detected`: number of frames where the student was detected
- `total_frames`: total processed frames

The real Python implementation is pending outside this Flutter repository. It
should perform camera capture, face detection, embedding generation, embedding
comparison, and percentage calculation before returning the response above.
