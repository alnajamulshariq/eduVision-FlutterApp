class AnonymousMessageModel {
  const AnonymousMessageModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.subjectId,
    required this.message,
    required this.status,
    required this.isReported,
    this.reportReason,
    required this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String studentId;
  final String teacherId;
  final String subjectId;
  final String message;
  final String status;
  final bool isReported;
  final String? reportReason;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  factory AnonymousMessageModel.fromJson(Map<String, dynamic> json) {
    return AnonymousMessageModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      teacherId: json['teacher_id'] as String,
      subjectId: json['subject_id'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      isReported: json['is_reported'] as bool,
      reportReason: json['report_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'message': message,
      'status': status,
      'is_reported': isReported,
      'report_reason': reportReason,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  AnonymousMessageModel copyWith({
    String? id,
    String? studentId,
    String? teacherId,
    String? subjectId,
    String? message,
    String? status,
    bool? isReported,
    String? reportReason,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return AnonymousMessageModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      subjectId: subjectId ?? this.subjectId,
      message: message ?? this.message,
      status: status ?? this.status,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
