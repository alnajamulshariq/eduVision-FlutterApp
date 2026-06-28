import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduvision_app/core/config/env_config.dart';
import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/face_recognition_result_model.dart';

class FaceApiService {
  const FaceApiService();

  static const _requestTimeout = Duration(seconds: 12);
  static const _connectionTimeout = Duration(seconds: 6);
  static const _processSessionPath = 'attendance/process-session';

  bool get isConfigured => EnvConfig.hasFaceApiConfig;

  Future<Result<FaceRecognitionSessionResultModel>> processAttendanceSession({
    required String sessionId,
    required String subjectId,
    required String teacherId,
    required List<String> enrolledStudentIds,
    int totalFrames = 20,
  }) async {
    final endpoint = _resolveEndpoint(_processSessionPath);

    if (endpoint == null) {
      return _failure(
        message:
            'Face Recognition API URL is not configured. Demo fallback will be used.',
        code: 'face_api_not_configured',
      );
    }

    final client = HttpClient()..connectionTimeout = _connectionTimeout;

    try {
      final request = await client.postUrl(endpoint).timeout(_requestTimeout);
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({
          'sessionId': sessionId,
          'subjectId': subjectId,
          'teacherId': teacherId,
          'enrolledStudentIds': enrolledStudentIds,
          'totalFrames': totalFrames,
        }),
      );

      final response = await request.close().timeout(_requestTimeout);
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _failure(
          message:
              'Face Recognition API returned an unavailable response. Demo fallback will be used.',
          code: 'face_api_unavailable',
        );
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is! Map) {
        return _failure(
          message:
              'Face Recognition API response was not valid. Demo fallback will be used.',
          code: 'face_api_invalid_response',
        );
      }

      final result = FaceRecognitionSessionResultModel.fromJson(
        Map<String, dynamic>.from(decoded),
        fallbackTotalFrames: totalFrames,
      );

      if (result.results.isEmpty) {
        return _failure(
          message:
              'Face Recognition API returned no student results. Demo fallback will be used.',
          code: 'face_api_empty_results',
        );
      }

      return Result.success(result);
    } on TimeoutException {
      return _failure(
        message: 'Face Recognition API timed out. Demo fallback will be used.',
        code: 'face_api_timeout',
      );
    } on SocketException {
      return _failure(
        message:
            'Face Recognition API could not be reached. Demo fallback will be used.',
        code: 'face_api_network_error',
      );
    } on FormatException {
      return _failure(
        message:
            'Face Recognition API response was not valid JSON. Demo fallback will be used.',
        code: 'face_api_invalid_json',
      );
    } catch (_) {
      return _failure(
        message:
            'Face Recognition API failed unexpectedly. Demo fallback will be used.',
        code: 'face_api_failed',
      );
    } finally {
      client.close(force: true);
    }
  }

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

  Uri? _resolveEndpoint(String path) {
    final rawBaseUrl = EnvConfig.faceApiBaseUrl.trim();

    if (rawBaseUrl.isEmpty) {
      return null;
    }

    final baseUrl = rawBaseUrl.endsWith('/') ? rawBaseUrl : '$rawBaseUrl/';
    final baseUri = Uri.tryParse(baseUrl);

    if (baseUri == null || !baseUri.hasScheme || !baseUri.hasAuthority) {
      return null;
    }

    return baseUri.resolve(path);
  }

  Result<T> _failure<T>({required String message, required String code}) {
    return Result.failure(AppException(message: message, code: code));
  }
}
