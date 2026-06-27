import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/attendance_record_model.dart';
import 'package:eduvision_app/data/models/dynamic_qr_model.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/data/models/teacher_model.dart';
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
    qrTokenService: ref.watch(qrTokenServiceProvider),
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

final studentQrIdentityProvider = FutureProvider<StudentQrIdentityModel>((
  ref,
) async {
  final currentUser = ref.watch(authControllerProvider).user;

  if (currentUser == null) {
    throw Exception('Please log in before opening your dynamic QR.');
  }

  final result = await ref
      .watch(studentAttendanceRepositoryProvider)
      .getStudentQrIdentity(studentUserId: currentUser.id);

  if (result case Success<StudentQrIdentityModel>(:final data)) {
    return data;
  }

  if (result case Failure<StudentQrIdentityModel>(:final exception)) {
    throw Exception(exception.message);
  }

  throw Exception('Unable to load student QR identity.');
});

final studentGateRepositoryProvider = Provider<GateRepository>((ref) {
  return GateRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
    qrTokenService: ref.watch(qrTokenServiceProvider),
  );
});

final studentGateLogsProvider = FutureProvider<List<GateLogModel>>((ref) async {
  final currentUser = ref.watch(authControllerProvider).user;

  if (currentUser == null) {
    return [];
  }

  final result = await ref
      .watch(studentGateRepositoryProvider)
      .getStudentGateHistory(studentId: currentUser.id);

  if (result case Success<List<GateLogModel>>(:final data)) {
    return data;
  }

  if (result case Failure<List<GateLogModel>>(:final exception)) {
    throw Exception(exception.message);
  }

  return [];
});

final studentMessageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(supabaseService: ref.watch(supabaseServiceProvider));
});

final studentMessageTeachersProvider = FutureProvider<List<TeacherModel>>((
  ref,
) async {
  final currentUser = ref.watch(authControllerProvider).user;

  if (currentUser == null) {
    return [];
  }

  final result = await ref
      .watch(studentMessageRepositoryProvider)
      .getAvailableTeachersForStudent(studentId: currentUser.id);

  if (result case Success<List<TeacherModel>>(:final data)) {
    return data;
  }

  if (result case Failure<List<TeacherModel>>(:final exception)) {
    throw Exception(exception.message);
  }

  return [];
});
