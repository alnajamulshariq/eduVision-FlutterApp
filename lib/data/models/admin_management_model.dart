import 'package:eduvision_app/data/models/department_model.dart';
import 'package:eduvision_app/data/models/semester_model.dart';

class AdminUsersOverviewModel {
  const AdminUsersOverviewModel({required this.users});

  final List<AdminUserProfileModel> users;

  int get studentCount => _roleCount('student');
  int get teacherCount => _roleCount('teacher');
  int get adminCount => _roleCount('admin');
  int get activeCount => users.where((user) => user.isActive).length;

  int _roleCount(String role) {
    return users.where((user) => user.normalizedRole == role).length;
  }
}

class AdminUserProfileModel {
  const AdminUserProfileModel({
    required this.id,
    required this.name,
    required this.universityEmail,
    required this.role,
    required this.isFirstLogin,
    required this.passwordChangedOnce,
    required this.isActive,
    required this.createdAt,
    this.linkedRecordId,
    this.idLabel,
    this.idValue,
    this.departmentName,
    this.batchName,
    this.semesterName,
  });

  final String id;
  final String name;
  final String universityEmail;
  final String role;
  final bool isFirstLogin;
  final bool passwordChangedOnce;
  final bool isActive;
  final DateTime createdAt;
  final String? linkedRecordId;
  final String? idLabel;
  final String? idValue;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  String get normalizedRole => role.trim().toLowerCase();
  String get roleLabel => _titleCase(normalizedRole);
  String get statusLabel => isActive ? 'Active' : 'Inactive';

  factory AdminUserProfileModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? studentJson,
    Map<String, dynamic>? teacherJson,
  }) {
    final role = (json['role'] as String).trim().toLowerCase();
    final linkedJson = role == 'student' ? studentJson : teacherJson;

    return AdminUserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      universityEmail: json['university_email'] as String,
      role: role,
      isFirstLogin: json['is_first_login'] as bool? ?? false,
      passwordChangedOnce: json['password_changed_once'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      linkedRecordId: linkedJson?['id'] as String?,
      idLabel: switch (role) {
        'student' => 'Roll No',
        'teacher' => 'Employee ID',
        _ => 'Account ID',
      },
      idValue: switch (role) {
        'student' => studentJson?['roll_no'] as String?,
        'teacher' => teacherJson?['employee_id'] as String?,
        _ => (json['id'] as String).substring(0, 8),
      },
      departmentName: _nestedName(linkedJson, 'departments'),
      batchName: _nestedName(linkedJson, 'batches'),
      semesterName: _nestedName(linkedJson, 'semesters'),
    );
  }
}

class AcademicOverviewModel {
  const AcademicOverviewModel({
    required this.departments,
    required this.batches,
    required this.semesters,
    required this.subjects,
    required this.teachers,
    required this.students,
    required this.teacherAssignments,
    required this.studentEnrollments,
  });

  final List<DepartmentModel> departments;
  final List<BatchSummaryModel> batches;
  final List<SemesterModel> semesters;
  final List<SubjectSummaryModel> subjects;
  final List<AdminTeacherProfileModel> teachers;
  final List<AdminStudentProfileModel> students;
  final List<TeacherAssignmentSummaryModel> teacherAssignments;
  final List<StudentEnrollmentSummaryModel> studentEnrollments;
}

class BatchSummaryModel {
  const BatchSummaryModel({
    required this.id,
    required this.name,
    required this.year,
    required this.departmentId,
    this.departmentName,
  });

  final String id;
  final String name;
  final int year;
  final String departmentId;
  final String? departmentName;

  factory BatchSummaryModel.fromJson(Map<String, dynamic> json) {
    return BatchSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      year: json['year'] as int,
      departmentId: json['department_id'] as String,
      departmentName: _nestedName(json, 'departments'),
    );
  }
}

class SubjectSummaryModel {
  const SubjectSummaryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.departmentId,
    required this.semesterId,
    this.departmentName,
    this.semesterName,
  });

  final String id;
  final String name;
  final String code;
  final String departmentId;
  final String semesterId;
  final String? departmentName;
  final String? semesterName;

  factory SubjectSummaryModel.fromJson(Map<String, dynamic> json) {
    return SubjectSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      departmentId: json['department_id'] as String,
      semesterId: json['semester_id'] as String,
      departmentName: _nestedName(json, 'departments'),
      semesterName: _nestedName(json, 'semesters'),
    );
  }
}

class AdminTeacherProfileModel {
  const AdminTeacherProfileModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.name,
    required this.departmentId,
    required this.isActive,
    this.departmentName,
  });

  final String id;
  final String userId;
  final String employeeId;
  final String name;
  final String departmentId;
  final bool isActive;
  final String? departmentName;

  factory AdminTeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminTeacherProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      departmentId: json['department_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      departmentName: _nestedName(json, 'departments'),
    );
  }
}

class AdminStudentProfileModel {
  const AdminStudentProfileModel({
    required this.id,
    required this.userId,
    required this.rollNo,
    required this.name,
    required this.departmentId,
    required this.batchId,
    required this.semesterId,
    required this.isActive,
    this.parentEmail,
    this.departmentName,
    this.batchName,
    this.semesterName,
  });

  final String id;
  final String userId;
  final String rollNo;
  final String name;
  final String departmentId;
  final String batchId;
  final String semesterId;
  final bool isActive;
  final String? parentEmail;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  factory AdminStudentProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminStudentProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rollNo: json['roll_no'] as String,
      name: json['name'] as String,
      departmentId: json['department_id'] as String,
      batchId: json['batch_id'] as String,
      semesterId: json['semester_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      parentEmail: json['parent_email'] as String?,
      departmentName: _nestedName(json, 'departments'),
      batchName: _nestedName(json, 'batches'),
      semesterName: _nestedName(json, 'semesters'),
    );
  }
}

class TeacherAssignmentSummaryModel {
  const TeacherAssignmentSummaryModel({
    required this.id,
    required this.isActive,
    this.teacherName,
    this.subjectName,
    this.departmentName,
    this.batchName,
    this.semesterName,
  });

  final String id;
  final bool isActive;
  final String? teacherName;
  final String? subjectName;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  factory TeacherAssignmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return TeacherAssignmentSummaryModel(
      id: json['id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      teacherName: _nestedName(json, 'teachers'),
      subjectName: _nestedName(json, 'subjects'),
      departmentName: _nestedName(json, 'departments'),
      batchName: _nestedName(json, 'batches'),
      semesterName: _nestedName(json, 'semesters'),
    );
  }
}

class StudentEnrollmentSummaryModel {
  const StudentEnrollmentSummaryModel({
    required this.id,
    required this.isActive,
    this.studentName,
    this.subjectName,
    this.departmentName,
    this.batchName,
    this.semesterName,
  });

  final String id;
  final bool isActive;
  final String? studentName;
  final String? subjectName;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  factory StudentEnrollmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return StudentEnrollmentSummaryModel(
      id: json['id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      studentName: _nestedName(json, 'students'),
      subjectName: _nestedName(json, 'subjects'),
      departmentName: _nestedName(json, 'departments'),
      batchName: _nestedName(json, 'batches'),
      semesterName: _nestedName(json, 'semesters'),
    );
  }
}

class AdminWriteResultModel {
  const AdminWriteResultModel({
    required this.success,
    required this.message,
    this.createdUserId,
    this.recordId,
  });

  final bool success;
  final String message;
  final String? createdUserId;
  final String? recordId;

  factory AdminWriteResultModel.fromJson(Map<String, dynamic> json) {
    return AdminWriteResultModel(
      success: json['success'] == true,
      message: _textOrFallback(json['message'], 'Admin write completed.'),
      createdUserId: _textOrNull(json['createdUserId']),
      recordId: _textOrNull(json['recordId']),
    );
  }
}

class AdminCreateUserRequestModel {
  const AdminCreateUserRequestModel({
    required this.name,
    required this.universityEmail,
    required this.role,
    required this.temporaryPassword,
    this.rollNo,
    this.employeeId,
    this.departmentId,
    this.batchId,
    this.semesterId,
    this.parentEmail,
  });

  final String name;
  final String universityEmail;
  final String role;
  final String temporaryPassword;
  final String? rollNo;
  final String? employeeId;
  final String? departmentId;
  final String? batchId;
  final String? semesterId;
  final String? parentEmail;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'universityEmail': universityEmail.trim().toLowerCase(),
      'role': role.trim().toLowerCase(),
      'temporaryPassword': temporaryPassword,
      if (_hasText(rollNo)) 'rollNo': rollNo!.trim(),
      if (_hasText(employeeId)) 'employeeId': employeeId!.trim(),
      if (_hasText(departmentId)) 'departmentId': departmentId!.trim(),
      if (_hasText(batchId)) 'batchId': batchId!.trim(),
      if (_hasText(semesterId)) 'semesterId': semesterId!.trim(),
      if (_hasText(parentEmail)) 'parentEmail': parentEmail!.trim(),
    };
  }
}

class AdminResetPasswordRequestModel {
  const AdminResetPasswordRequestModel({
    required this.userId,
    required this.temporaryPassword,
  });

  final String userId;
  final String temporaryPassword;

  Map<String, dynamic> toJson() {
    return {'userId': userId.trim(), 'temporaryPassword': temporaryPassword};
  }
}

class AdminAcademicWriteRequestModel {
  const AdminAcademicWriteRequestModel({
    required this.operation,
    required this.payload,
  });

  final String operation;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() {
    return {'operation': operation, 'payload': payload};
  }
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

String? _nestedName(Map<String, dynamic>? source, String key) {
  final nested = _mapOrNull(source?[key]);
  final name = nested?['name'] as String?;

  if (name == null || name.trim().isEmpty) {
    return null;
  }

  return name.trim();
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _textOrFallback(dynamic value, String fallback) {
  final text = _textOrNull(value);
  return text ?? fallback;
}

String? _textOrNull(dynamic value) {
  final text = value?.toString().trim();

  if (text == null || text.isEmpty) {
    return null;
  }

  return text;
}

String _titleCase(String value) {
  final words = value
      .trim()
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return 'Unknown';
  }

  return words
      .map(
        (word) => word.length == 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
