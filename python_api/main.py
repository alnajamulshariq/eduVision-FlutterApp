from hashlib import sha256

from fastapi import FastAPI
from pydantic import BaseModel, Field


app = FastAPI(
    title="EduVision Face Recognition API Demo",
    version="0.1.0",
)


class ProcessSessionRequest(BaseModel):
    sessionId: str = Field(min_length=1)
    subjectId: str = Field(min_length=1)
    teacherId: str = Field(min_length=1)
    enrolledStudentIds: list[str] = Field(default_factory=list)
    totalFrames: int = Field(default=20, ge=1, le=1000)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/attendance/process-session")
def process_session(payload: ProcessSessionRequest) -> dict[str, object]:
    total_frames = payload.totalFrames
    results = [
        _build_demo_result(
            session_id=payload.sessionId,
            student_id=student_id,
            total_frames=total_frames,
        )
        for student_id in payload.enrolledStudentIds
        if student_id.strip()
    ]

    return {
        "status": "completed",
        "message": "Face recognition demo processing completed.",
        "totalFrames": total_frames,
        "usedFallback": False,
        "results": results,
    }


def _build_demo_result(
    *,
    session_id: str,
    student_id: str,
    total_frames: int,
) -> dict[str, object]:
    seed = sha256(f"{session_id}:{student_id}".encode("utf-8")).hexdigest()
    seed_value = int(seed[:8], 16)
    minimum_frames = total_frames // 2
    frame_range = max(total_frames - minimum_frames, 1)
    frames_detected = minimum_frames + (seed_value % (frame_range + 1))
    frames_detected = min(frames_detected, total_frames)
    attendance_percentage = round((frames_detected / total_frames) * 100, 2)

    return {
        "studentId": student_id.strip(),
        "framesDetected": frames_detected,
        "totalFrames": total_frames,
        "attendancePercentage": attendance_percentage,
        "attendanceStatus": "present"
        if attendance_percentage >= 75
        else "absent",
        "confidence": round(min(0.99, 0.5 + attendance_percentage / 200), 2),
    }
