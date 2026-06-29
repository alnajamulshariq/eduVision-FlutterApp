import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/data/models/admin_management_model.dart';
import 'package:eduvision_app/data/models/department_model.dart';
import 'package:eduvision_app/features/admin/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _assignmentSteps = [
  'Create department',
  'Create batch',
  'Add semester',
  'Add subject',
  'Assign teacher',
  'Enroll students',
];

class AdminAcademicsScreen extends ConsumerWidget {
  const AdminAcademicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(adminAcademicOverviewProvider);

    return ModuleScreenShell(
      title: 'Academic Management',
      subtitle: 'Departments, batches, semesters, subjects, and assignments.',
      fallbackRoute: AppRoutes.admin,
      children: [
        ...overviewAsync.when(
          loading: () => const <Widget>[
            _AcademicLoadingPanel(),
            _AcademicWriteNotice(),
          ],
          error: (error, _) => <Widget>[
            _AcademicErrorPanel(message: _cleanErrorMessage(error)),
            const _AcademicWriteNotice(),
          ],
          data: (overview) => <Widget>[
            _AcademicSummaryCard(overview: overview),
            _AcademicStructureCard(overview: overview),
            _AcademicPeopleCard(overview: overview),
            _SubjectAssignmentCard(overview: overview),
            const _AssignmentFlowCard(steps: _assignmentSteps),
            _AcademicQuickActions(
              onCreateDepartment: () =>
                  _showCreateDepartmentDialog(context, ref),
              onCreateBatch: () =>
                  _showCreateBatchDialog(context, ref, overview: overview),
              onCreateSemester: () => _showCreateSemesterDialog(context, ref),
              onCreateSubject: () =>
                  _showCreateSubjectDialog(context, ref, overview: overview),
              onAssignTeacher: () =>
                  _showAssignTeacherDialog(context, ref, overview: overview),
              onEnrollStudent: () =>
                  _showEnrollStudentDialog(context, ref, overview: overview),
            ),
          ],
        ),
      ],
    );
  }
}

class _AcademicSummaryCard extends StatelessWidget {
  const _AcademicSummaryCard({required this.overview});

  final AcademicOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Academic Summary',
            icon: Icons.dashboard_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Departments',
                  value: overview.departments.length.toString(),
                  icon: Icons.account_tree_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Batches',
                  value: overview.batches.length.toString(),
                  icon: Icons.groups_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Semesters',
                  value: overview.semesters.length.toString(),
                  icon: Icons.layers_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Subjects',
                  value: overview.subjects.length.toString(),
                  icon: Icons.menu_book_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Teachers',
                  value: overview.teachers.length.toString(),
                  icon: Icons.co_present_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Students',
                  value: overview.students.length.toString(),
                  icon: Icons.school_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcademicStructureCard extends StatelessWidget {
  const _AcademicStructureCard({required this.overview});

  final AcademicOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Academic Structure',
            icon: Icons.schema_rounded,
          ),
          const SizedBox(height: 12),
          _SubsectionTitle(
            label: 'Departments',
            count: overview.departments.length,
          ),
          const SizedBox(height: 8),
          if (overview.departments.isEmpty)
            _EmptyInfoTile(label: 'No departments found')
          else
            for (final department in overview.departments.take(4)) ...[
              _DepartmentTile(department: department),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 4),
          _SubsectionTitle(label: 'Batches', count: overview.batches.length),
          const SizedBox(height: 8),
          if (overview.batches.isEmpty)
            _EmptyInfoTile(label: 'No batches found')
          else
            for (final batch in overview.batches.take(4)) ...[
              ModuleInfoTile(
                title: batch.name,
                subtitle:
                    'Year ${batch.year} - ${_display(batch.departmentName, 'Department')}',
                icon: Icons.groups_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 4),
          _SubsectionTitle(
            label: 'Semesters',
            count: overview.semesters.length,
          ),
          const SizedBox(height: 8),
          if (overview.semesters.isEmpty)
            _EmptyInfoTile(label: 'No semesters found')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final semester in overview.semesters.take(8))
                  ModuleBadge(
                    label: '${semester.name} (${semester.number})',
                    icon: Icons.layers_rounded,
                    color: colorScheme.tertiary,
                  ),
              ],
            ),
          const SizedBox(height: 12),
          _SubsectionTitle(label: 'Subjects', count: overview.subjects.length),
          const SizedBox(height: 8),
          if (overview.subjects.isEmpty)
            _EmptyInfoTile(label: 'No subjects found')
          else
            for (final subject in overview.subjects.take(6)) ...[
              ModuleInfoTile(
                title: subject.name,
                subtitle:
                    '${subject.code} - ${_display(subject.departmentName, 'Department')} - ${_display(subject.semesterName, 'Semester')}',
                icon: Icons.menu_book_rounded,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _AcademicPeopleCard extends StatelessWidget {
  const _AcademicPeopleCard({required this.overview});

  final AcademicOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'People Directory',
            icon: Icons.people_alt_rounded,
          ),
          const SizedBox(height: 12),
          _SubsectionTitle(label: 'Teachers', count: overview.teachers.length),
          const SizedBox(height: 8),
          if (overview.teachers.isEmpty)
            _EmptyInfoTile(label: 'No teachers found')
          else
            for (final teacher in overview.teachers.take(4)) ...[
              ModuleInfoTile(
                title: teacher.name,
                subtitle:
                    '${teacher.employeeId} - ${_display(teacher.departmentName, 'Department')}',
                icon: Icons.co_present_rounded,
                color: colorScheme.primary,
                trailing: ModuleBadge(
                  label: teacher.isActive ? 'Active' : 'Inactive',
                  color: teacher.isActive
                      ? colorScheme.secondary
                      : colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 4),
          _SubsectionTitle(label: 'Students', count: overview.students.length),
          const SizedBox(height: 8),
          if (overview.students.isEmpty)
            _EmptyInfoTile(label: 'No students found')
          else
            for (final student in overview.students.take(4)) ...[
              ModuleInfoTile(
                title: student.name,
                subtitle:
                    '${student.rollNo} - ${_display(student.departmentName, 'Department')} - ${_display(student.batchName, 'Batch')} - ${_display(student.semesterName, 'Semester')}',
                icon: Icons.school_rounded,
                color: colorScheme.tertiary,
                trailing: ModuleBadge(
                  label: student.isActive ? 'Active' : 'Inactive',
                  color: student.isActive
                      ? colorScheme.secondary
                      : colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _SubjectAssignmentCard extends StatelessWidget {
  const _SubjectAssignmentCard({required this.overview});

  final AcademicOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: _SectionTitle(
                  title: 'Assignments',
                  icon: Icons.assignment_turned_in_rounded,
                ),
              ),
              ModuleBadge(
                label:
                    '${overview.teacherAssignments.length + overview.studentEnrollments.length}',
                icon: Icons.checklist_rounded,
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SubsectionTitle(
            label: 'Teacher Subjects',
            count: overview.teacherAssignments.length,
          ),
          const SizedBox(height: 8),
          if (overview.teacherAssignments.isEmpty)
            _EmptyInfoTile(label: 'No teacher assignments found')
          else
            for (final assignment in overview.teacherAssignments.take(4)) ...[
              ModuleInfoTile(
                title: _display(assignment.subjectName, 'Subject'),
                subtitle:
                    '${_display(assignment.teacherName, 'Teacher')} - ${_display(assignment.departmentName, 'Department')} - ${_display(assignment.batchName, 'Batch')} - ${_display(assignment.semesterName, 'Semester')}',
                icon: Icons.assignment_ind_rounded,
                color: colorScheme.primary,
                trailing: ModuleBadge(
                  label: assignment.isActive ? 'Active' : 'Inactive',
                  color: assignment.isActive
                      ? colorScheme.secondary
                      : colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 4),
          _SubsectionTitle(
            label: 'Student Enrollments',
            count: overview.studentEnrollments.length,
          ),
          const SizedBox(height: 8),
          if (overview.studentEnrollments.isEmpty)
            _EmptyInfoTile(label: 'No student enrollments found')
          else
            for (final enrollment in overview.studentEnrollments.take(4)) ...[
              ModuleInfoTile(
                title: _display(enrollment.studentName, 'Student'),
                subtitle:
                    '${_display(enrollment.subjectName, 'Subject')} - ${_display(enrollment.batchName, 'Batch')} - ${_display(enrollment.semesterName, 'Semester')}',
                icon: Icons.how_to_reg_rounded,
                color: colorScheme.tertiary,
                trailing: ModuleBadge(
                  label: enrollment.isActive ? 'Active' : 'Inactive',
                  color: enrollment.isActive
                      ? colorScheme.secondary
                      : colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _AssignmentFlowCard extends StatelessWidget {
  const _AssignmentFlowCard({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Assignment Flow',
            icon: Icons.playlist_add_check_rounded,
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < steps.length; index++) ...[
            _ChecklistStep(number: index + 1, label: steps[index]),
            if (index != steps.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AcademicQuickActions extends StatelessWidget {
  const _AcademicQuickActions({
    required this.onCreateDepartment,
    required this.onCreateBatch,
    required this.onCreateSemester,
    required this.onCreateSubject,
    required this.onAssignTeacher,
    required this.onEnrollStudent,
  });

  final VoidCallback onCreateDepartment;
  final VoidCallback onCreateBatch;
  final VoidCallback onCreateSemester;
  final VoidCallback onCreateSubject;
  final VoidCallback onAssignTeacher;
  final VoidCallback onEnrollStudent;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Quick Actions', icon: Icons.bolt_rounded),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                label: 'Add Department',
                icon: Icons.account_tree_rounded,
                onPressed: onCreateDepartment,
              ),
              _ActionButton(
                label: 'Add Batch',
                icon: Icons.groups_rounded,
                onPressed: onCreateBatch,
              ),
              _ActionButton(
                label: 'Add Semester',
                icon: Icons.layers_rounded,
                onPressed: onCreateSemester,
              ),
              _ActionButton(
                label: 'Add Subject',
                icon: Icons.menu_book_rounded,
                onPressed: onCreateSubject,
              ),
              _ActionButton(
                label: 'Assign Teacher',
                icon: Icons.assignment_ind_rounded,
                onPressed: onAssignTeacher,
              ),
              _ActionButton(
                label: 'Enroll Students',
                icon: Icons.how_to_reg_rounded,
                onPressed: onEnrollStudent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _AcademicWriteNotice(),
        ],
      ),
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  const _DepartmentTile({required this.department});

  final DepartmentModel department;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModuleInfoTile(
      title: department.name,
      subtitle: 'Code: ${department.code}',
      icon: Icons.account_tree_rounded,
      color: colorScheme.secondary,
    );
  }
}

class _ChecklistStep extends StatelessWidget {
  const _ChecklistStep({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.34)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_rounded,
              color: colorScheme.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$number. $label',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _SubsectionTitle extends StatelessWidget {
  const _SubsectionTitle({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        ModuleBadge(label: count.toString(), color: colorScheme.primary),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _AcademicLoadingPanel extends StatelessWidget {
  const _AcademicLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading academic data',
        subtitle: 'Fetching departments, users, subjects, and assignments.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _AcademicErrorPanel extends StatelessWidget {
  const _AcademicErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load academic data',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
      ),
    );
  }
}

class _EmptyInfoTile extends StatelessWidget {
  const _EmptyInfoTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModuleInfoTile(
      title: label,
      subtitle: 'Add records in Supabase to populate this section.',
      icon: Icons.info_outline_rounded,
      color: colorScheme.tertiary,
    );
  }
}

class _AcademicWriteNotice extends StatelessWidget {
  const _AcademicWriteNotice();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModuleInfoTile(
      title: 'Create and assignment actions are manual for now',
      subtitle:
          'Academic writes run through secure Edge Functions, not directly through the Flutter anon client.',
      icon: Icons.admin_panel_settings_rounded,
      color: colorScheme.tertiary,
    );
  }
}

Future<void> _showCreateDepartmentDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final nameController = TextEditingController();
  final codeController = TextEditingController();

  await _showAcademicSheet(
    context: context,
    ref: ref,
    title: 'Create Department',
    icon: Icons.account_tree_rounded,
    fields: [
      TextField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Department Name',
          prefixIcon: Icon(Icons.account_tree_rounded),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: codeController,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Department Code',
          prefixIcon: Icon(Icons.tag_rounded),
        ),
      ),
    ],
    onSubmit: () => ref
        .read(adminRepositoryProvider)
        .createDepartmentSecure(
          name: nameController.text,
          code: codeController.text,
        ),
  );

  nameController.dispose();
  codeController.dispose();
}

Future<void> _showCreateBatchDialog(
  BuildContext context,
  WidgetRef ref, {
  required AcademicOverviewModel overview,
}) async {
  if (overview.departments.isEmpty) {
    showModuleSnackBar(context, 'Create a department before adding batches.');
    return;
  }

  final nameController = TextEditingController();
  final yearController = TextEditingController();
  var departmentId = overview.departments.first.id;

  await _showAcademicSheet(
    context: context,
    ref: ref,
    title: 'Create Batch',
    icon: Icons.groups_rounded,
    fieldsBuilder: (setSheetState, isSubmitting) => [
      TextField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Batch Name',
          prefixIcon: Icon(Icons.groups_rounded),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: yearController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Year',
          prefixIcon: Icon(Icons.calendar_month_rounded),
        ),
      ),
      const SizedBox(height: 10),
      _IdDropdown(
        label: 'Department',
        icon: Icons.account_tree_rounded,
        value: departmentId,
        items: {
          for (final department in overview.departments)
            department.id: department.name,
        },
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => departmentId = value),
      ),
    ],
    onSubmit: () {
      final year = int.tryParse(yearController.text.trim());
      if (year == null) {
        return Future.value(
          const Result.failure(
            AppException(
              message: 'Enter a valid batch year.',
              code: 'invalid_batch_year',
            ),
          ),
        );
      }

      return ref
          .read(adminRepositoryProvider)
          .createBatchSecure(
            name: nameController.text,
            year: year,
            departmentId: departmentId,
          );
    },
  );

  nameController.dispose();
  yearController.dispose();
}

Future<void> _showCreateSemesterDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  await _showAcademicSheet(
    context: context,
    ref: ref,
    title: 'Create Semester',
    icon: Icons.layers_rounded,
    fields: [
      TextField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Semester Name',
          prefixIcon: Icon(Icons.layers_rounded),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: numberController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Semester Number',
          prefixIcon: Icon(Icons.onetwothree_rounded),
        ),
      ),
    ],
    onSubmit: () {
      final number = int.tryParse(numberController.text.trim());
      if (number == null) {
        return Future.value(
          const Result.failure(
            AppException(
              message: 'Enter a valid semester number.',
              code: 'invalid_semester_number',
            ),
          ),
        );
      }

      return ref
          .read(adminRepositoryProvider)
          .createSemesterSecure(name: nameController.text, number: number);
    },
  );

  nameController.dispose();
  numberController.dispose();
}

Future<void> _showCreateSubjectDialog(
  BuildContext context,
  WidgetRef ref, {
  required AcademicOverviewModel overview,
}) async {
  if (overview.departments.isEmpty || overview.semesters.isEmpty) {
    showModuleSnackBar(
      context,
      'Create departments and semesters before adding subjects.',
    );
    return;
  }

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  var departmentId = overview.departments.first.id;
  var semesterId = overview.semesters.first.id;

  await _showAcademicSheet(
    context: context,
    ref: ref,
    title: 'Create Subject',
    icon: Icons.menu_book_rounded,
    fieldsBuilder: (setSheetState, isSubmitting) => [
      TextField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Subject Name',
          prefixIcon: Icon(Icons.menu_book_rounded),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: codeController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Subject Code',
          prefixIcon: Icon(Icons.tag_rounded),
        ),
      ),
      const SizedBox(height: 10),
      _IdDropdown(
        label: 'Department',
        icon: Icons.account_tree_rounded,
        value: departmentId,
        items: {
          for (final department in overview.departments)
            department.id: department.name,
        },
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => departmentId = value),
      ),
      const SizedBox(height: 10),
      _IdDropdown(
        label: 'Semester',
        icon: Icons.layers_rounded,
        value: semesterId,
        items: {
          for (final semester in overview.semesters) semester.id: semester.name,
        },
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => semesterId = value),
      ),
    ],
    onSubmit: () => ref
        .read(adminRepositoryProvider)
        .createSubjectSecure(
          name: nameController.text,
          code: codeController.text,
          departmentId: departmentId,
          semesterId: semesterId,
        ),
  );

  nameController.dispose();
  codeController.dispose();
}

Future<void> _showAssignTeacherDialog(
  BuildContext context,
  WidgetRef ref, {
  required AcademicOverviewModel overview,
}) async {
  if (overview.teachers.isEmpty ||
      overview.subjects.isEmpty ||
      overview.batches.isEmpty) {
    showModuleSnackBar(
      context,
      'Teachers, subjects, and batches are required before assignment.',
    );
    return;
  }

  var teacherId = overview.teachers.first.id;
  var subjectId = overview.subjects.first.id;
  var batchId = overview.batches.first.id;

  await _showAcademicSheet(
    context: context,
    ref: ref,
    title: 'Assign Teacher',
    icon: Icons.assignment_ind_rounded,
    fieldsBuilder: (setSheetState, isSubmitting) => [
      _IdDropdown(
        label: 'Teacher',
        icon: Icons.co_present_rounded,
        value: teacherId,
        items: {
          for (final teacher in overview.teachers)
            teacher.id: '${teacher.name} - ${teacher.employeeId}',
        },
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => teacherId = value),
      ),
      const SizedBox(height: 10),
      _IdDropdown(
        label: 'Subject',
        icon: Icons.menu_book_rounded,
        value: subjectId,
        items: {
          for (final subject in overview.subjects)
            subject.id: '${subject.name} - ${subject.code}',
        },
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => subjectId = value),
      ),
      const SizedBox(height: 10),
      _IdDropdown(
        label: 'Batch',
        icon: Icons.groups_rounded,
        value: batchId,
        items: {for (final batch in overview.batches) batch.id: batch.name},
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => batchId = value),
      ),
    ],
    onSubmit: () {
      final subject = _subjectById(overview, subjectId);
      final batch = _batchById(overview, batchId);

      if (subject == null || batch == null) {
        return Future.value(
          const Result.failure(
            AppException(
              message: 'Choose a valid subject and batch.',
              code: 'invalid_assignment_selection',
            ),
          ),
        );
      }

      return ref
          .read(adminRepositoryProvider)
          .assignTeacherSecure(
            teacherId: teacherId,
            subjectId: subjectId,
            departmentId: subject.departmentId,
            batchId: batchId,
            semesterId: subject.semesterId,
          );
    },
  );
}

Future<void> _showEnrollStudentDialog(
  BuildContext context,
  WidgetRef ref, {
  required AcademicOverviewModel overview,
}) async {
  if (overview.students.isEmpty || overview.subjects.isEmpty) {
    showModuleSnackBar(
      context,
      'Students and subjects are required before enrollment.',
    );
    return;
  }

  var studentId = overview.students.first.id;
  var subjectId = overview.subjects.first.id;

  await _showAcademicSheet(
    context: context,
    ref: ref,
    title: 'Enroll Student',
    icon: Icons.how_to_reg_rounded,
    fieldsBuilder: (setSheetState, isSubmitting) => [
      _IdDropdown(
        label: 'Student',
        icon: Icons.school_rounded,
        value: studentId,
        items: {
          for (final student in overview.students)
            student.id: '${student.name} - ${student.rollNo}',
        },
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => studentId = value),
      ),
      const SizedBox(height: 10),
      _IdDropdown(
        label: 'Subject',
        icon: Icons.menu_book_rounded,
        value: subjectId,
        items: {
          for (final subject in overview.subjects)
            subject.id: '${subject.name} - ${subject.code}',
        },
        onChanged: isSubmitting
            ? null
            : (value) => setSheetState(() => subjectId = value),
      ),
    ],
    onSubmit: () {
      final student = _studentById(overview, studentId);
      final subject = _subjectById(overview, subjectId);

      if (student == null || subject == null) {
        return Future.value(
          const Result.failure(
            AppException(
              message: 'Choose a valid student and subject.',
              code: 'invalid_enrollment_selection',
            ),
          ),
        );
      }

      return ref
          .read(adminRepositoryProvider)
          .enrollStudentSecure(
            studentId: studentId,
            subjectId: subjectId,
            departmentId: subject.departmentId,
            batchId: student.batchId,
            semesterId: subject.semesterId,
          );
    },
  );
}

Future<void> _showAcademicSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required IconData icon,
  required Future<Result<AdminWriteResultModel>> Function() onSubmit,
  List<Widget>? fields,
  List<Widget> Function(StateSetter setSheetState, bool isSubmitting)?
  fieldsBuilder,
}) async {
  final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  var isSubmitting = false;

  final successMessage = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final colorScheme = Theme.of(sheetContext).colorScheme;
          final children =
              fieldsBuilder?.call(setSheetState, isSubmitting) ??
              fields ??
              const <Widget>[];

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: title, icon: icon),
                    const SizedBox(height: 12),
                    ...children,
                    const SizedBox(height: 12),
                    Text(
                      'This write runs through a secure Edge Function.',
                      style: Theme.of(sheetContext).textTheme.bodySmall
                          ?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: title,
                      icon: icon,
                      isLoading: isSubmitting,
                      minHeight: 48,
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setSheetState(() => isSubmitting = true);
                              final Result<AdminWriteResultModel> result;

                              try {
                                result = await onSubmit();
                              } catch (_) {
                                if (!sheetContext.mounted) {
                                  return;
                                }

                                setSheetState(() => isSubmitting = false);
                                showModuleSnackBar(
                                  sheetContext,
                                  'Secure admin action failed. Please try again.',
                                );
                                return;
                              }

                              if (!sheetContext.mounted) {
                                return;
                              }

                              if (result case Failure<AdminWriteResultModel>(
                                :final exception,
                              )) {
                                setSheetState(() => isSubmitting = false);
                                showModuleSnackBar(
                                  sheetContext,
                                  exception.message,
                                );
                                return;
                              }

                              if (result case Success<AdminWriteResultModel>(
                                :final data,
                              )) {
                                if (data.success) {
                                  Navigator.of(sheetContext).pop(data.message);
                                } else {
                                  setSheetState(() => isSubmitting = false);
                                  showModuleSnackBar(
                                    sheetContext,
                                    data.message,
                                  );
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  if (successMessage == null) {
    return;
  }

  await WidgetsBinding.instance.endOfFrame;

  if (!context.mounted) {
    return;
  }

  if (scaffoldMessenger?.mounted ?? false) {
    scaffoldMessenger!.showSnackBar(SnackBar(content: Text(successMessage)));
  }

  ref.invalidate(adminAcademicOverviewProvider);
}

class _IdDropdown extends StatelessWidget {
  const _IdDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: [
        for (final item in items.entries)
          DropdownMenuItem<String>(
            value: item.key,
            child: Text(item.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged == null
          ? null
          : (value) {
              if (value != null) {
                onChanged!(value);
              }
            },
    );
  }
}

SubjectSummaryModel? _subjectById(
  AcademicOverviewModel overview,
  String subjectId,
) {
  for (final subject in overview.subjects) {
    if (subject.id == subjectId) {
      return subject;
    }
  }

  return null;
}

BatchSummaryModel? _batchById(AcademicOverviewModel overview, String batchId) {
  for (final batch in overview.batches) {
    if (batch.id == batchId) {
      return batch;
    }
  }

  return null;
}

AdminStudentProfileModel? _studentById(
  AcademicOverviewModel overview,
  String studentId,
) {
  for (final student in overview.students) {
    if (student.id == studentId) {
      return student;
    }
  }

  return null;
}

String _display(String? value, String fallback) {
  final trimmed = value?.trim();

  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }

  return fallback;
}

String _cleanErrorMessage(Object error) {
  final text = error.toString();

  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }

  return text;
}
