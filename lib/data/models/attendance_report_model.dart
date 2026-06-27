class AttendanceReportModel {
  const AttendanceReportModel({
    required this.sessionId,
    required this.teacherId,
    required this.subjectId,
    required this.departmentId,
    required this.batchId,
    required this.semesterId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    required this.records,
    this.teacherName,
    this.subjectName,
    this.departmentName,
    this.batchName,
    this.semesterName,
  });

  final String sessionId;
  final String teacherId;
  final String subjectId;
  final String departmentId;
  final String batchId;
  final String semesterId;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final String status;
  final DateTime createdAt;
  final List<AttendanceStudentRecordModel> records;
  final String? teacherName;
  final String? subjectName;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  int get totalStudents => records.length;

  int get presentCount {
    return records
        .where(
          (record) => record.attendanceStatus.trim().toLowerCase() == 'present',
        )
        .length;
  }

  int get absentCount {
    return records
        .where(
          (record) => record.attendanceStatus.trim().toLowerCase() == 'absent',
        )
        .length;
  }

  double get averagePercentage {
    if (records.isEmpty) {
      return 0;
    }

    final total = records.fold<double>(
      0,
      (sum, record) => sum + record.attendancePercentage,
    );

    return total / records.length;
  }

  factory AttendanceReportModel.fromSessionJson({
    required Map<String, dynamic> json,
    required List<AttendanceStudentRecordModel> records,
  }) {
    return AttendanceReportModel(
      sessionId: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      subjectId: json['subject_id'] as String,
      departmentId: json['department_id'] as String,
      batchId: json['batch_id'] as String,
      semesterId: json['semester_id'] as String,
      sessionDate: DateTime.parse(json['session_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      records: records,
      teacherName: _nestedName(json, 'teachers'),
      subjectName: _nestedName(json, 'subjects'),
      departmentName: _nestedName(json, 'departments'),
      batchName: _nestedName(json, 'batches'),
      semesterName: _nestedName(json, 'semesters'),
    );
  }

  AttendanceReportModel copyWith({
    String? sessionId,
    String? teacherId,
    String? subjectId,
    String? departmentId,
    String? batchId,
    String? semesterId,
    DateTime? sessionDate,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? createdAt,
    List<AttendanceStudentRecordModel>? records,
    String? teacherName,
    String? subjectName,
    String? departmentName,
    String? batchName,
    String? semesterName,
  }) {
    return AttendanceReportModel(
      sessionId: sessionId ?? this.sessionId,
      teacherId: teacherId ?? this.teacherId,
      subjectId: subjectId ?? this.subjectId,
      departmentId: departmentId ?? this.departmentId,
      batchId: batchId ?? this.batchId,
      semesterId: semesterId ?? this.semesterId,
      sessionDate: sessionDate ?? this.sessionDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      records: records ?? this.records,
      teacherName: teacherName ?? this.teacherName,
      subjectName: subjectName ?? this.subjectName,
      departmentName: departmentName ?? this.departmentName,
      batchName: batchName ?? this.batchName,
      semesterName: semesterName ?? this.semesterName,
    );
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  static String? _nestedName(Map<String, dynamic> source, String key) {
    final nested = _mapOrNull(source[key]);
    final name = nested?['name'] as String?;

    if (name == null || name.trim().isEmpty) {
      return null;
    }

    return name.trim();
  }
}

class AttendanceStudentRecordModel {
  const AttendanceStudentRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.attendancePercentage,
    required this.attendanceMethod,
    required this.attendanceStatus,
    required this.framesDetected,
    required this.totalFrames,
    required this.createdAt,
    this.studentName,
    this.rollNo,
  });

  final String id;
  final String sessionId;
  final String studentId;
  final double attendancePercentage;
  final String attendanceMethod;
  final String attendanceStatus;
  final int framesDetected;
  final int totalFrames;
  final DateTime createdAt;
  final String? studentName;
  final String? rollNo;

  factory AttendanceStudentRecordModel.fromJson(Map<String, dynamic> json) {
    final student = _mapOrNull(json['students']);

    return AttendanceStudentRecordModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
      attendanceMethod: json['attendance_method'] as String,
      attendanceStatus: json['attendance_status'] as String,
      framesDetected: (json['frames_detected'] as num?)?.toInt() ?? 0,
      totalFrames: (json['total_frames'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      studentName: _firstText(json['student_name'], student?['name']),
      rollNo: _firstText(json['roll_no'], student?['roll_no']),
    );
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  static String? _firstText(dynamic primary, dynamic fallback) {
    final primaryText = primary?.toString().trim();

    if (primaryText != null && primaryText.isNotEmpty) {
      return primaryText;
    }

    final fallbackText = fallback?.toString().trim();

    if (fallbackText != null && fallbackText.isNotEmpty) {
      return fallbackText;
    }

    return null;
  }
}
