class AppException implements Exception {
  const AppException({required this.message, this.code, this.details});

  final String message;
  final String? code;
  final Object? details;

  factory AppException.notImplemented(String feature) {
    return AppException(
      message: '$feature is not implemented yet.',
      code: 'not_implemented',
    );
  }

  @override
  String toString() {
    if (code == null) {
      return 'AppException: $message';
    }
    return 'AppException($code): $message';
  }
}
