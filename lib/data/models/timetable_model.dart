class TimetableModel {
  const TimetableModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.departmentId,
    required this.batchId,
    required this.semesterId,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String teacherId;
  final String subjectId;
  final String departmentId;
  final String batchId;
  final String semesterId;
  final String day;
  final String startTime;
  final String endTime;

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      subjectId: json['subject_id'] as String,
      departmentId: json['department_id'] as String,
      batchId: json['batch_id'] as String,
      semesterId: json['semester_id'] as String,
      day: json['day'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'department_id': departmentId,
      'batch_id': batchId,
      'semester_id': semesterId,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  TimetableModel copyWith({
    String? id,
    String? teacherId,
    String? subjectId,
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? day,
    String? startTime,
    String? endTime,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      subjectId: subjectId ?? this.subjectId,
      departmentId: departmentId ?? this.departmentId,
      batchId: batchId ?? this.batchId,
      semesterId: semesterId ?? this.semesterId,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
