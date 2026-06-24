class BatchModel {
  const BatchModel({
    required this.id,
    required this.name,
    required this.year,
    required this.departmentId,
  });

  final String id;
  final String name;
  final int year;
  final String departmentId;

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      year: json['year'] as int,
      departmentId: json['department_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'department_id': departmentId,
    };
  }

  BatchModel copyWith({
    String? id,
    String? name,
    int? year,
    String? departmentId,
  }) {
    return BatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      departmentId: departmentId ?? this.departmentId,
    );
  }
}
