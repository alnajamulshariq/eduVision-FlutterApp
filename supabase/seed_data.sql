-- EduVision demo seed data draft.
-- Planning only: adjust UUIDs, auth links, and RLS-safe insert strategy before production use.

insert into app_users (
  id,
  name,
  university_email,
  role,
  is_first_login,
  password_changed_once
) values
  (
    '00000000-0000-4000-8000-000000000001',
    'Ali Khan',
    'ali.khan@eduvision.local',
    'student',
    true,
    false
  ),
  (
    '00000000-0000-4000-8000-000000000002',
    'Sara Ahmed',
    'sara.ahmed@eduvision.local',
    'student',
    true,
    false
  ),
  (
    '00000000-0000-4000-8000-000000000003',
    'Ahmed Raza',
    'ahmed.raza@eduvision.local',
    'student',
    true,
    false
  ),
  (
    '00000000-0000-4000-8000-000000000004',
    'Fatima Noor',
    'fatima.noor@eduvision.local',
    'student',
    true,
    false
  ),
  (
    '00000000-0000-4000-8000-000000000005',
    'Mr. Ahmad',
    'ahmad.teacher@eduvision.local',
    'teacher',
    true,
    false
  ),
  (
    '00000000-0000-4000-8000-000000000006',
    'Admin User',
    'admin@eduvision.local',
    'admin',
    false,
    true
  )
on conflict (id) do update set
  name = excluded.name,
  university_email = excluded.university_email,
  role = excluded.role,
  updated_at = now();

insert into departments (id, name, code) values
  (
    '10000000-0000-4000-8000-000000000001',
    'Computer Science',
    'BSIT'
  )
on conflict (id) do update set
  name = excluded.name,
  code = excluded.code,
  updated_at = now();

insert into batches (id, name, year, department_id) values
  (
    '20000000-0000-4000-8000-000000000001',
    'BSIT 2022',
    2022,
    '10000000-0000-4000-8000-000000000001'
  )
on conflict (id) do update set
  name = excluded.name,
  year = excluded.year,
  department_id = excluded.department_id,
  updated_at = now();

insert into semesters (id, name, number) values
  (
    '30000000-0000-4000-8000-000000000001',
    '8th Semester',
    8
  )
on conflict (id) do update set
  name = excluded.name,
  number = excluded.number,
  updated_at = now();

insert into subjects (id, name, code, department_id, semester_id) values
  (
    '40000000-0000-4000-8000-000000000001',
    'Database Systems',
    'CS-408',
    '10000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001'
  )
on conflict (id) do update set
  name = excluded.name,
  code = excluded.code,
  department_id = excluded.department_id,
  semester_id = excluded.semester_id,
  updated_at = now();

insert into students (
  id,
  user_id,
  roll_no,
  name,
  department_id,
  batch_id,
  semester_id,
  parent_email
) values
  (
    '50000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000001',
    'BSIT-2022-001',
    'Ali Khan',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'parent@example.com'
  ),
  (
    '50000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000002',
    'BSIT-2022-002',
    'Sara Ahmed',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'parent@example.com'
  ),
  (
    '50000000-0000-4000-8000-000000000003',
    '00000000-0000-4000-8000-000000000003',
    'BSIT-2022-003',
    'Ahmed Raza',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'parent@example.com'
  ),
  (
    '50000000-0000-4000-8000-000000000004',
    '00000000-0000-4000-8000-000000000004',
    'BSIT-2022-004',
    'Fatima Noor',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'parent@example.com'
  )
on conflict (id) do update set
  roll_no = excluded.roll_no,
  name = excluded.name,
  department_id = excluded.department_id,
  batch_id = excluded.batch_id,
  semester_id = excluded.semester_id,
  parent_email = excluded.parent_email,
  updated_at = now();

insert into teachers (
  id,
  user_id,
  employee_id,
  name,
  department_id
) values
  (
    '60000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000005',
    'TCH-001',
    'Mr. Ahmad',
    '10000000-0000-4000-8000-000000000001'
  )
on conflict (id) do update set
  employee_id = excluded.employee_id,
  name = excluded.name,
  department_id = excluded.department_id,
  updated_at = now();

insert into face_embeddings (
  id,
  student_id,
  embedding_reference,
  model_version,
  captured_at
) values
  (
    '70000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000001',
    'face_refs/bsit-2022-001',
    'demo-v1',
    '2026-06-24 08:00:00+00'
  ),
  (
    '70000000-0000-4000-8000-000000000002',
    '50000000-0000-4000-8000-000000000002',
    'face_refs/bsit-2022-002',
    'demo-v1',
    '2026-06-24 08:00:00+00'
  ),
  (
    '70000000-0000-4000-8000-000000000003',
    '50000000-0000-4000-8000-000000000003',
    'face_refs/bsit-2022-003',
    'demo-v1',
    '2026-06-24 08:00:00+00'
  )
on conflict (id) do update set
  embedding_reference = excluded.embedding_reference,
  model_version = excluded.model_version,
  captured_at = excluded.captured_at,
  updated_at = now();

update students set face_embedding_id = '70000000-0000-4000-8000-000000000001'
where id = '50000000-0000-4000-8000-000000000001';

update students set face_embedding_id = '70000000-0000-4000-8000-000000000002'
where id = '50000000-0000-4000-8000-000000000002';

update students set face_embedding_id = '70000000-0000-4000-8000-000000000003'
where id = '50000000-0000-4000-8000-000000000003';

insert into teacher_subjects (
  id,
  teacher_id,
  subject_id,
  department_id,
  batch_id,
  semester_id
) values
  (
    '80000000-0000-4000-8000-000000000001',
    '60000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001'
  )
on conflict (id) do update set
  teacher_id = excluded.teacher_id,
  subject_id = excluded.subject_id,
  department_id = excluded.department_id,
  batch_id = excluded.batch_id,
  semester_id = excluded.semester_id,
  updated_at = now();

insert into student_subjects (
  id,
  student_id,
  subject_id,
  department_id,
  batch_id,
  semester_id
) values
  (
    '81000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001'
  ),
  (
    '81000000-0000-4000-8000-000000000002',
    '50000000-0000-4000-8000-000000000002',
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001'
  ),
  (
    '81000000-0000-4000-8000-000000000003',
    '50000000-0000-4000-8000-000000000003',
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001'
  ),
  (
    '81000000-0000-4000-8000-000000000004',
    '50000000-0000-4000-8000-000000000004',
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001'
  )
on conflict (id) do update set
  student_id = excluded.student_id,
  subject_id = excluded.subject_id,
  department_id = excluded.department_id,
  batch_id = excluded.batch_id,
  semester_id = excluded.semester_id,
  updated_at = now();

insert into teacher_timetables (
  id,
  teacher_id,
  subject_id,
  department_id,
  batch_id,
  semester_id,
  day,
  start_time,
  end_time,
  room
) values
  (
    '82000000-0000-4000-8000-000000000001',
    '60000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'wednesday',
    '09:00',
    '10:00',
    'Lab 2'
  )
on conflict (id) do update set
  teacher_id = excluded.teacher_id,
  subject_id = excluded.subject_id,
  day = excluded.day,
  start_time = excluded.start_time,
  end_time = excluded.end_time,
  room = excluded.room,
  updated_at = now();

insert into attendance_sessions (
  id,
  teacher_id,
  subject_id,
  department_id,
  batch_id,
  semester_id,
  session_date,
  start_time,
  end_time,
  status
) values
  (
    '90000000-0000-4000-8000-000000000001',
    '60000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    '2026-06-24',
    '09:00',
    '10:00',
    'completed'
  )
on conflict (id) do update set
  status = excluded.status,
  updated_at = now();

insert into attendance_records (
  id,
  session_id,
  student_id,
  attendance_percentage,
  attendance_method,
  attendance_status,
  frames_detected,
  total_frames
) values
  (
    '91000000-0000-4000-8000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000001',
    90,
    'face_recognition',
    'present',
    18,
    20
  ),
  (
    '91000000-0000-4000-8000-000000000002',
    '90000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000002',
    80,
    'face_recognition',
    'present',
    16,
    20
  ),
  (
    '91000000-0000-4000-8000-000000000003',
    '90000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000003',
    70,
    'face_recognition',
    'absent',
    14,
    20
  ),
  (
    '91000000-0000-4000-8000-000000000004',
    '90000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000004',
    100,
    'dynamic_qr',
    'present',
    null,
    null
  )
on conflict (id) do update set
  attendance_percentage = excluded.attendance_percentage,
  attendance_method = excluded.attendance_method,
  attendance_status = excluded.attendance_status,
  frames_detected = excluded.frames_detected,
  total_frames = excluded.total_frames,
  updated_at = now();

insert into gate_logs (
  id,
  student_id,
  log_date,
  log_time,
  status,
  gate_location,
  parent_email_sent
) values
  (
    'a0000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000001',
    '2026-06-24',
    '08:00',
    'entry',
    'Main Gate',
    true
  ),
  (
    'a0000000-0000-4000-8000-000000000002',
    '50000000-0000-4000-8000-000000000001',
    '2026-06-24',
    '11:30',
    'exit',
    'Main Gate',
    true
  ),
  (
    'a0000000-0000-4000-8000-000000000003',
    '50000000-0000-4000-8000-000000000001',
    '2026-06-24',
    '12:15',
    'entry',
    'Main Gate',
    true
  ),
  (
    'a0000000-0000-4000-8000-000000000004',
    '50000000-0000-4000-8000-000000000002',
    '2026-06-24',
    '08:05',
    'entry',
    'Main Gate',
    true
  ),
  (
    'a0000000-0000-4000-8000-000000000005',
    '50000000-0000-4000-8000-000000000003',
    '2026-06-24',
    '12:30',
    'exit',
    'Main Gate',
    true
  )
on conflict (id) do update set
  log_date = excluded.log_date,
  log_time = excluded.log_time,
  status = excluded.status,
  gate_location = excluded.gate_location,
  parent_email_sent = excluded.parent_email_sent,
  updated_at = now();

insert into anonymous_messages (
  id,
  student_id,
  teacher_id,
  subject_id,
  message,
  status,
  is_reported,
  report_reason
) values
  (
    'b0000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000001',
    '60000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    'Sir, Lecture 4 was difficult to understand.',
    'new',
    false,
    null
  ),
  (
    'b0000000-0000-4000-8000-000000000002',
    '50000000-0000-4000-8000-000000000002',
    '60000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    'Please provide additional practice exercises.',
    'resolved',
    false,
    null
  ),
  (
    'b0000000-0000-4000-8000-000000000003',
    '50000000-0000-4000-8000-000000000003',
    '60000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    'The classroom projector is not working properly.',
    'reported',
    true,
    'Classroom facility issue'
  )
on conflict (id) do update set
  message = excluded.message,
  status = excluded.status,
  is_reported = excluded.is_reported,
  report_reason = excluded.report_reason,
  updated_at = now();

insert into message_reports (
  id,
  message_id,
  reported_by_teacher_id,
  reason,
  status
) values
  (
    'c0000000-0000-4000-8000-000000000001',
    'b0000000-0000-4000-8000-000000000003',
    '60000000-0000-4000-8000-000000000001',
    'Classroom facility issue',
    'pending'
  )
on conflict (id) do update set
  reason = excluded.reason,
  status = excluded.status,
  updated_at = now();
