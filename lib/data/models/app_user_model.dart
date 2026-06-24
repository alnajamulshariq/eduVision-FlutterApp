class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.name,
    required this.universityEmail,
    required this.role,
    required this.isFirstLogin,
    required this.passwordChangedOnce,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String universityEmail;
  final String role;
  final bool isFirstLogin;
  final bool passwordChangedOnce;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      universityEmail: json['university_email'] as String,
      role: json['role'] as String,
      isFirstLogin: json['is_first_login'] as bool,
      passwordChangedOnce: json['password_changed_once'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'university_email': universityEmail,
      'role': role,
      'is_first_login': isFirstLogin,
      'password_changed_once': passwordChangedOnce,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AppUserModel copyWith({
    String? id,
    String? name,
    String? universityEmail,
    String? role,
    bool? isFirstLogin,
    bool? passwordChangedOnce,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      universityEmail: universityEmail ?? this.universityEmail,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      passwordChangedOnce: passwordChangedOnce ?? this.passwordChangedOnce,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
