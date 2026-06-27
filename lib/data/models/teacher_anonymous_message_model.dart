class TeacherAnonymousMessageModel {
  const TeacherAnonymousMessageModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.message,
    required this.status,
    required this.isReported,
    this.reportReason,
    required this.createdAt,
    this.resolvedAt,
    this.subjectName,
    this.reportStatus,
    this.reportCreatedAt,
  });

  final String id;
  final String teacherId;
  final String? subjectId;
  final String message;
  final String status;
  final bool isReported;
  final String? reportReason;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? subjectName;
  final String? reportStatus;
  final DateTime? reportCreatedAt;

  factory TeacherAnonymousMessageModel.fromJson(Map<String, dynamic> json) {
    final report = _firstMapFromRelation(json['message_reports']);

    return TeacherAnonymousMessageModel(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      subjectId: json['subject_id'] as String?,
      message: json['message'] as String,
      status: json['status'] as String,
      isReported: json['is_reported'] as bool? ?? false,
      reportReason: _firstText(json['report_reason'], report?['reason']),
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      subjectName: _nestedName(json, 'subjects'),
      reportStatus: report?['status'] as String?,
      reportCreatedAt: _parseOptionalDateTime(report?['created_at']),
    );
  }

  TeacherAnonymousMessageModel copyWith({
    String? id,
    String? teacherId,
    String? subjectId,
    String? message,
    String? status,
    bool? isReported,
    String? reportReason,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? subjectName,
    String? reportStatus,
    DateTime? reportCreatedAt,
  }) {
    return TeacherAnonymousMessageModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      subjectId: subjectId ?? this.subjectId,
      message: message ?? this.message,
      status: status ?? this.status,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      subjectName: subjectName ?? this.subjectName,
      reportStatus: reportStatus ?? this.reportStatus,
      reportCreatedAt: reportCreatedAt ?? this.reportCreatedAt,
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

  static Map<String, dynamic>? _firstMapFromRelation(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return _mapOrNull(value.first);
    }

    return _mapOrNull(value);
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

  static String? _nestedName(Map<String, dynamic> source, String key) {
    final nested = _mapOrNull(source[key]);
    final name = nested?['name'] as String?;

    if (name == null || name.trim().isEmpty) {
      return null;
    }

    return name.trim();
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
