import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/data/models/timetable_model.dart';
import 'package:eduvision_app/data/repositories/attendance_repository.dart';
import 'package:eduvision_app/data/repositories/gate_repository.dart';
import 'package:eduvision_app/data/repositories/message_repository.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
import 'package:eduvision_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final teacherAttendanceRepositoryProvider = Provider<AttendanceRepository>((
  ref,
) {
  return AttendanceRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
    faceApiService: ref.watch(faceApiServiceProvider),
  );
});

final teacherGateRepositoryProvider = Provider<GateRepository>((ref) {
  return GateRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
    qrTokenService: ref.watch(qrTokenServiceProvider),
  );
});

final teacherMessageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(supabaseService: ref.watch(supabaseServiceProvider));
});

final teacherGateStatusProvider = FutureProvider<List<GateLogModel>>((
  ref,
) async {
  final currentUser = ref.watch(authControllerProvider).user;

  if (currentUser == null) {
    return [];
  }

  final result = await ref
      .watch(teacherGateRepositoryProvider)
      .getTeacherStudentGateStatus(teacherId: currentUser.id, subjectId: '');

  if (result case Success<List<GateLogModel>>(:final data)) {
    return data;
  }

  if (result case Failure<List<GateLogModel>>(:final exception)) {
    throw Exception(exception.message);
  }

  return [];
});

final teacherTimetableProvider = FutureProvider<List<TimetableModel>>((
  ref,
) async {
  final currentUser = ref.watch(authControllerProvider).user;

  if (currentUser == null) {
    return [];
  }

  final result = await ref
      .watch(teacherAttendanceRepositoryProvider)
      .getTeacherTimetable(
        teacherId: currentUser.id,
        day: _weekdayName(DateTime.now()),
      );

  if (result case Success<List<TimetableModel>>(:final data)) {
    return data;
  }

  if (result case Failure<List<TimetableModel>>(:final exception)) {
    throw Exception(exception.message);
  }

  return [];
});

final teacherActiveClassProvider = FutureProvider<TimetableModel?>((ref) async {
  final currentUser = ref.watch(authControllerProvider).user;

  if (currentUser == null) {
    return null;
  }

  final result = await ref
      .watch(teacherAttendanceRepositoryProvider)
      .validateActiveClass(teacherId: currentUser.id, dateTime: DateTime.now());

  if (result case Success<TimetableModel?>(:final data)) {
    return data;
  }

  if (result case Failure<TimetableModel?>(:final exception)) {
    throw Exception(exception.message);
  }

  return null;
});

String _weekdayName(DateTime dateTime) {
  switch (dateTime.weekday) {
    case DateTime.monday:
      return 'monday';
    case DateTime.tuesday:
      return 'tuesday';
    case DateTime.wednesday:
      return 'wednesday';
    case DateTime.thursday:
      return 'thursday';
    case DateTime.friday:
      return 'friday';
    case DateTime.saturday:
      return 'saturday';
    case DateTime.sunday:
      return 'sunday';
  }

  return '';
}
