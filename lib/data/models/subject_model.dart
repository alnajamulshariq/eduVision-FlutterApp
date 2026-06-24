class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.departmentId,
    required this.semesterId,
  });

  final String id;
  final String name;
  final String code;
  final String departmentId;
  final String semesterId;

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      departmentId: json['department_id'] as String,
      semesterId: json['semester_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'department_id': departmentId,
      'semester_id': semesterId,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? code,
    String? departmentId,
    String? semesterId,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      semesterId: semesterId ?? this.semesterId,
    );
  }
}
