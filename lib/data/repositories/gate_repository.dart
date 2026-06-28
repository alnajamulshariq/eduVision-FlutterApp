import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/data/services/qr_token_service.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class GateRepository {
  const GateRepository({this.supabaseService, this.qrTokenService});

  final SupabaseService? supabaseService;
  final QrTokenService? qrTokenService;

  static const _gateLogDetailsSelect = '''
    id,
    student_id,
    log_date,
    log_time,
    status,
    gate_location,
    parent_email_sent,
    students(
      name,
      roll_no,
      parent_email,
      departments(name),
      batches(name),
      semesters(name)
    )
  ''';

  static const _studentDetailsSelect = '''
    id,
    name,
    roll_no,
    parent_email,
    departments(name),
    batches(name),
    semesters(name)
  ''';

  Future<Result<GateLogModel>> createGateLog({
    required GateLogModel gateLog,
  }) async {
    if (_shouldUseMockData) {
      final mockId = gateLog.id.trim().isEmpty
          ? 'mock-gate-log-${DateTime.now().millisecondsSinceEpoch}'
          : gateLog.id;

      return Result.success(gateLog.copyWith(id: mockId));
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

      final payload = gateLog.toJson();

      if ((payload['id'] as String?)?.trim().isEmpty ?? true) {
        payload.remove('id');
      }

      final row = await client
          .from('gate_logs')
          .insert(payload)
          .select(_gateLogDetailsSelect)
          .single();

      return Result.success(
        GateLogModel.fromJson(Map<String, dynamic>.from(row)),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to create gate log right now.',
          code: 'gate_log_create_failed',
        ),
      );
    }
  }

  Future<Result<GateLogModel>> createNextGateLogForStudent({
    required String studentId,
    String gateLocation = 'Main Gate',
  }) async {
    if (_shouldUseMockData) {
      final nextStatus = _nextGateAction(
        _mockGateLogs()
            .where((log) => log.studentId == studentId || studentId.isEmpty)
            .toList(),
      );
      final now = DateTime.now();

      return createGateLog(
        gateLog: GateLogModel(
          id: '',
          studentId: studentId.isEmpty ? 'mock-student-001' : studentId,
          date: DateTime(now.year, now.month, now.day),
          time: _timeOnly(now),
          status: nextStatus,
          gateLocation: gateLocation,
          parentEmailSent: false,
          studentName: 'Ali Khan',
          rollNo: 'BSIT-2022-001',
          parentEmail: 'parent@example.com',
          departmentName: 'Computer Science',
          batchName: 'BSIT 2022',
          semesterName: '8th Semester',
        ),
      );
    }

    try {
      final resolvedStudentId = await _resolveStudentRecordId(studentId);

      if (resolvedStudentId == null) {
        return const Result.failure(
          AppException(
            message: 'No student profile was found for this gate scan.',
            code: 'gate_log_student_not_found',
          ),
        );
      }

      final nextStatus = await _determineNextGateActionForResolvedStudent(
        resolvedStudentId,
      );
      final now = DateTime.now();

      return createGateLog(
        gateLog: GateLogModel(
          id: '',
          studentId: resolvedStudentId,
          date: DateTime(now.year, now.month, now.day),
          time: _timeOnly(now),
          status: nextStatus,
          gateLocation: gateLocation,
          parentEmailSent: false,
        ),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to save the next gate scan right now.',
          code: 'next_gate_log_create_failed',
        ),
      );
    }
  }

  Future<Result<GateLogModel>> createNextGateLogFromQrPayload({
    required String payload,
    String gateLocation = 'Main Gate',
  }) async {
    final tokenResult = (qrTokenService ?? const QrTokenService())
        .parseGatePayload(payload: payload);

    if (tokenResult case Failure<DynamicQrPayload>(:final exception)) {
      return Result.failure(exception);
    }

    final token = (tokenResult as Success<DynamicQrPayload>).data;

    return createNextGateLogForStudent(
      studentId: token.lookupId,
      gateLocation: gateLocation,
    );
  }

  Future<Result<GateLogModel>> createNextGateLogForFirstActiveStudent({
    String gateLocation = 'Main Gate',
  }) async {
    if (_shouldUseMockData) {
      return createNextGateLogForStudent(
        studentId: 'mock-student-001',
        gateLocation: gateLocation,
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

      final row = await client
          .from('students')
          .select('id')
          .eq('is_active', true)
          .order('roll_no')
          .limit(1)
          .maybeSingle();

      final studentId = row?['id'] as String?;

      if (studentId == null || studentId.trim().isEmpty) {
        return const Result.failure(
          AppException(
            message: 'No active student was found for gate scan demo.',
            code: 'active_student_not_found',
          ),
        );
      }

      return createNextGateLogForStudent(
        studentId: studentId,
        gateLocation: gateLocation,
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to find an active student for gate scan demo.',
          code: 'active_student_lookup_failed',
        ),
      );
    }
  }

  Future<Result<List<GateLogModel>>> getStudentGateHistory({
    required String studentId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockGateLogs());
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

      final rows = await client
          .from('gate_logs')
          .select(_gateLogDetailsSelect)
          .eq('student_id', resolvedStudentId)
          .order('log_date', ascending: false)
          .order('log_time', ascending: false);

      final logs = rows
          .map((row) => GateLogModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      return Result.success(logs);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load student gate history right now.',
          code: 'student_gate_history_load_failed',
        ),
      );
    }
  }

  Future<Result<List<GateLogModel>>> getAdminGateLogs({
    DateTime? date,
    String? status,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockGateLogs());
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

      final normalizedStatus = status?.trim().toLowerCase();

      final rows = date == null
          ? normalizedStatus == null || normalizedStatus.isEmpty
                ? await client
                      .from('gate_logs')
                      .select(_gateLogDetailsSelect)
                      .order('log_date', ascending: false)
                      .order('log_time', ascending: false)
                : await client
                      .from('gate_logs')
                      .select(_gateLogDetailsSelect)
                      .eq('status', normalizedStatus)
                      .order('log_date', ascending: false)
                      .order('log_time', ascending: false)
          : normalizedStatus == null || normalizedStatus.isEmpty
          ? await client
                .from('gate_logs')
                .select(_gateLogDetailsSelect)
                .eq('log_date', _dateOnly(date))
                .order('log_date', ascending: false)
                .order('log_time', ascending: false)
          : await client
                .from('gate_logs')
                .select(_gateLogDetailsSelect)
                .eq('log_date', _dateOnly(date))
                .eq('status', normalizedStatus)
                .order('log_date', ascending: false)
                .order('log_time', ascending: false);

      final logs = rows
          .map((row) => GateLogModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      return Result.success(logs);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load admin gate logs right now.',
          code: 'admin_gate_logs_load_failed',
        ),
      );
    }
  }

  Future<Result<List<GateLogModel>>> getTeacherStudentGateStatus({
    required String teacherId,
    required String subjectId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockTeacherGateStatus());
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

      final studentIds = await _studentIdsForTeacher(
        teacherId: resolvedTeacherId,
        subjectId: subjectId,
      );

      if (studentIds.isEmpty) {
        return const Result.success([]);
      }

      final statuses = await _latestGateLogsForStudents(studentIds);

      return Result.success(statuses);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load teacher gate monitoring right now.',
          code: 'teacher_gate_monitoring_load_failed',
        ),
      );
    }
  }

  Future<Result<String>> determineNextGateAction({
    required String studentId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_nextGateAction(_mockGateLogs()));
    }

    try {
      final resolvedStudentId = await _resolveStudentRecordId(studentId);

      if (resolvedStudentId == null) {
        return const Result.failure(
          AppException(
            message: 'No student profile was found for this gate action.',
            code: 'gate_action_student_not_found',
          ),
        );
      }

      final action = await _determineNextGateActionForResolvedStudent(
        resolvedStudentId,
      );

      return Result.success(action);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to determine next gate action right now.',
          code: 'next_gate_action_failed',
        ),
      );
    }
  }

  Future<Result<GateLogModel?>> getLatestGateLogForStudent({
    required String studentId,
  }) async {
    if (_shouldUseMockData) {
      final logs = _mockGateLogs();
      return Result.success(logs.isEmpty ? null : logs.first);
    }

    try {
      final resolvedStudentId = await _resolveStudentRecordId(studentId);

      if (resolvedStudentId == null) {
        return const Result.success(null);
      }

      final latestLog = await _latestGateLogForResolvedStudent(
        resolvedStudentId,
      );

      return Result.success(latestLog);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load latest gate log right now.',
          code: 'latest_gate_log_load_failed',
        ),
      );
    }
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

  Future<List<String>> _studentIdsForTeacher({
    required String teacherId,
    required String subjectId,
  }) async {
    final client = supabaseService?.client;

    if (client == null) {
      return [];
    }

    final subjectIds = subjectId.trim().isNotEmpty
        ? [subjectId.trim()]
        : await _subjectIdsForTeacher(teacherId);

    if (subjectIds.isEmpty) {
      return [];
    }

    final rows = subjectIds.length == 1
        ? await client
              .from('student_subjects')
              .select('student_id')
              .eq('is_active', true)
              .eq('subject_id', subjectIds.first)
        : await client
              .from('student_subjects')
              .select('student_id')
              .eq('is_active', true)
              .inFilter('subject_id', subjectIds);

    return rows.map((row) => row['student_id'] as String).toSet().toList();
  }

  Future<List<String>> _subjectIdsForTeacher(String teacherId) async {
    final client = supabaseService?.client;

    if (client == null) {
      return [];
    }

    final rows = await client
        .from('teacher_subjects')
        .select('subject_id')
        .eq('teacher_id', teacherId)
        .eq('is_active', true);

    return rows.map((row) => row['subject_id'] as String).toSet().toList();
  }

  Future<List<GateLogModel>> _latestGateLogsForStudents(
    List<String> studentIds,
  ) async {
    final client = supabaseService?.client;

    if (client == null || studentIds.isEmpty) {
      return [];
    }

    final studentRows = await client
        .from('students')
        .select(_studentDetailsSelect)
        .inFilter('id', studentIds)
        .order('roll_no');

    final logRows = await client
        .from('gate_logs')
        .select(_gateLogDetailsSelect)
        .inFilter('student_id', studentIds)
        .order('log_date', ascending: false)
        .order('log_time', ascending: false);

    final latestLogsByStudent = <String, GateLogModel>{};

    for (final row in logRows) {
      final log = GateLogModel.fromJson(Map<String, dynamic>.from(row));
      latestLogsByStudent.putIfAbsent(log.studentId, () => log);
    }

    return studentRows.map((row) {
      final student = Map<String, dynamic>.from(row);
      final studentId = student['id'] as String;

      return latestLogsByStudent[studentId] ??
          _notScannedGateStatusFromStudent(student);
    }).toList();
  }

  Future<GateLogModel?> _latestGateLogForResolvedStudent(
    String studentId,
  ) async {
    final client = supabaseService?.client;

    if (client == null) {
      return null;
    }

    final row = await client
        .from('gate_logs')
        .select(_gateLogDetailsSelect)
        .eq('student_id', studentId)
        .order('log_date', ascending: false)
        .order('log_time', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return GateLogModel.fromJson(Map<String, dynamic>.from(row));
  }

  Future<String> _determineNextGateActionForResolvedStudent(
    String studentId,
  ) async {
    final latestLog = await _latestGateLogForResolvedStudent(studentId);

    if (latestLog == null) {
      return 'entry';
    }

    return latestLog.status == 'entry' ? 'exit' : 'entry';
  }

  GateLogModel _notScannedGateStatusFromStudent(Map<String, dynamic> student) {
    final now = DateTime.now();

    return GateLogModel(
      id: '',
      studentId: student['id'] as String,
      date: DateTime(now.year, now.month, now.day),
      time: '',
      status: 'not_scanned',
      gateLocation: 'Main Gate',
      parentEmailSent: false,
      studentName: student['name'] as String?,
      rollNo: student['roll_no'] as String?,
      parentEmail: student['parent_email'] as String?,
      departmentName: _nestedName(student, 'departments'),
      batchName: _nestedName(student, 'batches'),
      semesterName: _nestedName(student, 'semesters'),
    );
  }

  String _nextGateAction(List<GateLogModel> logs) {
    if (logs.isEmpty || logs.first.status == 'exit') {
      return 'entry';
    }

    return 'exit';
  }

  List<GateLogModel> _mockGateLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      GateLogModel(
        id: 'mock-gate-log-003',
        studentId: 'mock-student-001',
        date: today,
        time: '12:15:00',
        status: 'entry',
        gateLocation: 'Main Gate',
        parentEmailSent: true,
        studentName: 'Ali Khan',
        rollNo: 'BSIT-2022-001',
        parentEmail: 'parent@example.com',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
      GateLogModel(
        id: 'mock-gate-log-002',
        studentId: 'mock-student-001',
        date: today,
        time: '11:30:00',
        status: 'exit',
        gateLocation: 'Main Gate',
        parentEmailSent: true,
        studentName: 'Ali Khan',
        rollNo: 'BSIT-2022-001',
        parentEmail: 'parent@example.com',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
      GateLogModel(
        id: 'mock-gate-log-001',
        studentId: 'mock-student-001',
        date: today,
        time: '08:00:00',
        status: 'entry',
        gateLocation: 'Main Gate',
        parentEmailSent: true,
        studentName: 'Ali Khan',
        rollNo: 'BSIT-2022-001',
        parentEmail: 'parent@example.com',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
    ];
  }

  List<GateLogModel> _mockTeacherGateStatus() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      ..._mockGateLogs().take(1),
      GateLogModel(
        id: 'mock-gate-log-004',
        studentId: 'mock-student-002',
        date: today,
        time: '08:05:00',
        status: 'entry',
        gateLocation: 'Main Gate',
        parentEmailSent: true,
        studentName: 'Sara Ahmed',
        rollNo: 'BSIT-2022-002',
        parentEmail: 'parent2@example.com',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
      GateLogModel(
        id: 'mock-gate-log-005',
        studentId: 'mock-student-003',
        date: today,
        time: '12:30:00',
        status: 'exit',
        gateLocation: 'Main Gate',
        parentEmailSent: true,
        studentName: 'Ahmed Raza',
        rollNo: 'BSIT-2022-003',
        parentEmail: 'parent3@example.com',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
      ),
      GateLogModel(
        id: '',
        studentId: 'mock-student-004',
        date: today,
        time: '',
        status: 'not_scanned',
        gateLocation: 'Main Gate',
        parentEmailSent: false,
        studentName: 'Fatima Noor',
        rollNo: 'BSIT-2022-004',
        parentEmail: 'parent4@example.com',
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

  String _timeOnly(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }

  String? _nestedName(Map<String, dynamic> source, String key) {
    final nestedValue = source[key];

    if (nestedValue is Map<String, dynamic>) {
      final name = nestedValue['name'] as String?;

      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }

    if (nestedValue is Map) {
      final nested = Map<String, dynamic>.from(nestedValue);
      final name = nested['name'] as String?;

      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }

    return null;
  }

  bool get _shouldUseMockData {
    return supabaseService == null || supabaseService!.isMockMode;
  }

  // Kept for unimplemented future gate features.
  // ignore: unused_element
  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
