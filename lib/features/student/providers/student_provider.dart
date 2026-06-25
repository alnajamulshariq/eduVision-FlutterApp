import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/attendance_record_model.dart';
import 'package:eduvision_app/data/repositories/attendance_repository.dart';
import 'package:eduvision_app/data/repositories/gate_repository.dart';
import 'package:eduvision_app/data/repositories/message_repository.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
import 'package:eduvision_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentAttendanceRepositoryProvider = Provider<AttendanceRepository>((
  ref,
) {
  return AttendanceRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
    faceApiService: ref.watch(faceApiServiceProvider),
  );
});

final studentAttendanceRecordsProvider =
    FutureProvider<List<AttendanceRecordModel>>((ref) async {
      final currentUser = ref.watch(authControllerProvider).user;

      if (currentUser == null) {
        return [];
      }

      final result = await ref
          .watch(studentAttendanceRepositoryProvider)
          .getStudentAttendance(studentId: currentUser.id);

      if (result case Success<List<AttendanceRecordModel>>(:final data)) {
        return data;
      }

      if (result case Failure<List<AttendanceRecordModel>>(:final exception)) {
        throw Exception(exception.message);
      }

      return [];
    });

final studentGateRepositoryProvider = Provider<GateRepository>((ref) {
  return GateRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
    qrTokenService: ref.watch(qrTokenServiceProvider),
  );
});

final studentMessageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(supabaseService: ref.watch(supabaseServiceProvider));
});
