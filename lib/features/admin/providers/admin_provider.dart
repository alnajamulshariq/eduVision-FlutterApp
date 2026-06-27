import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/data/repositories/admin_repository.dart';
import 'package:eduvision_app/data/repositories/attendance_repository.dart';
import 'package:eduvision_app/data/repositories/gate_repository.dart';
import 'package:eduvision_app/data/repositories/message_repository.dart';
import 'package:eduvision_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(supabaseService: ref.watch(supabaseServiceProvider));
});

final adminAttendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
    faceApiService: ref.watch(faceApiServiceProvider),
  );
});

final adminGateRepositoryProvider = Provider<GateRepository>((ref) {
  return GateRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
    qrTokenService: ref.watch(qrTokenServiceProvider),
  );
});

final adminGateLogsProvider = FutureProvider<List<GateLogModel>>((ref) async {
  final result = await ref
      .watch(adminGateRepositoryProvider)
      .getAdminGateLogs();

  if (result case Success<List<GateLogModel>>(:final data)) {
    return data;
  }

  if (result case Failure<List<GateLogModel>>(:final exception)) {
    throw Exception(exception.message);
  }

  return [];
});

final adminMessageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(supabaseService: ref.watch(supabaseServiceProvider));
});
