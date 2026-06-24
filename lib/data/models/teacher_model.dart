class TeacherModel {
  const TeacherModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.name,
    required this.departmentId,
    required this.isActive,
  });

  final String id;
  final String userId;
  final String employeeId;
  final String name;
  final String departmentId;
  final bool isActive;

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      departmentId: json['department_id'] as String,
      isActive: json['is_active'] as bool,
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
    };
  }

  TeacherModel copyWith({
    String? id,
    String? userId,
    String? employeeId,
    String? name,
    String? departmentId,
    bool? isActive,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      isActive: isActive ?? this.isActive,
    );
  }
}
