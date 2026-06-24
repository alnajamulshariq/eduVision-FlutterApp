class SemesterModel {
  const SemesterModel({
    required this.id,
    required this.name,
    required this.number,
  });

  final String id;
  final String name;
  final int number;

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'number': number};
  }

  SemesterModel copyWith({String? id, String? name, int? number}) {
    return SemesterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
    );
  }
}
