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
    return _notImplemented('Teacher timetable lookup');
  }

  Future<Result<TimetableModel?>> validateActiveClass({
    required String teacherId,
    required DateTime dateTime,
  }) async {
    return _notImplemented('Active class validation');
  }

  Future<Result<AttendanceSessionModel>> createAttendanceSession({
    required AttendanceSessionModel session,
  }) async {
    return _notImplemented('Attendance session creation');
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

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
