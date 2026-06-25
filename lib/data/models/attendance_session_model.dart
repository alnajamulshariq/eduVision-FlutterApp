class AttendanceSessionModel {
  const AttendanceSessionModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.departmentId,
    required this.batchId,
    required this.semesterId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  final String id;
  final String teacherId;
  final String subjectId;
  final String departmentId;
  final String batchId;
  final String semesterId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['session_date'] ?? json['date'];

    return AttendanceSessionModel(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      subjectId: json['subject_id'] as String,
      departmentId: json['department_id'] as String,
      batchId: json['batch_id'] as String,
      semesterId: json['semester_id'] as String,
      date: DateTime.parse(rawDate as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.trim().isNotEmpty) 'id': id,
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'department_id': departmentId,
      'batch_id': batchId,
      'semester_id': semesterId,
      'session_date': _formatDate(date),
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
    };
  }

  AttendanceSessionModel copyWith({
    String? id,
    String? teacherId,
    String? subjectId,
    String? departmentId,
    String? batchId,
    String? semesterId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
  }) {
    return AttendanceSessionModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      subjectId: subjectId ?? this.subjectId,
      departmentId: departmentId ?? this.departmentId,
      batchId: batchId ?? this.batchId,
      semesterId: semesterId ?? this.semesterId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
