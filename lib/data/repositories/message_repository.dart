import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/anonymous_message_model.dart';
import 'package:eduvision_app/data/models/student_model.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class MessageRepository {
  const MessageRepository({this.supabaseService});

  final SupabaseService? supabaseService;

  Future<Result<AnonymousMessageModel>> submitAnonymousMessage({
    required AnonymousMessageModel message,
  }) async {
    return _notImplemented('Anonymous message submission');
  }

  Future<Result<List<AnonymousMessageModel>>> getTeacherMessages({
    required String teacherId,
  }) async {
    return _notImplemented('Teacher anonymous message lookup');
  }

  Future<Result<void>> markMessageResolved({required String messageId}) async {
    return _notImplemented('Anonymous message resolution');
  }

  Future<Result<void>> reportMessage({
    required String messageId,
    required String reportReason,
  }) async {
    return _notImplemented('Anonymous message reporting');
  }

  Future<Result<List<AnonymousMessageModel>>> getAdminReportedMessages() async {
    return _notImplemented('Admin reported message lookup');
  }

  Future<Result<StudentModel>> revealSenderForAdminReview({
    required String messageId,
  }) async {
    return _notImplemented('Admin sender reveal review');
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
