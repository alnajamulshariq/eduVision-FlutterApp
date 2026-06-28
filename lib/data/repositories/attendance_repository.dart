import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/attendance_record_model.dart';
import 'package:eduvision_app/data/models/attendance_report_model.dart';
import 'package:eduvision_app/data/models/attendance_session_model.dart';
import 'package:eduvision_app/data/models/dynamic_qr_model.dart';
import 'package:eduvision_app/data/models/face_recognition_result_model.dart';
import 'package:eduvision_app/data/models/timetable_model.dart';
import 'package:eduvision_app/data/services/face_api_service.dart';
import 'package:eduvision_app/data/services/qr_token_service.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class AttendanceRepository {
  const AttendanceRepository({
    this.supabaseService,
    this.faceApiService,
    this.qrTokenService,
  });

  final SupabaseService? supabaseService;
  final FaceApiService? faceApiService;
  final QrTokenService? qrTokenService;

  static const _attendanceSessionReportSelect = '''
    id,
    teacher_id,
    subject_id,
    department_id,
    batch_id,
    semester_id,
    session_date,
    start_time,
    end_time,
    status,
    created_at,
    teachers(name),
    subjects(name),
    departments(name),
    batches(name),
    semesters(name)
  ''';

  static const _attendanceStudentRecordSelect = '''
    id,
    session_id,
    student_id,
    attendance_percentage,
    attendance_method,
    attendance_status,
    frames_detected,
    total_frames,
    created_at,
    students(name, roll_no)
  ''';

  static const _studentQrIdentitySelect = '''
    id,
    user_id,
    roll_no,
    name,
    department_id,
    batch_id,
    semester_id,
    departments(name),
    batches(name),
    semesters(name)
  ''';

  static const _activeAttendanceSessionSelect = '''
    id,
    teacher_id,
    subject_id,
    department_id,
    batch_id,
    semester_id,
    session_date,
    start_time,
    end_time,
    status,
    created_at,
    subjects(name),
    departments(name),
    batches(name),
    semesters(name)
  ''';

  static const _attendanceRecordReportSelect = '''
    id,
    session_id,
    student_id,
    attendance_percentage,
    attendance_method,
    attendance_status,
    frames_detected,
    total_frames,
    created_at,
    students(name, roll_no),
    attendance_sessions!inner(
      id,
      teacher_id,
      subject_id,
      department_id,
      batch_id,
      semester_id,
      session_date,
      start_time,
      end_time,
      status,
      created_at,
      teachers(name),
      subjects(name),
      departments(name),
      batches(name),
      semesters(name)
    )
  ''';

  Future<Result<List<TimetableModel>>> getTeacherTimetable({
    required String teacherId,
    String? day,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockTeacherTimetable(day: day));
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final resolvedTeacherId = await _resolveTeacherRecordId(teacherId);

      if (resolvedTeacherId == null) {
        return const Result.success([]);
      }

      final rows = day == null || day.trim().isEmpty
          ? await client
                .from('teacher_timetables')
                .select()
                .eq('teacher_id', resolvedTeacherId)
                .order('start_time', ascending: true)
          : await client
                .from('teacher_timetables')
                .select()
                .eq('teacher_id', resolvedTeacherId)
                .eq('day', _normalizeDay(day))
                .order('start_time', ascending: true);

      final timetable = rows
          .map((row) => TimetableModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      return Result.success(timetable);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load teacher timetable right now.',
          code: 'teacher_timetable_load_failed',
        ),
      );
    }
  }

  Future<Result<TimetableModel?>> validateActiveClass({
    required String teacherId,
    required DateTime dateTime,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(
        _findActiveClass(_mockTeacherTimetable(), dateTime),
      );
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final resolvedTeacherId = await _resolveTeacherRecordId(teacherId);

      if (resolvedTeacherId == null) {
        return const Result.success(null);
      }

      final rows = await client
          .from('teacher_timetables')
          .select()
          .eq('teacher_id', resolvedTeacherId)
          .order('start_time', ascending: true);

      final timetable = rows
          .map((row) => TimetableModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      return Result.success(_findActiveClass(timetable, dateTime));
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to validate active class right now.',
          code: 'active_class_validation_failed',
        ),
      );
    }
  }

  Future<Result<AttendanceSessionModel>> createAttendanceSession({
    required AttendanceSessionModel session,
  }) async {
    if (_shouldUseMockData) {
      final mockId = session.id.trim().isEmpty
          ? 'mock-session-${DateTime.now().millisecondsSinceEpoch}'
          : session.id;

      return Result.success(session.copyWith(id: mockId));
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final payload = session.toJson();

      if ((payload['id'] as String?)?.trim().isEmpty ?? true) {
        payload.remove('id');
      }

      final row = await client
          .from('attendance_sessions')
          .insert(payload)
          .select()
          .single();

      return Result.success(
        AttendanceSessionModel.fromJson(Map<String, dynamic>.from(row)),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to create attendance session right now.',
          code: 'attendance_session_create_failed',
        ),
      );
    }
  }

  Future<Result<void>> saveAttendanceRecord({
    required AttendanceRecordModel record,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(null);
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final payload = record.toJson();

      if ((payload['id'] as String?)?.trim().isEmpty ?? true) {
        payload.remove('id');
      }

      payload.remove('created_at');

      await client
          .from('attendance_records')
          .upsert(payload, onConflict: 'session_id,student_id');

      return const Result.success(null);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to save attendance record right now.',
          code: 'attendance_record_save_failed',
        ),
      );
    }
  }

  Future<Result<FaceRecognitionSessionResultModel>>
  runFaceRecognitionAttendanceForSession({
    required AttendanceSessionModel session,
    int totalFrames = 20,
  }) async {
    final resolvedTotalFrames = totalFrames <= 0 ? 20 : totalFrames;

    if (_shouldUseMockData) {
      return Result.success(
        _buildFaceRecognitionFallback(
          enrolledStudents: _mockFaceRecognitionCandidates(),
          totalFrames: resolvedTotalFrames,
          message: 'Face Recognition demo fallback used.',
        ),
      );
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final enrolledStudents = await _loadEnrolledStudentsForSession(session);

      if (enrolledStudents.isEmpty) {
        return const Result.failure(
          AppException(
            message: 'No enrolled students found for this active class.',
            code: 'face_attendance_students_not_found',
          ),
        );
      }

      FaceRecognitionSessionResultModel sessionResult;
      final service = faceApiService;

      if (service != null && service.isConfigured) {
        final apiResult = await service.processAttendanceSession(
          sessionId: session.id,
          subjectId: session.subjectId,
          teacherId: session.teacherId,
          enrolledStudentIds: enrolledStudents
              .map((student) => student.studentId)
              .toList(),
          totalFrames: resolvedTotalFrames,
        );

        if (apiResult case Success<FaceRecognitionSessionResultModel>(
          :final data,
        )) {
          sessionResult = _mergeFaceRecognitionResults(
            apiResult: data,
            enrolledStudents: enrolledStudents,
            totalFrames: resolvedTotalFrames,
          );
        } else {
          sessionResult = _buildFaceRecognitionFallback(
            enrolledStudents: enrolledStudents,
            totalFrames: resolvedTotalFrames,
            message:
                'Face Recognition demo fallback used because the Python API is unavailable.',
          );
        }
      } else {
        sessionResult = _buildFaceRecognitionFallback(
          enrolledStudents: enrolledStudents,
          totalFrames: resolvedTotalFrames,
          message:
              'Face Recognition demo fallback used. Configure FACE_API_URL or FACE_API_BASE_URL to call the Python API.',
        );
      }

      for (final result in sessionResult.results) {
        final saveResult = await saveAttendanceRecord(
          record: AttendanceRecordModel(
            id: '',
            sessionId: session.id,
            studentId: result.studentId,
            attendancePercentage: result.attendancePercentage,
            attendanceMethod: 'face_recognition',
            attendanceStatus: result.attendanceStatus,
            framesDetected: result.framesDetected,
            totalFrames: result.totalFrames,
            createdAt: DateTime.now(),
          ),
        );

        if (saveResult case Failure<void>(:final exception)) {
          return Result.failure(exception);
        }
      }

      return Result.success(sessionResult);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to run face recognition attendance right now.',
          code: 'face_attendance_run_failed',
        ),
      );
    }
  }

  Future<Result<void>> saveDemoAttendanceRecordForSession({
    required AttendanceSessionModel session,
  }) async {
    final result = await runFaceRecognitionAttendanceForSession(
      session: session,
    );

    if (result case Failure<FaceRecognitionSessionResultModel>(
      :final exception,
    )) {
      return Result.failure(exception);
    }

    return const Result.success(null);
  }

  Future<Result<StudentQrIdentityModel>> getStudentQrIdentity({
    required String studentUserId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockStudentQrIdentity());
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final student = await _loadStudentQrIdentity(studentUserId);

      if (student == null) {
        return const Result.failure(
          AppException(
            message: 'No student profile was found for this account.',
            code: 'student_qr_identity_not_found',
          ),
        );
      }

      return Result.success(student);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load student QR identity right now.',
          code: 'student_qr_identity_load_failed',
        ),
      );
    }
  }

  Future<Result<QrAttendanceMarkResult>> markDynamicQrAttendanceFromPayload({
    required String teacherUserId,
    required String payload,
  }) async {
    final tokenResult = (qrTokenService ?? const QrTokenService())
        .parseAttendancePayload(payload: payload);

    if (tokenResult case Failure<DynamicQrPayload>(:final exception)) {
      return Result.failure(exception);
    }

    final token = (tokenResult as Success<DynamicQrPayload>).data;

    if (_shouldUseMockData) {
      final now = DateTime.now();

      return Result.success(
        QrAttendanceMarkResult(
          studentName: 'Ali Khan',
          rollNo: 'BSIT-2022-001',
          method: 'Dynamic QR',
          status: 'Attendance marked',
          message: 'Mock dynamic QR attendance marked successfully.',
          markedAt: now,
          alreadyMarked: false,
        ),
      );
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final teacherId = await _resolveTeacherRecordId(teacherUserId);

      if (teacherId == null) {
        return const Result.failure(
          AppException(
            message: 'No teacher profile was found for this account.',
            code: 'teacher_profile_not_found',
          ),
        );
      }

      final session = await _findActiveAttendanceSession(teacherId);

      if (session == null) {
        return const Result.failure(
          AppException(
            message: 'Start an active attendance session before scanning QR.',
            code: 'no_active_attendance_session',
          ),
        );
      }

      final student = await _loadStudentQrIdentity(token.lookupId);

      if (student == null) {
        return const Result.failure(
          AppException(
            message: 'No student profile was found for this QR code.',
            code: 'qr_student_not_found',
          ),
        );
      }

      final isEnrolled = await _isStudentEnrolledForSession(
        studentId: student.studentId,
        session: session,
      );

      if (!isEnrolled) {
        return const Result.failure(
          AppException(
            message:
                'This student is not enrolled in the active subject/class.',
            code: 'student_not_enrolled',
          ),
        );
      }

      final sessionId = session['id'] as String;
      final existingRecord = await client
          .from('attendance_records')
          .select('id, created_at')
          .eq('session_id', sessionId)
          .eq('student_id', student.studentId)
          .maybeSingle();

      if (existingRecord != null) {
        return Result.success(
          QrAttendanceMarkResult(
            studentName: student.name,
            rollNo: student.rollNo,
            method: 'Dynamic QR',
            status: 'Already marked',
            message: 'Attendance is already marked for this session.',
            markedAt:
                DateTime.tryParse(
                  existingRecord['created_at']?.toString() ?? '',
                ) ??
                DateTime.now(),
            alreadyMarked: true,
          ),
        );
      }

      final now = DateTime.now();
      final saveResult = await saveAttendanceRecord(
        record: AttendanceRecordModel(
          id: '',
          sessionId: sessionId,
          studentId: student.studentId,
          attendancePercentage: 100,
          attendanceMethod: 'dynamic_qr',
          attendanceStatus: 'present',
          framesDetected: 0,
          totalFrames: 0,
          createdAt: now,
        ),
      );

      if (saveResult case Failure<void>(:final exception)) {
        return Result.failure(exception);
      }

      return Result.success(
        QrAttendanceMarkResult(
          studentName: student.name,
          rollNo: student.rollNo,
          method: 'Dynamic QR',
          status: 'Attendance marked',
          message: 'Dynamic QR attendance marked successfully.',
          markedAt: now,
          alreadyMarked: false,
        ),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to mark dynamic QR attendance right now.',
          code: 'dynamic_qr_attendance_save_failed',
        ),
      );
    }
  }

  Future<Result<List<AttendanceRecordModel>>> getStudentAttendance({
    required String studentId,
    String? subjectId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockStudentAttendance());
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message:
                'Supabase is not configured. Please check environment setup.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final resolvedStudentId = await _resolveStudentRecordId(studentId);

      if (resolvedStudentId == null) {
        return const Result.success([]);
      }

      const attendanceRecordDetailsSelect = '''
        id,
        session_id,
        student_id,
        attendance_percentage,
        attendance_method,
        attendance_status,
        frames_detected,
        total_frames,
        created_at,
        attendance_sessions!inner(
          id,
          session_date,
          start_time,
          end_time,
          subject_id,
          subjects(name),
          teachers(name),
          departments(name),
          batches(name),
          semesters(name)
        )
      ''';

      if (subjectId != null && subjectId.trim().isNotEmpty) {
        final sessionRows = await client
            .from('attendance_sessions')
            .select('id')
            .eq('subject_id', subjectId.trim());

        final sessionIds = sessionRows
            .map((row) => row['id'] as String)
            .toList();

        if (sessionIds.isEmpty) {
          return const Result.success([]);
        }

        final rows = await client
            .from('attendance_records')
            .select(attendanceRecordDetailsSelect)
            .eq('student_id', resolvedStudentId)
            .inFilter('session_id', sessionIds)
            .order('created_at', ascending: false);

        final records = rows
            .map(
              (row) => AttendanceRecordModel.fromJson(
                Map<String, dynamic>.from(row),
              ),
            )
            .toList();

        return Result.success(records);
      }

      final rows = await client
          .from('attendance_records')
          .select(attendanceRecordDetailsSelect)
          .eq('student_id', resolvedStudentId)
          .order('created_at', ascending: false);

      final records = rows
          .map(
            (row) =>
                AttendanceRecordModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();

      return Result.success(records);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load student attendance right now.',
          code: 'student_attendance_load_failed',
        ),
      );
    }
  }

  Future<Result<List<AttendanceReportModel>>> getAttendanceReports({
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? subjectId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return getAdminAttendanceReports(
      departmentId: departmentId,
      batchId: batchId,
      semesterId: semesterId,
      subjectId: subjectId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<Result<List<AttendanceReportModel>>> getTeacherAttendanceReports({
    required String teacherId,
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? subjectId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockAttendanceReports().take(2).toList());
    }

    try {
      final resolvedTeacherId = await _resolveTeacherRecordId(teacherId);

      if (resolvedTeacherId == null) {
        return const Result.success([]);
      }

      final reports = await _loadAttendanceReports(
        teacherId: resolvedTeacherId,
        departmentId: departmentId,
        batchId: batchId,
        semesterId: semesterId,
        subjectId: subjectId,
        fromDate: fromDate,
        toDate: toDate,
      );

      return Result.success(reports);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load teacher attendance reports right now.',
          code: 'teacher_attendance_reports_load_failed',
        ),
      );
    }
  }

  Future<Result<List<AttendanceReportModel>>> getAdminAttendanceReports({
    String? teacherId,
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? subjectId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockAttendanceReports());
    }

    try {
      final reports = await _loadAttendanceReportsFromRecords(
        teacherId: teacherId,
        departmentId: departmentId,
        batchId: batchId,
        semesterId: semesterId,
        subjectId: subjectId,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      );

      return Result.success(reports);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load admin attendance reports right now.',
          code: 'admin_attendance_reports_load_failed',
        ),
      );
    }
  }

  Future<List<AttendanceReportModel>> _loadAttendanceReports({
    String? teacherId,
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? subjectId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final client = supabaseService?.client;

    if (client == null) {
      throw const AppException(
        message: 'Supabase is not configured. Please check environment setup.',
        code: 'supabase_not_ready',
      );
    }

    var query = client
        .from('attendance_sessions')
        .select(_attendanceSessionReportSelect);

    if (teacherId != null && teacherId.trim().isNotEmpty) {
      query = query.eq('teacher_id', teacherId.trim());
    }

    if (departmentId != null && departmentId.trim().isNotEmpty) {
      query = query.eq('department_id', departmentId.trim());
    }

    if (batchId != null && batchId.trim().isNotEmpty) {
      query = query.eq('batch_id', batchId.trim());
    }

    if (semesterId != null && semesterId.trim().isNotEmpty) {
      query = query.eq('semester_id', semesterId.trim());
    }

    if (subjectId != null && subjectId.trim().isNotEmpty) {
      query = query.eq('subject_id', subjectId.trim());
    }

    if (status != null && status.trim().isNotEmpty) {
      query = query.eq('status', status.trim().toLowerCase());
    }

    if (fromDate != null) {
      query = query.gte('session_date', _dateOnly(fromDate));
    }

    if (toDate != null) {
      query = query.lte('session_date', _dateOnly(toDate));
    }

    final sessionRows = await query
        .order('session_date', ascending: false)
        .order('start_time', ascending: false);

    final sessionIds = sessionRows.map((row) => row['id'] as String).toList();

    if (sessionIds.isEmpty) {
      return [];
    }

    final recordRows = await client
        .from('attendance_records')
        .select(_attendanceStudentRecordSelect)
        .inFilter('session_id', sessionIds)
        .order('created_at', ascending: false);

    final recordsBySession = <String, List<AttendanceStudentRecordModel>>{};

    for (final row in recordRows) {
      final record = AttendanceStudentRecordModel.fromJson(
        Map<String, dynamic>.from(row),
      );

      recordsBySession.putIfAbsent(record.sessionId, () => []).add(record);
    }

    return sessionRows.map((row) {
      final session = Map<String, dynamic>.from(row);
      final sessionId = session['id'] as String;

      return AttendanceReportModel.fromSessionJson(
        json: session,
        records: recordsBySession[sessionId] ?? const [],
      );
    }).toList();
  }

  Future<List<AttendanceReportModel>> _loadAttendanceReportsFromRecords({
    String? teacherId,
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? subjectId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final client = supabaseService?.client;

    if (client == null) {
      throw const AppException(
        message: 'Supabase is not configured. Please check environment setup.',
        code: 'supabase_not_ready',
      );
    }

    var query = client
        .from('attendance_records')
        .select(_attendanceRecordReportSelect);

    if (teacherId != null && teacherId.trim().isNotEmpty) {
      query = query.eq('attendance_sessions.teacher_id', teacherId.trim());
    }

    if (departmentId != null && departmentId.trim().isNotEmpty) {
      query = query.eq(
        'attendance_sessions.department_id',
        departmentId.trim(),
      );
    }

    if (batchId != null && batchId.trim().isNotEmpty) {
      query = query.eq('attendance_sessions.batch_id', batchId.trim());
    }

    if (semesterId != null && semesterId.trim().isNotEmpty) {
      query = query.eq('attendance_sessions.semester_id', semesterId.trim());
    }

    if (subjectId != null && subjectId.trim().isNotEmpty) {
      query = query.eq('attendance_sessions.subject_id', subjectId.trim());
    }

    if (status != null && status.trim().isNotEmpty) {
      query = query.eq(
        'attendance_sessions.status',
        status.trim().toLowerCase(),
      );
    }

    if (fromDate != null) {
      query = query.gte(
        'attendance_sessions.session_date',
        _dateOnly(fromDate),
      );
    }

    if (toDate != null) {
      query = query.lte('attendance_sessions.session_date', _dateOnly(toDate));
    }

    final recordRows = await query.order('created_at', ascending: false);
    final sessionById = <String, Map<String, dynamic>>{};
    final recordsBySession = <String, List<AttendanceStudentRecordModel>>{};

    for (final row in recordRows) {
      final recordJson = Map<String, dynamic>.from(row);
      final sessionJson = _mapOrNull(recordJson['attendance_sessions']);

      if (sessionJson == null) {
        continue;
      }

      final sessionId = sessionJson['id'] as String;
      sessionById.putIfAbsent(sessionId, () => sessionJson);

      final record = AttendanceStudentRecordModel.fromJson(recordJson);
      recordsBySession.putIfAbsent(sessionId, () => []).add(record);
    }

    final reports = sessionById.entries.map((entry) {
      return AttendanceReportModel.fromSessionJson(
        json: entry.value,
        records: recordsBySession[entry.key] ?? const [],
      );
    }).toList();

    reports.sort(_compareReportsDescending);

    return reports;
  }

  Future<List<FaceRecognitionStudentCandidateModel>>
  _loadEnrolledStudentsForSession(AttendanceSessionModel session) async {
    final client = supabaseService?.client;

    if (client == null) {
      return const [];
    }

    final rows = await client
        .from('student_subjects')
        .select('student_id, students(name, roll_no)')
        .eq('subject_id', session.subjectId)
        .eq('department_id', session.departmentId)
        .eq('batch_id', session.batchId)
        .eq('semester_id', session.semesterId)
        .eq('is_active', true);

    return rows
        .map((row) {
          final data = Map<String, dynamic>.from(row);
          final studentId = data['student_id']?.toString().trim() ?? '';
          final student = _mapOrNull(data['students']);

          if (studentId.isEmpty) {
            return null;
          }

          return FaceRecognitionStudentCandidateModel(
            studentId: studentId,
            studentName: _textOrNull(student?['name']),
            rollNo: _textOrNull(student?['roll_no']),
          );
        })
        .whereType<FaceRecognitionStudentCandidateModel>()
        .toList();
  }

  FaceRecognitionSessionResultModel _mergeFaceRecognitionResults({
    required FaceRecognitionSessionResultModel apiResult,
    required List<FaceRecognitionStudentCandidateModel> enrolledStudents,
    required int totalFrames,
  }) {
    final resultsByStudentId = <String, FaceRecognitionAttendanceResultModel>{};

    for (final result in apiResult.results) {
      final studentId = result.studentId.trim();

      if (studentId.isNotEmpty) {
        resultsByStudentId[studentId] = result;
      }
    }

    final mergedResults = enrolledStudents.map((student) {
      final apiStudentResult = resultsByStudentId[student.studentId];

      if (apiStudentResult == null) {
        return FaceRecognitionAttendanceResultModel(
          studentId: student.studentId,
          studentName: student.studentName,
          rollNo: student.rollNo,
          framesDetected: 0,
          totalFrames: totalFrames,
          attendancePercentage: 0,
          attendanceStatus: 'absent',
          message: 'No face match returned for this student.',
        );
      }

      return apiStudentResult.copyWith(
        studentName: student.studentName ?? apiStudentResult.studentName,
        rollNo: student.rollNo ?? apiStudentResult.rollNo,
        totalFrames: apiStudentResult.totalFrames <= 0
            ? totalFrames
            : apiStudentResult.totalFrames,
        recognitionMethod: 'face_recognition',
      );
    }).toList();

    return apiResult.copyWith(
      results: mergedResults,
      totalFrames: totalFrames,
      usedFallback: false,
      message: apiResult.message.trim().isEmpty
          ? 'Face Recognition API processed the attendance session.'
          : apiResult.message,
    );
  }

  FaceRecognitionSessionResultModel _buildFaceRecognitionFallback({
    required List<FaceRecognitionStudentCandidateModel> enrolledStudents,
    required int totalFrames,
    required String message,
  }) {
    final safeTotalFrames = totalFrames <= 0 ? 20 : totalFrames;
    final ratios = [0.90, 0.80, 0.70, 0.55];
    final results = <FaceRecognitionAttendanceResultModel>[];

    for (var index = 0; index < enrolledStudents.length; index++) {
      final student = enrolledStudents[index];
      final ratio = ratios[index % ratios.length];
      final framesDetected = (safeTotalFrames * ratio).round();
      final percentage = ((framesDetected / safeTotalFrames) * 100)
          .clamp(0, 100)
          .toDouble();

      results.add(
        FaceRecognitionAttendanceResultModel(
          studentId: student.studentId,
          studentName: student.studentName,
          rollNo: student.rollNo,
          framesDetected: framesDetected,
          totalFrames: safeTotalFrames,
          attendancePercentage: percentage,
          attendanceStatus: percentage >= 75 ? 'present' : 'absent',
          confidence: ratio,
          message: message,
        ),
      );
    }

    return FaceRecognitionSessionResultModel(
      results: results,
      totalFrames: safeTotalFrames,
      usedFallback: true,
      message: message,
    );
  }

  List<FaceRecognitionStudentCandidateModel> _mockFaceRecognitionCandidates() {
    return const [
      FaceRecognitionStudentCandidateModel(
        studentId: 'mock-student-001',
        studentName: 'Ali Khan',
        rollNo: 'BSIT-2022-001',
      ),
      FaceRecognitionStudentCandidateModel(
        studentId: 'mock-student-002',
        studentName: 'Sara Ahmed',
        rollNo: 'BSIT-2022-002',
      ),
      FaceRecognitionStudentCandidateModel(
        studentId: 'mock-student-003',
        studentName: 'Ahmed Raza',
        rollNo: 'BSIT-2022-003',
      ),
      FaceRecognitionStudentCandidateModel(
        studentId: 'mock-student-004',
        studentName: 'Fatima Noor',
        rollNo: 'BSIT-2022-004',
      ),
    ];
  }

  Future<StudentQrIdentityModel?> _loadStudentQrIdentity(
    String studentIdentifier,
  ) async {
    final client = supabaseService?.client;

    if (client == null || studentIdentifier.trim().isEmpty) {
      return null;
    }

    final normalizedIdentifier = studentIdentifier.trim();
    final studentByUserId = await client
        .from('students')
        .select(_studentQrIdentitySelect)
        .eq('user_id', normalizedIdentifier)
        .maybeSingle();

    if (studentByUserId != null) {
      return StudentQrIdentityModel.fromJson(
        Map<String, dynamic>.from(studentByUserId),
      );
    }

    final studentById = await client
        .from('students')
        .select(_studentQrIdentitySelect)
        .eq('id', normalizedIdentifier)
        .maybeSingle();

    if (studentById != null) {
      return StudentQrIdentityModel.fromJson(
        Map<String, dynamic>.from(studentById),
      );
    }

    return null;
  }

  Future<Map<String, dynamic>?> _findActiveAttendanceSession(
    String teacherId,
  ) async {
    final client = supabaseService?.client;

    if (client == null) {
      return null;
    }

    final now = DateTime.now();
    final rows = await client
        .from('attendance_sessions')
        .select(_activeAttendanceSessionSelect)
        .eq('teacher_id', teacherId)
        .eq('status', 'active')
        .eq('session_date', _dateOnly(now))
        .order('created_at', ascending: false)
        .order('start_time', ascending: false);

    if (rows.isEmpty) {
      return null;
    }

    final currentMinutes = (now.hour * 60) + now.minute;

    for (final row in rows) {
      final session = Map<String, dynamic>.from(row);
      final startMinutes = _timeToMinutes(session['start_time'].toString());
      final endMinutes = _timeToMinutes(session['end_time'].toString());

      if (startMinutes == null || endMinutes == null) {
        continue;
      }

      if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return session;
      }
    }

    return Map<String, dynamic>.from(rows.first);
  }

  Future<bool> _isStudentEnrolledForSession({
    required String studentId,
    required Map<String, dynamic> session,
  }) async {
    final client = supabaseService?.client;

    if (client == null) {
      return false;
    }

    final row = await client
        .from('student_subjects')
        .select('id')
        .eq('student_id', studentId)
        .eq('subject_id', session['subject_id'] as String)
        .eq('department_id', session['department_id'] as String)
        .eq('batch_id', session['batch_id'] as String)
        .eq('semester_id', session['semester_id'] as String)
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();

    return row != null;
  }

  Future<String?> _resolveTeacherRecordId(String teacherId) async {
    final client = supabaseService?.client;

    if (client == null) {
      return null;
    }

    final teacherById = await client
        .from('teachers')
        .select('id')
        .eq('id', teacherId)
        .maybeSingle();

    if (teacherById != null) {
      return teacherById['id'] as String;
    }

    final teacherByUserId = await client
        .from('teachers')
        .select('id')
        .eq('user_id', teacherId)
        .maybeSingle();

    if (teacherByUserId != null) {
      return teacherByUserId['id'] as String;
    }

    return null;
  }

  Future<String?> _resolveStudentRecordId(String studentId) async {
    final client = supabaseService?.client;

    if (client == null) {
      return null;
    }

    final studentById = await client
        .from('students')
        .select('id')
        .eq('id', studentId)
        .maybeSingle();

    if (studentById != null) {
      return studentById['id'] as String;
    }

    final studentByUserId = await client
        .from('students')
        .select('id')
        .eq('user_id', studentId)
        .maybeSingle();

    if (studentByUserId != null) {
      return studentByUserId['id'] as String;
    }

    return null;
  }

  TimetableModel? _findActiveClass(
    List<TimetableModel> timetable,
    DateTime dateTime,
  ) {
    final currentDay = _weekdayName(dateTime);
    final currentMinutes = (dateTime.hour * 60) + dateTime.minute;

    for (final item in timetable) {
      if (_normalizeDay(item.day) != currentDay) {
        continue;
      }

      final startMinutes = _timeToMinutes(item.startTime);
      final endMinutes = _timeToMinutes(item.endTime);

      if (startMinutes == null || endMinutes == null) {
        continue;
      }

      if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return item;
      }
    }

    return null;
  }

  int? _timeToMinutes(String value) {
    final parts = value.trim().split(':');

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    return (hour * 60) + minute;
  }

  String _weekdayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
    }

    return '';
  }

  String _normalizeDay(String value) {
    return value.trim().toLowerCase();
  }

  List<TimetableModel> _mockTeacherTimetable({String? day}) {
    final timetable = [
      const TimetableModel(
        id: 'mock-timetable-001',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-database-systems',
        departmentId: 'mock-department-bsit',
        batchId: 'mock-batch-2022',
        semesterId: 'mock-semester-8',
        day: 'monday',
        startTime: '09:00:00',
        endTime: '10:00:00',
      ),
      const TimetableModel(
        id: 'mock-timetable-002',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-web-engineering',
        departmentId: 'mock-department-bsse',
        batchId: 'mock-batch-2023',
        semesterId: 'mock-semester-6',
        day: 'monday',
        startTime: '11:00:00',
        endTime: '12:00:00',
      ),
    ];

    if (day == null || day.trim().isEmpty) {
      return timetable;
    }

    final normalizedDay = _normalizeDay(day);

    return timetable
        .where((item) => _normalizeDay(item.day) == normalizedDay)
        .toList();
  }

  List<AttendanceRecordModel> _mockStudentAttendance() {
    final now = DateTime.now();

    return [
      AttendanceRecordModel(
        id: 'mock-attendance-record-001',
        sessionId: 'mock-session-database-systems',
        studentId: 'mock-student-001',
        attendancePercentage: 90,
        attendanceMethod: 'face_recognition',
        attendanceStatus: 'present',
        framesDetected: 18,
        totalFrames: 20,
        createdAt: now,
        sessionDate: now,
        startTime: '09:00:00',
        endTime: '10:00:00',
        subjectName: 'Database Systems',
        teacherName: 'Mr. Ahmad',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
      AttendanceRecordModel(
        id: 'mock-attendance-record-002',
        sessionId: 'mock-session-web-engineering',
        studentId: 'mock-student-001',
        attendancePercentage: 80,
        attendanceMethod: 'face_recognition',
        attendanceStatus: 'present',
        framesDetected: 16,
        totalFrames: 20,
        createdAt: now.subtract(const Duration(days: 1)),
        sessionDate: now.subtract(const Duration(days: 1)),
        startTime: '11:00:00',
        endTime: '12:00:00',
        subjectName: 'Web Engineering',
        teacherName: 'Mr. Ahmad',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
      AttendanceRecordModel(
        id: 'mock-attendance-record-003',
        sessionId: 'mock-session-software-project',
        studentId: 'mock-student-001',
        attendancePercentage: 70,
        attendanceMethod: 'face_recognition',
        attendanceStatus: 'absent',
        framesDetected: 14,
        totalFrames: 20,
        createdAt: now.subtract(const Duration(days: 2)),
        sessionDate: now.subtract(const Duration(days: 2)),
        startTime: '01:00:00',
        endTime: '02:00:00',
        subjectName: 'Software Project',
        teacherName: 'Mr. Ahmad',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
    ];
  }

  StudentQrIdentityModel _mockStudentQrIdentity() {
    return const StudentQrIdentityModel(
      studentUserId: 'mock-app-user-student',
      studentId: 'mock-student-001',
      name: 'Ali Khan',
      rollNo: 'BSIT-2022-001',
      departmentName: 'Computer Science',
      batchName: 'BSIT 2022',
      semesterName: '8th Semester',
    );
  }

  List<AttendanceReportModel> _mockAttendanceReports() {
    final now = DateTime.now();
    final sessionDate = DateTime(now.year, now.month, now.day);

    final databaseRecords = [
      AttendanceStudentRecordModel(
        id: 'mock-report-record-001',
        sessionId: 'mock-session-database-systems',
        studentId: 'mock-student-001',
        attendancePercentage: 90,
        attendanceMethod: 'face_recognition',
        attendanceStatus: 'present',
        framesDetected: 18,
        totalFrames: 20,
        createdAt: now,
        studentName: 'Ali Khan',
        rollNo: 'BSIT-2022-001',
      ),
      AttendanceStudentRecordModel(
        id: 'mock-report-record-002',
        sessionId: 'mock-session-database-systems',
        studentId: 'mock-student-002',
        attendancePercentage: 80,
        attendanceMethod: 'face_recognition',
        attendanceStatus: 'present',
        framesDetected: 16,
        totalFrames: 20,
        createdAt: now,
        studentName: 'Sara Ahmed',
        rollNo: 'BSIT-2022-002',
      ),
      AttendanceStudentRecordModel(
        id: 'mock-report-record-003',
        sessionId: 'mock-session-database-systems',
        studentId: 'mock-student-003',
        attendancePercentage: 70,
        attendanceMethod: 'face_recognition',
        attendanceStatus: 'absent',
        framesDetected: 14,
        totalFrames: 20,
        createdAt: now,
        studentName: 'Ahmed Raza',
        rollNo: 'BSIT-2022-003',
      ),
      AttendanceStudentRecordModel(
        id: 'mock-report-record-004',
        sessionId: 'mock-session-database-systems',
        studentId: 'mock-student-004',
        attendancePercentage: 100,
        attendanceMethod: 'dynamic_qr',
        attendanceStatus: 'present',
        framesDetected: 0,
        totalFrames: 0,
        createdAt: now,
        studentName: 'Fatima Noor',
        rollNo: 'BSIT-2022-004',
      ),
    ];

    return [
      AttendanceReportModel(
        sessionId: 'mock-session-database-systems',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-database-systems',
        departmentId: 'mock-department-bsit',
        batchId: 'mock-batch-2022',
        semesterId: 'mock-semester-8',
        sessionDate: sessionDate,
        startTime: '09:00:00',
        endTime: '10:00:00',
        status: 'completed',
        createdAt: now,
        records: databaseRecords,
        teacherName: 'Mr. Ahmad',
        subjectName: 'Database Systems',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
      AttendanceReportModel(
        sessionId: 'mock-session-web-engineering',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-web-engineering',
        departmentId: 'mock-department-bsit',
        batchId: 'mock-batch-2022',
        semesterId: 'mock-semester-8',
        sessionDate: sessionDate.subtract(const Duration(days: 1)),
        startTime: '11:00:00',
        endTime: '12:00:00',
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 1)),
        records: [
          AttendanceStudentRecordModel(
            id: 'mock-report-record-005',
            sessionId: 'mock-session-web-engineering',
            studentId: 'mock-student-001',
            attendancePercentage: 85,
            attendanceMethod: 'face_recognition',
            attendanceStatus: 'present',
            framesDetected: 17,
            totalFrames: 20,
            createdAt: now.subtract(const Duration(days: 1)),
            studentName: 'Ali Khan',
            rollNo: 'BSIT-2022-001',
          ),
        ],
        teacherName: 'Mr. Ahmad',
        subjectName: 'Web Engineering',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
    ];
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '${value.year}-$month-$day';
  }

  Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  String? _textOrNull(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  int _compareReportsDescending(
    AttendanceReportModel first,
    AttendanceReportModel second,
  ) {
    final dateCompare = second.sessionDate.compareTo(first.sessionDate);

    if (dateCompare != 0) {
      return dateCompare;
    }

    return second.startTime.compareTo(first.startTime);
  }

  bool get _shouldUseMockData {
    return supabaseService == null || supabaseService!.isMockMode;
  }
}
