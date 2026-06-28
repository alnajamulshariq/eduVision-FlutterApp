import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/admin_management_model.dart';
import 'package:eduvision_app/data/models/app_user_model.dart';
import 'package:eduvision_app/data/models/batch_model.dart';
import 'package:eduvision_app/data/models/department_model.dart';
import 'package:eduvision_app/data/models/semester_model.dart';
import 'package:eduvision_app/data/models/student_model.dart';
import 'package:eduvision_app/data/models/subject_model.dart';
import 'package:eduvision_app/data/models/teacher_model.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class AdminRepository {
  const AdminRepository({this.supabaseService});

  final SupabaseService? supabaseService;

  Future<Result<AdminUsersOverviewModel>> getAdminUsersOverview() async {
    if (_shouldUseMockData) {
      return Result.success(_mockAdminUsersOverview());
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

      final userRows = await client
          .from('app_users')
          .select()
          .order('created_at', ascending: false);

      final studentRows = await client.from('students').select('''
            id,
            user_id,
            roll_no,
            department_id,
            batch_id,
            semester_id,
            is_active,
            departments(name),
            batches(name),
            semesters(name)
          ''');

      final teacherRows = await client.from('teachers').select('''
            id,
            user_id,
            employee_id,
            department_id,
            is_active,
            departments(name)
          ''');

      final studentsByUserId = <String, Map<String, dynamic>>{};
      final teachersByUserId = <String, Map<String, dynamic>>{};

      for (final row in studentRows) {
        final student = Map<String, dynamic>.from(row);
        studentsByUserId[student['user_id'] as String] = student;
      }

      for (final row in teacherRows) {
        final teacher = Map<String, dynamic>.from(row);
        teachersByUserId[teacher['user_id'] as String] = teacher;
      }

      final users = userRows.map((row) {
        final user = Map<String, dynamic>.from(row);
        final userId = user['id'] as String;

        return AdminUserProfileModel.fromJson(
          user,
          studentJson: studentsByUserId[userId],
          teacherJson: teachersByUserId[userId],
        );
      }).toList();

      return Result.success(AdminUsersOverviewModel(users: users));
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load admin users right now.',
          code: 'admin_users_load_failed',
        ),
      );
    }
  }

  Future<Result<AcademicOverviewModel>> getAcademicOverview() async {
    if (_shouldUseMockData) {
      return Result.success(_mockAcademicOverview());
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

      final departmentRows = await client
          .from('departments')
          .select()
          .order('name', ascending: true);

      final batchRows = await client
          .from('batches')
          .select('id, name, year, department_id, departments(name)')
          .order('year', ascending: false);

      final semesterRows = await client
          .from('semesters')
          .select()
          .order('number', ascending: true);

      final subjectRows = await client
          .from('subjects')
          .select('''
            id,
            name,
            code,
            department_id,
            semester_id,
            departments(name),
            semesters(name)
          ''')
          .order('name', ascending: true);

      final teacherRows = await client
          .from('teachers')
          .select('''
            id,
            user_id,
            employee_id,
            name,
            department_id,
            is_active,
            departments(name)
          ''')
          .order('name', ascending: true);

      final studentRows = await client
          .from('students')
          .select('''
            id,
            user_id,
            roll_no,
            name,
            department_id,
            batch_id,
            semester_id,
            parent_email,
            is_active,
            departments(name),
            batches(name),
            semesters(name)
          ''')
          .order('name', ascending: true);

      final assignmentRows = await client
          .from('teacher_subjects')
          .select('''
            id,
            is_active,
            teachers(name),
            subjects(name),
            departments(name),
            batches(name),
            semesters(name)
          ''')
          .order('created_at', ascending: false);

      final enrollmentRows = await client
          .from('student_subjects')
          .select('''
            id,
            is_active,
            students(name),
            subjects(name),
            departments(name),
            batches(name),
            semesters(name)
          ''')
          .order('created_at', ascending: false);

      return Result.success(
        AcademicOverviewModel(
          departments: departmentRows
              .map(
                (row) =>
                    DepartmentModel.fromJson(Map<String, dynamic>.from(row)),
              )
              .toList(),
          batches: batchRows
              .map(
                (row) =>
                    BatchSummaryModel.fromJson(Map<String, dynamic>.from(row)),
              )
              .toList(),
          semesters: semesterRows
              .map(
                (row) => SemesterModel.fromJson(Map<String, dynamic>.from(row)),
              )
              .toList(),
          subjects: subjectRows
              .map(
                (row) => SubjectSummaryModel.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
          teachers: teacherRows
              .map(
                (row) => AdminTeacherProfileModel.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
          students: studentRows
              .map(
                (row) => AdminStudentProfileModel.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
          teacherAssignments: assignmentRows
              .map(
                (row) => TeacherAssignmentSummaryModel.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
          studentEnrollments: enrollmentRows
              .map(
                (row) => StudentEnrollmentSummaryModel.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
        ),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Unable to load academic management data right now.',
          code: 'admin_academics_load_failed',
        ),
      );
    }
  }

  Future<Result<void>> createStudentAccount({
    required AppUserModel user,
    required StudentModel student,
  }) async {
    return _secureBackendRequired('Student account creation');
  }

  Future<Result<void>> createTeacherAccount({
    required AppUserModel user,
    required TeacherModel teacher,
  }) async {
    return _secureBackendRequired('Teacher account creation');
  }

  Future<Result<void>> createAdminAccount({required AppUserModel user}) async {
    return _secureBackendRequired('Admin account creation');
  }

  Future<Result<AdminWriteResultModel>> createUserAccount({
    required AdminCreateUserRequestModel request,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock admin user creation completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-create-user',
      body: request.toJson(),
    );
  }

  Future<Result<AdminWriteResultModel>> resetUserPassword({
    required AdminResetPasswordRequestModel request,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock password reset completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-reset-password',
      body: request.toJson(),
    );
  }

  Future<Result<AdminWriteResultModel>> createDepartmentSecure({
    required String name,
    required String code,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock department creation completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-academic-write',
      body: AdminAcademicWriteRequestModel(
        operation: 'create_department',
        payload: {'name': name.trim(), 'code': code.trim().toUpperCase()},
      ).toJson(),
    );
  }

  Future<Result<AdminWriteResultModel>> createSubjectSecure({
    required String name,
    required String code,
    required String departmentId,
    required String semesterId,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock subject creation completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-academic-write',
      body: AdminAcademicWriteRequestModel(
        operation: 'create_subject',
        payload: {
          'name': name.trim(),
          'code': code.trim().toUpperCase(),
          'departmentId': departmentId.trim(),
          'semesterId': semesterId.trim(),
        },
      ).toJson(),
    );
  }

  Future<Result<AdminWriteResultModel>> createBatchSecure({
    required String name,
    required int year,
    required String departmentId,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock batch creation completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-academic-write',
      body: AdminAcademicWriteRequestModel(
        operation: 'create_batch',
        payload: {
          'name': name.trim(),
          'year': year,
          'departmentId': departmentId.trim(),
        },
      ).toJson(),
    );
  }

  Future<Result<AdminWriteResultModel>> createSemesterSecure({
    required String name,
    required int number,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock semester creation completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-academic-write',
      body: AdminAcademicWriteRequestModel(
        operation: 'create_semester',
        payload: {'name': name.trim(), 'number': number},
      ).toJson(),
    );
  }

  Future<Result<AdminWriteResultModel>> assignTeacherSecure({
    required String teacherId,
    required String subjectId,
    required String departmentId,
    required String batchId,
    required String semesterId,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock teacher assignment completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-academic-write',
      body: AdminAcademicWriteRequestModel(
        operation: 'assign_teacher',
        payload: {
          'teacherId': teacherId.trim(),
          'subjectId': subjectId.trim(),
          'departmentId': departmentId.trim(),
          'batchId': batchId.trim(),
          'semesterId': semesterId.trim(),
        },
      ).toJson(),
    );
  }

  Future<Result<AdminWriteResultModel>> enrollStudentSecure({
    required String studentId,
    required String subjectId,
    required String departmentId,
    required String batchId,
    required String semesterId,
  }) async {
    if (_shouldUseMockData) {
      return const Result.success(
        AdminWriteResultModel(
          success: true,
          message: 'Mock student enrollment completed.',
        ),
      );
    }

    return _invokeAdminFunction(
      functionName: 'admin-academic-write',
      body: AdminAcademicWriteRequestModel(
        operation: 'enroll_student',
        payload: {
          'studentId': studentId.trim(),
          'subjectId': subjectId.trim(),
          'departmentId': departmentId.trim(),
          'batchId': batchId.trim(),
          'semesterId': semesterId.trim(),
        },
      ).toJson(),
    );
  }

  Future<Result<DepartmentModel>> createDepartment({
    required DepartmentModel department,
  }) async {
    return _academicWritesDisabled<DepartmentModel>('Department creation');
  }

  Future<Result<BatchModel>> createBatch({required BatchModel batch}) async {
    return _academicWritesDisabled<BatchModel>('Batch creation');
  }

  Future<Result<SemesterModel>> createSemester({
    required SemesterModel semester,
  }) async {
    return _academicWritesDisabled<SemesterModel>('Semester creation');
  }

  Future<Result<SubjectModel>> createSubject({
    required SubjectModel subject,
  }) async {
    return _academicWritesDisabled<SubjectModel>('Subject creation');
  }

  Future<Result<void>> assignTeacherToSubject({
    required String teacherId,
    required String subjectId,
  }) async {
    return _academicWritesDisabled<void>('Teacher subject assignment');
  }

  Future<Result<void>> assignStudentToSubject({
    required String studentId,
    required String subjectId,
  }) async {
    return _academicWritesDisabled<void>('Student subject assignment');
  }

  Result<T> _secureBackendRequired<T>(String feature) {
    return Result.failure(
      AppException(
        message:
            '$feature requires a secure backend function or Supabase Admin API. '
            'It is not safe to create Auth users from the Flutter client.',
        code: 'secure_backend_required',
      ),
    );
  }

  Future<Result<AdminWriteResultModel>> _invokeAdminFunction({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
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

      final response = await client.functions.invoke(functionName, body: body);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return Result.success(AdminWriteResultModel.fromJson(data));
      }

      if (data is Map) {
        return Result.success(
          AdminWriteResultModel.fromJson(Map<String, dynamic>.from(data)),
        );
      }

      return const Result.failure(
        AppException(
          message: 'Admin action returned an invalid response.',
          code: 'admin_function_invalid_response',
        ),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message:
              'Secure admin action failed. Check Edge Function deployment and secrets.',
          code: 'admin_function_failed',
        ),
      );
    }
  }

  Result<T> _academicWritesDisabled<T>(String feature) {
    return Result.failure(
      AppException(
        message:
            '$feature is read-only in the Flutter client right now. Academic '
            'writes require admin insert/update policies or a secure backend '
            'function.',
        code: 'admin_academic_write_disabled',
      ),
    );
  }

  AcademicOverviewModel _mockAcademicOverview() {
    const departments = [
      DepartmentModel(
        id: 'mock-department-bsit',
        name: 'Computer Science',
        code: 'CS',
      ),
      DepartmentModel(
        id: 'mock-department-bba',
        name: 'Business Administration',
        code: 'BBA',
      ),
    ];

    const semesters = [
      SemesterModel(id: 'mock-semester-6', name: '6th Semester', number: 6),
      SemesterModel(id: 'mock-semester-8', name: '8th Semester', number: 8),
    ];

    return const AcademicOverviewModel(
      departments: departments,
      batches: [
        BatchSummaryModel(
          id: 'mock-batch-2022',
          name: 'BSIT 2022',
          year: 2022,
          departmentId: 'mock-department-bsit',
          departmentName: 'Computer Science',
        ),
        BatchSummaryModel(
          id: 'mock-batch-2023',
          name: 'BSSE 2023',
          year: 2023,
          departmentId: 'mock-department-bsit',
          departmentName: 'Computer Science',
        ),
      ],
      semesters: semesters,
      subjects: [
        SubjectSummaryModel(
          id: 'mock-subject-database',
          name: 'Database Systems',
          code: 'CS-408',
          departmentId: 'mock-department-bsit',
          semesterId: 'mock-semester-8',
          departmentName: 'Computer Science',
          semesterName: '8th Semester',
        ),
        SubjectSummaryModel(
          id: 'mock-subject-web',
          name: 'Web Engineering',
          code: 'CS-406',
          departmentId: 'mock-department-bsit',
          semesterId: 'mock-semester-6',
          departmentName: 'Computer Science',
          semesterName: '6th Semester',
        ),
      ],
      teachers: [
        AdminTeacherProfileModel(
          id: 'mock-teacher-001',
          userId: 'mock-teacher-user-001',
          employeeId: 'TCH-001',
          name: 'Mr. Ahmad',
          departmentId: 'mock-department-bsit',
          isActive: true,
          departmentName: 'Computer Science',
        ),
      ],
      students: [
        AdminStudentProfileModel(
          id: 'mock-student-001',
          userId: 'mock-student-user-001',
          rollNo: 'BSIT-2022-001',
          name: 'Ali Khan',
          departmentId: 'mock-department-bsit',
          batchId: 'mock-batch-2022',
          semesterId: 'mock-semester-8',
          isActive: true,
          parentEmail: 'parent@example.com',
          departmentName: 'Computer Science',
          batchName: 'BSIT 2022',
          semesterName: '8th Semester',
        ),
      ],
      teacherAssignments: [
        TeacherAssignmentSummaryModel(
          id: 'mock-assignment-001',
          isActive: true,
          teacherName: 'Mr. Ahmad',
          subjectName: 'Database Systems',
          departmentName: 'Computer Science',
          batchName: 'BSIT 2022',
          semesterName: '8th Semester',
        ),
      ],
      studentEnrollments: [
        StudentEnrollmentSummaryModel(
          id: 'mock-enrollment-001',
          isActive: true,
          studentName: 'Ali Khan',
          subjectName: 'Database Systems',
          departmentName: 'Computer Science',
          batchName: 'BSIT 2022',
          semesterName: '8th Semester',
        ),
      ],
    );
  }

  AdminUsersOverviewModel _mockAdminUsersOverview() {
    final createdAt = DateTime.utc(2026, 6, 24);

    return AdminUsersOverviewModel(
      users: [
        AdminUserProfileModel(
          id: 'mock-student-user-001',
          name: 'Ali Khan',
          universityEmail: 'student@eduvision.edu',
          role: 'student',
          isFirstLogin: false,
          passwordChangedOnce: true,
          isActive: true,
          createdAt: createdAt,
          linkedRecordId: 'mock-student-001',
          idLabel: 'Roll No',
          idValue: 'BSIT-2022-001',
          departmentName: 'Computer Science',
          batchName: 'BSIT 2022',
          semesterName: '8th Semester',
        ),
        AdminUserProfileModel(
          id: 'mock-teacher-user-001',
          name: 'Mr. Ahmad',
          universityEmail: 'teacher@eduvision.edu',
          role: 'teacher',
          isFirstLogin: false,
          passwordChangedOnce: true,
          isActive: true,
          createdAt: createdAt,
          linkedRecordId: 'mock-teacher-001',
          idLabel: 'Employee ID',
          idValue: 'TCH-001',
          departmentName: 'Computer Science',
        ),
        AdminUserProfileModel(
          id: 'mock-admin-user-001',
          name: 'Admin User',
          universityEmail: 'admin@eduvision.edu',
          role: 'admin',
          isFirstLogin: false,
          passwordChangedOnce: true,
          isActive: true,
          createdAt: createdAt,
          idLabel: 'Account ID',
          idValue: 'mock-admin',
          departmentName: 'Administration',
        ),
      ],
    );
  }

  bool get _shouldUseMockData {
    return supabaseService == null || supabaseService!.isMockMode;
  }
}
