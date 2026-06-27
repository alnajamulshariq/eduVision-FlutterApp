class TeacherModel {
  const TeacherModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.name,
    required this.departmentId,
    required this.isActive,
    this.subjectId,
    this.subjectName,
    this.departmentName,
  });

  final String id;
  final String userId;
  final String employeeId;
  final String name;
  final String departmentId;
  final bool isActive;
  final String? subjectId;
  final String? subjectName;
  final String? departmentName;

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      departmentId: json['department_id'] as String,
      isActive: json['is_active'] as bool,
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      departmentName: _nestedName(json, 'departments'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_id': employeeId,
      'name': name,
      'department_id': departmentId,
      'is_active': isActive,
      'subject_id': subjectId,
      'subject_name': subjectName,
    };
  }

  TeacherModel copyWith({
    String? id,
    String? userId,
    String? employeeId,
    String? name,
    String? departmentId,
    bool? isActive,
    String? subjectId,
    String? subjectName,
    String? departmentName,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      isActive: isActive ?? this.isActive,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      departmentName: departmentName ?? this.departmentName,
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

  static String? _nestedName(Map<String, dynamic> source, String key) {
    final nested = _mapOrNull(source[key]);
    final name = nested?['name'] as String?;

    if (name == null || name.trim().isEmpty) {
      return null;
    }

    return name.trim();
  }
}
