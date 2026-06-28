import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/admin_management_model.dart';
import 'package:eduvision_app/data/models/anonymous_message_model.dart';
import 'package:eduvision_app/data/models/attendance_report_model.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/data/models/system_activity_log_model.dart';
import 'package:eduvision_app/data/repositories/admin_repository.dart';
import 'package:eduvision_app/data/repositories/attendance_repository.dart';
import 'package:eduvision_app/data/repositories/gate_repository.dart';
import 'package:eduvision_app/data/repositories/message_repository.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
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

final adminUsersOverviewProvider =
    FutureProvider.autoDispose<AdminUsersOverviewModel>((ref) async {
      final currentUser = ref.watch(authControllerProvider).user;

      if (currentUser == null || currentUser.role.toLowerCase() != 'admin') {
        return const AdminUsersOverviewModel(users: []);
      }

      final result = await ref
          .watch(adminRepositoryProvider)
          .getAdminUsersOverview();

      if (result case Success<AdminUsersOverviewModel>(:final data)) {
        return data;
      }

      if (result case Failure<AdminUsersOverviewModel>(:final exception)) {
        throw Exception(exception.message);
      }

      return const AdminUsersOverviewModel(users: []);
    });

final adminAcademicOverviewProvider =
    FutureProvider.autoDispose<AcademicOverviewModel>((ref) async {
      final currentUser = ref.watch(authControllerProvider).user;

      if (currentUser == null || currentUser.role.toLowerCase() != 'admin') {
        return const AcademicOverviewModel(
          departments: [],
          batches: [],
          semesters: [],
          subjects: [],
          teachers: [],
          students: [],
          teacherAssignments: [],
          studentEnrollments: [],
        );
      }

      final result = await ref
          .watch(adminRepositoryProvider)
          .getAcademicOverview();

      if (result case Success<AcademicOverviewModel>(:final data)) {
        return data;
      }

      if (result case Failure<AcademicOverviewModel>(:final exception)) {
        throw Exception(exception.message);
      }

      return const AcademicOverviewModel(
        departments: [],
        batches: [],
        semesters: [],
        subjects: [],
        teachers: [],
        students: [],
        teacherAssignments: [],
        studentEnrollments: [],
      );
    });

final adminSystemActivityLogsProvider =
    FutureProvider.autoDispose<List<SystemActivityLogModel>>((ref) async {
      final currentUser = ref.watch(authControllerProvider).user;

      if (currentUser == null || currentUser.role.toLowerCase() != 'admin') {
        return [];
      }

      final result = await ref
          .watch(adminRepositoryProvider)
          .getSystemActivityLogs();

      if (result case Success<List<SystemActivityLogModel>>(:final data)) {
        return data;
      }

      if (result case Failure<List<SystemActivityLogModel>>(:final exception)) {
        throw Exception(exception.message);
      }

      return [];
    });

final adminAttendanceReportsProvider =
    FutureProvider.autoDispose<List<AttendanceReportModel>>((ref) async {
      final currentUser = ref.watch(authControllerProvider).user;

      if (currentUser == null || currentUser.role.toLowerCase() != 'admin') {
        return [];
      }

      final result = await ref
          .watch(adminAttendanceRepositoryProvider)
          .getAdminAttendanceReports();

      if (result case Success<List<AttendanceReportModel>>(:final data)) {
        return data;
      }

      if (result case Failure<List<AttendanceReportModel>>(:final exception)) {
        throw Exception(exception.message);
      }

      return [];
    });

final adminMessageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(supabaseService: ref.watch(supabaseServiceProvider));
});

final adminReportedMessagesProvider =
    FutureProvider<List<AnonymousMessageModel>>((ref) async {
      final result = await ref
          .watch(adminMessageRepositoryProvider)
          .getAdminReportedMessages();

      if (result case Success<List<AnonymousMessageModel>>(:final data)) {
        return data;
      }

      if (result case Failure<List<AnonymousMessageModel>>(:final exception)) {
        throw Exception(exception.message);
      }

      return [];
    });
