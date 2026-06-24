import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/data/services/qr_token_service.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class GateRepository {
  const GateRepository({this.supabaseService, this.qrTokenService});

  final SupabaseService? supabaseService;
  final QrTokenService? qrTokenService;

  Future<Result<GateLogModel>> createGateLog({
    required GateLogModel gateLog,
  }) async {
    return _notImplemented('Gate log creation');
  }

  Future<Result<List<GateLogModel>>> getStudentGateHistory({
    required String studentId,
  }) async {
    return _notImplemented('Student gate history lookup');
  }

  Future<Result<List<GateLogModel>>> getAdminGateLogs({
    DateTime? date,
    String? status,
  }) async {
    return _notImplemented('Admin gate log lookup');
  }

  Future<Result<List<GateLogModel>>> getTeacherStudentGateStatus({
    required String teacherId,
    required String subjectId,
  }) async {
    return _notImplemented('Teacher student gate status lookup');
  }

  Future<Result<String>> determineNextGateAction({
    required String studentId,
  }) async {
    return _notImplemented('Next gate action determination');
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
