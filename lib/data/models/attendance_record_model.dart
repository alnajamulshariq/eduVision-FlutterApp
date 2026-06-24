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

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
      attendanceMethod: json['attendance_method'] as String,
      attendanceStatus: json['attendance_status'] as String,
      framesDetected: json['frames_detected'] as int,
      totalFrames: json['total_frames'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
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
    );
  }
}
