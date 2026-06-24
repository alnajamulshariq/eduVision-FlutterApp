import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/app_user_model.dart';
import 'package:eduvision_app/data/models/batch_model.dart';
import 'package:eduvision_app/data/models/department_model.dart';
import 'package:eduvision_app/data/models/semester_model.dart';
import 'package:eduvision_app/data/models/student_model.dart';
import 'package:eduvision_app/data/models/subject_model.dart';
import 'package:eduvision_app/data/models/teacher_model.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class AdminRepository {
  const AdminRepository({this.supabaseService});

  final SupabaseService? supabaseService;

  Future<Result<void>> createStudentAccount({
    required AppUserModel user,
    required StudentModel student,
  }) async {
    return _notImplemented('Student account creation');
  }

  Future<Result<void>> createTeacherAccount({
    required AppUserModel user,
    required TeacherModel teacher,
  }) async {
    return _notImplemented('Teacher account creation');
  }

  Future<Result<void>> createAdminAccount({required AppUserModel user}) async {
    return _notImplemented('Admin account creation');
  }

  Future<Result<DepartmentModel>> createDepartment({
    required DepartmentModel department,
  }) async {
    return _notImplemented('Department creation');
  }

  Future<Result<BatchModel>> createBatch({required BatchModel batch}) async {
    return _notImplemented('Batch creation');
  }

  Future<Result<SemesterModel>> createSemester({
    required SemesterModel semester,
  }) async {
    return _notImplemented('Semester creation');
  }

  Future<Result<SubjectModel>> createSubject({
    required SubjectModel subject,
  }) async {
    return _notImplemented('Subject creation');
  }

  Future<Result<void>> assignTeacherToSubject({
    required String teacherId,
    required String subjectId,
  }) async {
    return _notImplemented('Teacher subject assignment');
  }

  Future<Result<void>> assignStudentToSubject({
    required String studentId,
    required String subjectId,
  }) async {
    return _notImplemented('Student subject assignment');
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
