class GateLogModel {
  const GateLogModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.time,
    required this.status,
    required this.gateLocation,
    required this.parentEmailSent,
  });

  final String id;
  final String studentId;
  final DateTime date;
  final String time;
  final String status;
  final String gateLocation;
  final bool parentEmailSent;

  factory GateLogModel.fromJson(Map<String, dynamic> json) {
    return GateLogModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: json['status'] as String,
      gateLocation: json['gate_location'] as String,
      parentEmailSent: json['parent_email_sent'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date.toIso8601String(),
      'time': time,
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
  }) {
    return GateLogModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      gateLocation: gateLocation ?? this.gateLocation,
      parentEmailSent: parentEmailSent ?? this.parentEmailSent,
    );
  }
}
