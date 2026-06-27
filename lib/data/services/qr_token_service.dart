import 'dart:convert';
import 'dart:math';

import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';

class QrTokenService {
  const QrTokenService();

  static const payloadType = 'attendance_qr';
  static const defaultTtl = Duration(seconds: 30);

  Future<Result<String>> generateStudentToken({
    String? studentUserId,
    String? studentId,
    Duration ttl = defaultTtl,
  }) async {
    final normalizedUserId = _normalizedOrNull(studentUserId);
    final normalizedStudentId = _normalizedOrNull(studentId);

    if (normalizedUserId == null && normalizedStudentId == null) {
      return const Result.failure(
        AppException(
          message: 'Student identity is required to generate a QR code.',
          code: 'qr_student_id_missing',
        ),
      );
    }

    final issuedAt = DateTime.now().toUtc();
    final expiresAt = issuedAt.add(ttl);
    final payload = <String, dynamic>{
      'type': payloadType,
      if (normalizedUserId != null) 'studentUserId': normalizedUserId,
      if (normalizedStudentId != null) 'studentId': normalizedStudentId,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'nonce': _nonce(),
    };

    return Result.success(jsonEncode(payload));
  }

  Result<DynamicQrPayload> parseAttendancePayload({
    required String payload,
    DateTime? now,
  }) {
    final rawPayload = payload.trim();

    if (rawPayload.isEmpty) {
      return const Result.failure(
        AppException(
          message: 'This QR code is empty. Please scan a valid student QR.',
          code: 'invalid_qr_payload',
        ),
      );
    }

    try {
      final decoded = jsonDecode(rawPayload);

      if (decoded is! Map) {
        return _invalidPayload();
      }

      final json = Map<String, dynamic>.from(decoded);
      final type = json['type'] as String?;

      if (type != payloadType) {
        return _invalidPayload();
      }

      final studentUserId = _normalizedOrNull(json['studentUserId'] as String?);
      final studentId = _normalizedOrNull(json['studentId'] as String?);

      if (studentUserId == null && studentId == null) {
        return const Result.failure(
          AppException(
            message: 'This QR code does not contain a student identity.',
            code: 'qr_student_id_missing',
          ),
        );
      }

      final issuedAt = _parseDate(json['issuedAt']);
      final expiresAt = _parseDate(json['expiresAt']);

      if (issuedAt == null || expiresAt == null) {
        return _invalidPayload();
      }

      final currentTime = (now ?? DateTime.now()).toUtc();

      if (!expiresAt.isAfter(currentTime)) {
        return const Result.failure(
          AppException(
            message:
                'This QR code has expired. Ask the student to show the latest QR.',
            code: 'qr_expired',
          ),
        );
      }

      final nonce = _normalizedOrNull(json['nonce'] as String?);

      if (nonce == null) {
        return _invalidPayload();
      }

      return Result.success(
        DynamicQrPayload(
          studentUserId: studentUserId,
          studentId: studentId,
          issuedAt: issuedAt,
          expiresAt: expiresAt,
          nonce: nonce,
        ),
      );
    } catch (_) {
      return _invalidPayload();
    }
  }

  Future<Result<bool>> verifyStudentToken({required String token}) async {
    final result = parseAttendancePayload(payload: token);

    if (result case Success<DynamicQrPayload>()) {
      return const Result.success(true);
    }

    if (result case Failure<DynamicQrPayload>(:final exception)) {
      return Result.failure(exception);
    }

    return const Result.success(false);
  }

  Result<String> determineNextGateAction({required int previousScanCount}) {
    if (previousScanCount < 0) {
      return const Result.failure(
        AppException(
          message: 'Previous scan count cannot be negative.',
          code: 'invalid_gate_scan_count',
        ),
      );
    }

    return Result.success(previousScanCount.isEven ? 'entry' : 'exit');
  }

  Result<DynamicQrPayload> _invalidPayload() {
    return const Result.failure(
      AppException(
        message: 'This is not a valid EduVision attendance QR.',
        code: 'invalid_qr_payload',
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString())?.toUtc();
  }

  String? _normalizedOrNull(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String _nonce() {
    final random = Random.secure();

    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}

class DynamicQrPayload {
  const DynamicQrPayload({
    required this.studentUserId,
    required this.studentId,
    required this.issuedAt,
    required this.expiresAt,
    required this.nonce,
  });

  final String? studentUserId;
  final String? studentId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String nonce;

  String get lookupId => studentUserId ?? studentId ?? '';
}
