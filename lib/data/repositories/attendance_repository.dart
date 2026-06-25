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
    return _notImplemented('Attendance record saving');
  }

  Future<Result<List<AttendanceRecordModel>>> getStudentAttendance({
    required String studentId,
    String? subjectId,
  }) async {
    return _notImplemented('Student attendance lookup');
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

  bool get _shouldUseMockData {
    return supabaseService == null || supabaseService!.isMockMode;
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
