import 'package:eduvision_app/core/config/env_config.dart';
import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';

class FaceApiService {
  const FaceApiService();

  bool get isConfigured => EnvConfig.hasFaceApiConfig;

  Future<Result<Map<String, dynamic>>> processAttendanceFrames({
    required String sessionId,
    required List<String> frameReferences,
  }) async {
    // TODO: Send frame references to the future Python face recognition API.
    return _notImplemented('Face recognition frame processing');
  }

  Future<Result<String>> registerStudentEmbedding({
    required String studentId,
    required List<String> imageReferences,
  }) async {
    // TODO: Create and store a face embedding reference through the Python API.
    return _notImplemented('Student face embedding registration');
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
