import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/attendance_record_model.dart';
import 'package:eduvision_app/data/models/attendance_session_model.dart';
import 'package:eduvision_app/data/models/timetable_model.dart';
import 'package:eduvision_app/data/services/face_api_service.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class AttendanceRepository {
  const AttendanceRepository({this.supabaseService, this.faceApiService});

  final SupabaseService? supabaseService;
  final FaceApiService? faceApiService;

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

  Future<Result<void>> saveDemoAttendanceRecordForSession({
    required AttendanceSessionModel session,
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

      final enrolledStudent = await client
          .from('student_subjects')
          .select('student_id')
          .eq('subject_id', session.subjectId)
          .limit(1)
          .maybeSingle();

      final studentId = enrolledStudent?['student_id'] as String?;

      if (studentId == null || studentId.trim().isEmpty) {
        return const Result.failure(
          AppException(
            message: 'No enrolled student found for this active class.',
            code: 'attendance_record_student_not_found',
          ),
        );
      }

      final record = AttendanceRecordModel(
        id: '',
        sessionId: session.id,
        studentId: studentId,
        attendancePercentage: 90,
        attendanceMethod: 'face_recognition',
        attendanceStatus: 'present',
        framesDetected: 18,
        totalFrames: 20,
        createdAt: DateTime.now(),
      );

      return saveAttendanceRecord(record: record);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to save demo attendance record right now.',
          code: 'demo_attendance_record_save_failed',
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
            .select()
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
          .select()
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

  Future<Result<List<AttendanceRecordModel>>> getAttendanceReports({
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? subjectId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return _notImplemented('Attendance report lookup');
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
      ),
    ];
  }

  bool get _shouldUseMockData {
    return supabaseService == null || supabaseService!.isMockMode;
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
