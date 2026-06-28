# EduVision Face Recognition API Demo

This optional FastAPI service matches the Flutter face-recognition API contract
without adding OpenCV or embedding dependencies. It is intended for FYP demo and
deployment readiness only.

## Run Locally

```bash
cd python_api
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

For Android emulator testing, run Flutter with:

```bash
flutter run -d emulator-5554 --dart-define=FACE_API_URL=http://10.0.2.2:8000
```

## Endpoint

`POST /attendance/process-session`

The request and response shape matches `docs/face_recognition_api_contract.md`.
Results are deterministic demo values derived from `sessionId` and each
`enrolledStudentIds` entry.

## Production Upgrade Path

Replace the demo scoring in `main.py` with:

- frame capture or uploaded frame reference loading
- face detection
- embedding generation
- stored embedding lookup
- similarity matching
- attendance percentage calculation

Do not add Supabase service-role keys or provider secrets to this folder.
