class SystemActivityLogModel {
  const SystemActivityLogModel({
    required this.id,
    required this.action,
    required this.createdAt,
    this.actorUserId,
    this.actorName,
    this.targetType,
    this.targetId,
    this.description,
    this.metadata,
  });

  final String id;
  final String action;
  final DateTime createdAt;
  final String? actorUserId;
  final String? actorName;
  final String? targetType;
  final String? targetId;
  final String? description;
  final Map<String, dynamic>? metadata;

  String get actionLabel => _titleCase(action);

  String get targetLabel {
    final type = _textOrNull(targetType);
    final id = _textOrNull(targetId);

    if (type == null && id == null) {
      return 'System';
    }

    if (type == null) {
      return id!;
    }

    if (id == null) {
      return _titleCase(type);
    }

    return '${_titleCase(type)} $id';
  }

  String get actorLabel => _textOrNull(actorName) ?? 'System';

  factory SystemActivityLogModel.fromJson(Map<String, dynamic> json) {
    final actor = _mapOrNull(json['actor']);

    return SystemActivityLogModel(
      id: json['id'] as String,
      action: json['action'] as String,
      actorUserId: _textOrNull(json['actor_user_id']),
      actorName: _textOrNull(actor?['name']),
      targetType: _textOrNull(json['target_type']),
      targetId: _textOrNull(json['target_id']),
      description: _textOrNull(json['description']),
      metadata: _mapOrNull(json['metadata']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

Map<String, dynamic>? _mapOrNull(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

String? _textOrNull(dynamic value) {
  final text = value?.toString().trim();

  if (text == null || text.isEmpty) {
    return null;
  }

  return text;
}

String _titleCase(String value) {
  final words = value
      .trim()
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return 'Activity';
  }

  return words
      .map(
        (word) => word.length == 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
