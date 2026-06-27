class StudentQrIdentityModel {
  const StudentQrIdentityModel({
    required this.studentUserId,
    required this.studentId,
    required this.name,
    required this.rollNo,
    this.departmentName,
    this.batchName,
    this.semesterName,
  });

  final String studentUserId;
  final String studentId;
  final String name;
  final String rollNo;
  final String? departmentName;
  final String? batchName;
  final String? semesterName;

  factory StudentQrIdentityModel.fromJson(Map<String, dynamic> json) {
    return StudentQrIdentityModel(
      studentUserId: json['user_id'] as String,
      studentId: json['id'] as String,
      name: json['name'] as String,
      rollNo: json['roll_no'] as String,
      departmentName: _nestedName(json, 'departments'),
      batchName: _nestedName(json, 'batches'),
      semesterName: _nestedName(json, 'semesters'),
    );
  }
}

class QrAttendanceMarkResult {
  const QrAttendanceMarkResult({
    required this.studentName,
    required this.rollNo,
    required this.method,
    required this.status,
    required this.message,
    required this.markedAt,
    required this.alreadyMarked,
  });

  final String studentName;
  final String rollNo;
  final String method;
  final String status;
  final String message;
  final DateTime markedAt;
  final bool alreadyMarked;
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

String? _nestedName(Map<String, dynamic> source, String key) {
  final nested = _mapOrNull(source[key]);
  final name = nested?['name'] as String?;

  if (name == null || name.trim().isEmpty) {
    return null;
  }

  return name.trim();
}
