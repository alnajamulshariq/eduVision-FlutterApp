import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/anonymous_message_model.dart';
import 'package:eduvision_app/data/models/student_model.dart';
import 'package:eduvision_app/data/models/teacher_anonymous_message_model.dart';
import 'package:eduvision_app/data/models/teacher_model.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class MessageRepository {
  const MessageRepository({this.supabaseService});

  final SupabaseService? supabaseService;

  static const _adminMessageSelect = '''
    id,
    student_id,
    teacher_id,
    subject_id,
    message,
    status,
    is_reported,
    report_reason,
    created_at,
    resolved_at,
    subjects(name),
    teachers(name),
    students(
      name,
      roll_no,
      parent_email,
      department_id,
      batch_id,
      semester_id,
      departments(name),
      batches(name),
      semesters(name)
    ),
    message_reports(
      reason,
      status,
      created_at,
      teachers(name)
    )
  ''';

  static const _teacherMessageSelect = '''
    id,
    teacher_id,
    subject_id,
    message,
    status,
    is_reported,
    report_reason,
    created_at,
    resolved_at,
    subjects(name),
    message_reports(
      reason,
      status,
      created_at
    )
  ''';

  Future<Result<List<TeacherModel>>> getAvailableTeachersForStudent({
    required String studentId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockTeachers());
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

      final enrolledSubjectRows = await client
          .from('student_subjects')
          .select('subject_id')
          .eq('student_id', resolvedStudentId)
          .eq('is_active', true);

      final subjectIds = enrolledSubjectRows
          .map((row) => row['subject_id'] as String)
          .toSet()
          .toList();

      if (subjectIds.isEmpty) {
        final teacherRows = await client
            .from('teachers')
            .select('id, user_id, employee_id, name, department_id, is_active')
            .eq('is_active', true)
            .order('name');

        return Result.success(
          teacherRows
              .map(
                (row) => TeacherModel.fromJson(Map<String, dynamic>.from(row)),
              )
              .toList(),
        );
      }

      final teacherSubjectRows = await client
          .from('teacher_subjects')
          .select('''
            subject_id,
            subjects(name),
            teachers(
              id,
              user_id,
              employee_id,
              name,
              department_id,
              is_active
            )
          ''')
          .eq('is_active', true)
          .inFilter('subject_id', subjectIds)
          .order('subject_id');

      final teachers = <TeacherModel>[];
      final seen = <String>{};

      for (final row in teacherSubjectRows) {
        final teacher = _teacherFromTeacherSubjectRow(
          Map<String, dynamic>.from(row),
        );

        if (teacher == null || !teacher.isActive) {
          continue;
        }

        final key = '${teacher.id}:${teacher.subjectId ?? ''}';

        if (seen.add(key)) {
          teachers.add(teacher);
        }
      }

      teachers.sort((a, b) {
        final byName = a.name.compareTo(b.name);

        if (byName != 0) {
          return byName;
        }

        return (a.subjectName ?? '').compareTo(b.subjectName ?? '');
      });

      return Result.success(teachers);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load teachers for anonymous messaging.',
          code: 'anonymous_message_teachers_load_failed',
        ),
      );
    }
  }

  Future<Result<AnonymousMessageModel>> submitAnonymousMessage({
    required AnonymousMessageModel message,
  }) async {
    if (_shouldUseMockData) {
      final mockId = message.id.trim().isEmpty
          ? 'mock-anonymous-message-${DateTime.now().millisecondsSinceEpoch}'
          : message.id;

      return Result.success(message.copyWith(id: mockId));
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

      final resolvedStudentId = await _resolveStudentRecordId(
        message.studentId,
      );

      if (resolvedStudentId == null) {
        return const Result.failure(
          AppException(
            message: 'No student profile was found for this message.',
            code: 'anonymous_message_student_not_found',
          ),
        );
      }

      final resolvedTeacherId = await _resolveTeacherRecordId(
        message.teacherId,
      );

      if (resolvedTeacherId == null) {
        return const Result.failure(
          AppException(
            message: 'Please select a valid teacher before submitting.',
            code: 'anonymous_message_teacher_not_found',
          ),
        );
      }

      final payload = message
          .copyWith(studentId: resolvedStudentId, teacherId: resolvedTeacherId)
          .toJson();

      if ((payload['id'] as String?)?.trim().isEmpty ?? true) {
        payload.remove('id');
      }

      payload.remove('created_at');
      payload.remove('resolved_at');

      if ((payload['subject_id'] as String?)?.trim().isEmpty ?? true) {
        payload.remove('subject_id');
      }

      final row = await client
          .from('anonymous_messages')
          .insert(payload)
          .select(_adminMessageSelect)
          .single();

      return Result.success(
        AnonymousMessageModel.fromJson(Map<String, dynamic>.from(row)),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to submit anonymous message right now.',
          code: 'anonymous_message_submit_failed',
        ),
      );
    }
  }

  Future<Result<List<TeacherAnonymousMessageModel>>> getTeacherMessages({
    required String teacherId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockTeacherMessages());
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

      final rows = await client
          .from('anonymous_messages')
          .select(_teacherMessageSelect)
          .eq('teacher_id', resolvedTeacherId)
          .order('created_at', ascending: false);

      final messages = rows
          .map(
            (row) => TeacherAnonymousMessageModel.fromJson(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();

      return Result.success(messages);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load anonymous messages right now.',
          code: 'teacher_anonymous_messages_load_failed',
        ),
      );
    }
  }

  Future<Result<void>> markMessageResolved({required String messageId}) async {
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

      await client
          .from('anonymous_messages')
          .update({
            'status': 'resolved',
            'resolved_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', messageId);

      return const Result.success(null);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to mark message as resolved right now.',
          code: 'anonymous_message_resolve_failed',
        ),
      );
    }
  }

  Future<Result<void>> reportMessage({
    required String messageId,
    required String reportReason,
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

      final messageRow = await client
          .from('anonymous_messages')
          .select('teacher_id')
          .eq('id', messageId)
          .maybeSingle();

      final teacherId = messageRow?['teacher_id'] as String?;

      if (teacherId == null || teacherId.trim().isEmpty) {
        return const Result.failure(
          AppException(
            message: 'Unable to find the message teacher for reporting.',
            code: 'anonymous_message_teacher_missing',
          ),
        );
      }

      await client
          .from('anonymous_messages')
          .update({
            'status': 'reported',
            'is_reported': true,
            'report_reason': reportReason.trim(),
          })
          .eq('id', messageId);

      await client.from('message_reports').insert({
        'message_id': messageId,
        'reported_by_teacher_id': teacherId,
        'reason': reportReason.trim(),
        'status': 'pending',
      });

      return const Result.success(null);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to report anonymous message right now.',
          code: 'anonymous_message_report_failed',
        ),
      );
    }
  }

  Future<Result<List<AnonymousMessageModel>>> getAdminReportedMessages() async {
    if (_shouldUseMockData) {
      return Result.success(_mockAdminReportedMessages());
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

      final rows = await client
          .from('anonymous_messages')
          .select(_adminMessageSelect)
          .eq('is_reported', true)
          .order('created_at', ascending: false);

      final messages = rows
          .map(
            (row) =>
                AnonymousMessageModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();

      return Result.success(messages);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load reported anonymous messages right now.',
          code: 'admin_anonymous_reports_load_failed',
        ),
      );
    }
  }

  Future<Result<StudentModel>> revealSenderForAdminReview({
    required String messageId,
  }) async {
    if (_shouldUseMockData) {
      return Result.success(_mockStudent());
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
          .from('anonymous_messages')
          .select('students(*)')
          .eq('id', messageId)
          .maybeSingle();

      final student = _mapOrNull(row?['students']);

      if (student == null) {
        return const Result.failure(
          AppException(
            message: 'Unable to reveal sender for this message.',
            code: 'anonymous_message_sender_not_found',
          ),
        );
      }

      return Result.success(_studentFromJson(student));
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to reveal sender right now.',
          code: 'anonymous_message_sender_reveal_failed',
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

  TeacherModel? _teacherFromTeacherSubjectRow(Map<String, dynamic> row) {
    final teacher = _mapOrNull(row['teachers']);

    if (teacher == null) {
      return null;
    }

    final subject = _mapOrNull(row['subjects']);

    return TeacherModel.fromJson(teacher).copyWith(
      subjectId: row['subject_id'] as String?,
      subjectName: subject?['name'] as String?,
    );
  }

  StudentModel _studentFromJson(Map<String, dynamic> json) {
    return StudentModel.fromJson({
      ...json,
      'parent_email': json['parent_email'] as String? ?? '',
      'face_embedding_id': json['face_embedding_id'] as String?,
    });
  }

  List<TeacherModel> _mockTeachers() {
    return const [
      TeacherModel(
        id: 'mock-teacher-001',
        userId: 'mock-teacher-user-001',
        employeeId: 'T-001',
        name: 'Mr. Ahmad',
        departmentId: 'mock-department-bsit',
        isActive: true,
        subjectId: 'mock-subject-database-systems',
        subjectName: 'Database Systems',
        departmentName: 'Computer Science',
      ),
      TeacherModel(
        id: 'mock-teacher-002',
        userId: 'mock-teacher-user-002',
        employeeId: 'T-002',
        name: 'Ms. Sara',
        departmentId: 'mock-department-bsit',
        isActive: true,
        subjectId: 'mock-subject-web-engineering',
        subjectName: 'Web Engineering',
        departmentName: 'Computer Science',
      ),
    ];
  }

  List<TeacherAnonymousMessageModel> _mockTeacherMessages() {
    final now = DateTime.now();

    return [
      TeacherAnonymousMessageModel(
        id: 'mock-message-001',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-database-systems',
        message: 'Sir, Lecture 4 was difficult to understand.',
        status: 'new',
        isReported: false,
        createdAt: now,
        subjectName: 'Database Systems',
      ),
      TeacherAnonymousMessageModel(
        id: 'mock-message-002',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-database-systems',
        message: 'Please provide additional practice exercises.',
        status: 'resolved',
        isReported: false,
        createdAt: now.subtract(const Duration(days: 1)),
        resolvedAt: now.subtract(const Duration(hours: 6)),
        subjectName: 'Database Systems',
      ),
      TeacherAnonymousMessageModel(
        id: 'mock-message-003',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-database-systems',
        message: 'The classroom projector is not working properly.',
        status: 'reported',
        isReported: true,
        reportReason: 'Classroom issue review',
        createdAt: now.subtract(const Duration(hours: 2)),
        subjectName: 'Database Systems',
        reportStatus: 'pending',
      ),
    ];
  }

  List<AnonymousMessageModel> _mockAdminReportedMessages() {
    final now = DateTime.now();

    return [
      AnonymousMessageModel(
        id: 'mock-message-003',
        studentId: 'mock-student-001',
        teacherId: 'mock-teacher-001',
        subjectId: 'mock-subject-database-systems',
        message: 'The classroom projector is not working properly.',
        status: 'reported',
        isReported: true,
        reportReason: 'Classroom issue review',
        createdAt: now.subtract(const Duration(hours: 2)),
        subjectName: 'Database Systems',
        teacherName: 'Mr. Ahmad',
        studentName: 'Ali Khan',
        studentRollNo: 'BSIT-2022-001',
        departmentName: 'Computer Science',
        batchName: 'BSIT 2022',
        semesterName: '8th Semester',
        reportStatus: 'pending',
        reportedByTeacherName: 'Mr. Ahmad',
        reportCreatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  StudentModel _mockStudent() {
    return const StudentModel(
      id: 'mock-student-001',
      userId: 'mock-user-001',
      rollNo: 'BSIT-2022-001',
      name: 'Ali Khan',
      departmentId: 'mock-department-bsit',
      batchId: 'mock-batch-2022',
      semesterId: 'mock-semester-8',
      parentEmail: 'parent@example.com',
      isActive: true,
    );
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

  bool get _shouldUseMockData {
    return supabaseService == null || supabaseService!.isMockMode;
  }
}
