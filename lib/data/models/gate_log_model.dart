class GateLogModel {
  const GateLogModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.time,
    required this.status,
    required this.gateLocation,
    required this.parentEmailSent,
    this.studentName,
    this.rollNo,
    this.parentEmail,
    this.departmentName,
    this.batchName,
    this.semesterName,
  });

  final String id;
  final String studentId;
  final DateTime date;
  final String time;
  final String status;
  final String gateLocation;
  final bool parentEmailSent;

  // Display-only joined fields from students and academic tables.
  final String? studentName;
  final String? rollNo;
  final String? parentEmail;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  factory GateLogModel.fromJson(Map<String, dynamic> json) {
    final student = _mapOrNull(json['students']);

    return GateLogModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      date: DateTime.parse((json['log_date'] ?? json['date']) as String),
      time: (json['log_time'] ?? json['time']) as String,
      status: json['status'] as String,
      gateLocation: json['gate_location'] as String,
      parentEmailSent: json['parent_email_sent'] as bool? ?? false,
      studentName: _firstText(json['student_name'], student?['name']),
      rollNo: _firstText(json['roll_no'], student?['roll_no']),
      parentEmail: _firstText(json['parent_email'], student?['parent_email']),
      departmentName: _nestedName(student, 'departments'),
      batchName: _nestedName(student, 'batches'),
      semesterName: _nestedName(student, 'semesters'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'log_date': _dateOnly(date),
      'log_time': time,
      'status': status,
      'gate_location': gateLocation,
      'parent_email_sent': parentEmailSent,
    };
  }

  GateLogModel copyWith({
    String? id,
    String? studentId,
    DateTime? date,
    String? time,
    String? status,
    String? gateLocation,
    bool? parentEmailSent,
    String? studentName,
    String? rollNo,
    String? parentEmail,
    String? departmentName,
    String? batchName,
    String? semesterName,
  }) {
    return GateLogModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      gateLocation: gateLocation ?? this.gateLocation,
      parentEmailSent: parentEmailSent ?? this.parentEmailSent,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      parentEmail: parentEmail ?? this.parentEmail,
      departmentName: departmentName ?? this.departmentName,
      batchName: batchName ?? this.batchName,
      semesterName: semesterName ?? this.semesterName,
    );
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '${value.year}-$month-$day';
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

  static String? _nestedName(Map<String, dynamic>? source, String key) {
    final nested = _mapOrNull(source?[key]);
    final name = nested?['name'] as String?;

    if (name == null || name.trim().isEmpty) {
      return null;
    }

    return name.trim();
  }
}
