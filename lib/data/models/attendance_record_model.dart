class AttendanceRecordModel {
  const AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.attendancePercentage,
    required this.attendanceMethod,
    required this.attendanceStatus,
    required this.framesDetected,
    required this.totalFrames,
    required this.createdAt,
    this.sessionDate,
    this.startTime,
    this.endTime,
    this.subjectName,
    this.teacherName,
    this.departmentName,
    this.batchName,
    this.semesterName,
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

  // Display-only joined fields from attendance_sessions and academic tables.
  final DateTime? sessionDate;
  final String? startTime;
  final String? endTime;
  final String? subjectName;
  final String? teacherName;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final session = _mapOrNull(json['attendance_sessions']);

    return AttendanceRecordModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
      attendanceMethod: json['attendance_method'] as String,
      attendanceStatus: json['attendance_status'] as String,
      framesDetected: (json['frames_detected'] as num?)?.toInt() ?? 0,
      totalFrames: (json['total_frames'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      sessionDate: _parseOptionalDate(session?['session_date']),
      startTime: session?['start_time'] as String?,
      endTime: session?['end_time'] as String?,
      subjectName: _nestedName(session, 'subjects'),
      teacherName: _nestedName(session, 'teachers'),
      departmentName: _nestedName(session, 'departments'),
      batchName: _nestedName(session, 'batches'),
      semesterName: _nestedName(session, 'semesters'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'attendance_percentage': attendancePercentage,
      'attendance_method': attendanceMethod,
      'attendance_status': attendanceStatus,
      'frames_detected': framesDetected,
      'total_frames': totalFrames,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AttendanceRecordModel copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    double? attendancePercentage,
    String? attendanceMethod,
    String? attendanceStatus,
    int? framesDetected,
    int? totalFrames,
    DateTime? createdAt,
    DateTime? sessionDate,
    String? startTime,
    String? endTime,
    String? subjectName,
    String? teacherName,
    String? departmentName,
    String? batchName,
    String? semesterName,
  }) {
    return AttendanceRecordModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      attendanceMethod: attendanceMethod ?? this.attendanceMethod,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      framesDetected: framesDetected ?? this.framesDetected,
      totalFrames: totalFrames ?? this.totalFrames,
      createdAt: createdAt ?? this.createdAt,
      sessionDate: sessionDate ?? this.sessionDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
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

  static DateTime? _parseOptionalDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final rawValue = value.toString().trim();

    if (rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }

  static String? _nestedName(Map<String, dynamic>? source, String key) {
    final nested = _mapOrNull(source?[key]);
    final name = nested?['name'] as String?;

    if (name == null || name.trim().isEmpty) {
      return null;
    }

    return name.trim();
  }
}
