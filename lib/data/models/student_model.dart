class StudentModel {
  const StudentModel({
    required this.id,
    required this.userId,
    required this.rollNo,
    required this.name,
    required this.departmentId,
    required this.batchId,
    required this.semesterId,
    required this.parentEmail,
    this.faceEmbeddingId,
    required this.isActive,
  });

  final String id;
  final String userId;
  final String rollNo;
  final String name;
  final String departmentId;
  final String batchId;
  final String semesterId;
  final String parentEmail;
  final String? faceEmbeddingId;
  final bool isActive;

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rollNo: json['roll_no'] as String,
      name: json['name'] as String,
      departmentId: json['department_id'] as String,
      batchId: json['batch_id'] as String,
      semesterId: json['semester_id'] as String,
      parentEmail: json['parent_email'] as String,
      faceEmbeddingId: json['face_embedding_id'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'roll_no': rollNo,
      'name': name,
      'department_id': departmentId,
      'batch_id': batchId,
      'semester_id': semesterId,
      'parent_email': parentEmail,
      'face_embedding_id': faceEmbeddingId,
      'is_active': isActive,
    };
  }

  StudentModel copyWith({
    String? id,
    String? userId,
    String? rollNo,
    String? name,
    String? departmentId,
    String? batchId,
    String? semesterId,
    String? parentEmail,
    String? faceEmbeddingId,
    bool? isActive,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rollNo: rollNo ?? this.rollNo,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      batchId: batchId ?? this.batchId,
      semesterId: semesterId ?? this.semesterId,
      parentEmail: parentEmail ?? this.parentEmail,
      faceEmbeddingId: faceEmbeddingId ?? this.faceEmbeddingId,
      isActive: isActive ?? this.isActive,
    );
  }
}
