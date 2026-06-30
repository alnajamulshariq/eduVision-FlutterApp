import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/data/models/admin_management_model.dart';
import 'package:eduvision_app/data/models/department_model.dart';
import 'package:eduvision_app/data/models/semester_model.dart';
import 'package:eduvision_app/features/admin/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _roles = ['Student', 'Teacher', 'Admin'];
const _fallbackDepartments = ['Manual setup'];
const _fallbackBatches = ['Manual setup'];
const _fallbackSemesters = ['Manual setup'];

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _profileIdController = TextEditingController();
  final _parentEmailController = TextEditingController();
  String _role = _roles.first;
  String _department = _fallbackDepartments.first;
  String _batch = _fallbackBatches.first;
  String _semester = _fallbackSemesters.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _profileIdController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  void _showCreateHint(String role) {
    setState(() => _role = role);
    showModuleSnackBar(
      context,
      'Use the Create User form below to create a ${role.toLowerCase()} account.',
    );
  }

  Future<void> _createUser(AcademicOverviewModel? academicOverview) async {
    if (_isSubmitting) {
      return;
    }

    final role = _role.toLowerCase();
    final departmentOptions = _departmentOptions(academicOverview);
    final safeDepartments = departmentOptions.isEmpty
        ? _fallbackDepartments
        : departmentOptions;
    final selectedDepartment = _safeSelection(safeDepartments, _department);
    final department = _findDepartment(academicOverview, selectedDepartment);
    final batchOptions = _batchOptions(academicOverview, department?.id);
    final safeBatches = batchOptions.isEmpty ? _fallbackBatches : batchOptions;
    final selectedBatch = _safeSelection(safeBatches, _batch);
    final batch = _findBatch(
      academicOverview,
      selectedBatch,
      departmentId: department?.id,
    );
    final semesterOptions = _semesterOptions(academicOverview);
    final safeSemesters = semesterOptions.isEmpty
        ? _fallbackSemesters
        : semesterOptions;
    final selectedSemester = _safeSelection(safeSemesters, _semester);
    final semester = _findSemester(academicOverview, selectedSemester);
    final profileId = _profileIdController.text.trim();

    final validation = _validateCreateUserForm(
      role: role,
      name: _nameController.text,
      email: _emailController.text,
      temporaryPassword: _passwordController.text,
      departmentId: department?.id,
      batchId: batch?.id,
      semesterId: semester?.id,
      profileId: profileId,
    );

    if (validation != null) {
      showModuleSnackBar(context, validation);
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(adminRepositoryProvider)
        .createUserAccount(
          request: AdminCreateUserRequestModel(
            name: _nameController.text,
            universityEmail: _emailController.text,
            role: role,
            temporaryPassword: _passwordController.text,
            rollNo: role == 'student' ? profileId : null,
            employeeId: role == 'teacher' ? profileId : null,
            departmentId: role == 'student' || role == 'teacher'
                ? department?.id
                : null,
            batchId: role == 'student' ? batch?.id : null,
            semesterId: role == 'student' ? semester?.id : null,
            parentEmail: role == 'student' ? _parentEmailController.text : null,
          ),
        );

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);

    if (result case Failure<AdminWriteResultModel>(:final exception)) {
      showModuleSnackBar(context, exception.message);
      return;
    }

    if (result case Success<AdminWriteResultModel>(:final data)) {
      showModuleSnackBar(context, data.message);

      if (data.success) {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _profileIdController.clear();
        _parentEmailController.clear();
        ref.invalidate(adminUsersOverviewProvider);
        ref.invalidate(adminAcademicOverviewProvider);
      }
    }
  }

  Future<void> _showResetPasswordDialog(
    List<AdminUserProfileModel> users,
  ) async {
    if (users.isEmpty) {
      showModuleSnackBar(context, 'No users are available for password reset.');
      return;
    }

    final passwordController = TextEditingController();
    var selectedUserId = users.first.id;
    var isSubmitting = false;

    final successMessage = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      requestFocus: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final colorScheme = Theme.of(sheetContext).colorScheme;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'Reset Password',
                      icon: Icons.lock_reset_rounded,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedUserId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'User',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      items: [
                        for (final user in users)
                          DropdownMenuItem<String>(
                            value: user.id,
                            child: Text(
                              '${user.name} - ${user.universityEmail}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setSheetState(() => selectedUserId = value);
                              }
                            },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Temporary Password',
                        prefixIcon: Icon(Icons.password_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Password reset runs through a secure Edge Function.',
                      style: Theme.of(sheetContext).textTheme.bodySmall
                          ?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: 'Set Temporary Password',
                      icon: Icons.lock_reset_rounded,
                      isLoading: isSubmitting,
                      minHeight: 48,
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (passwordController.text.length < 6) {
                                showModuleSnackBar(
                                  sheetContext,
                                  'Temporary password must be at least 6 characters.',
                                );
                                return;
                              }

                              setSheetState(() => isSubmitting = true);
                              final result = await ref
                                  .read(adminRepositoryProvider)
                                  .resetUserPassword(
                                    request: AdminResetPasswordRequestModel(
                                      userId: selectedUserId,
                                      temporaryPassword:
                                          passwordController.text,
                                    ),
                                  );

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
            );
          },
        );
      },
    );

    passwordController.dispose();

    if (!mounted || successMessage == null) {
      return;
    }

    ref.invalidate(adminUsersOverviewProvider);
    showModuleSnackBar(context, successMessage);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersOverviewProvider);
    final academicAsync = ref.watch(adminAcademicOverviewProvider);
    final academicOverview = academicAsync.maybeWhen(
      data: (overview) => overview,
      orElse: () => null,
    );
    final departmentOptions = _departmentOptions(academicOverview);
    final safeDepartments = departmentOptions.isEmpty
        ? _fallbackDepartments
        : departmentOptions;
    final selectedDepartment = _safeSelection(safeDepartments, _department);
    final selectedDepartmentModel = _findDepartment(
      academicOverview,
      selectedDepartment,
    );
    final batchOptions = _batchOptions(
      academicOverview,
      selectedDepartmentModel?.id,
    );
    final safeBatches = batchOptions.isEmpty ? _fallbackBatches : batchOptions;
    final semesterOptions = _semesterOptions(academicOverview);
    final safeSemesters = semesterOptions.isEmpty
        ? _fallbackSemesters
        : semesterOptions;
    final selectedBatch = _safeSelection(safeBatches, _batch);
    final selectedSemester = _safeSelection(safeSemesters, _semester);

    return ModuleScreenShell(
      title: 'User Management',
      subtitle: 'View users and linked student or teacher profiles.',
      fallbackRoute: AppRoutes.admin,
      children: [
        ...usersAsync.when(
          loading: () => const <Widget>[
            _UsersLoadingPanel(),
            _UserSecurityNotice(),
          ],
          error: (error, _) => <Widget>[
            _UsersErrorPanel(message: _cleanErrorMessage(error)),
            const _UserSecurityNotice(),
          ],
          data: (overview) => <Widget>[
            _UserSummaryCard(overview: overview),
            _QuickActionsCard(
              onCreateRole: _showCreateHint,
              onResetPassword: () => _showResetPasswordDialog(overview.users),
            ),
            _AddUserPreviewForm(
              nameController: _nameController,
              emailController: _emailController,
              passwordController: _passwordController,
              profileIdController: _profileIdController,
              parentEmailController: _parentEmailController,
              role: _role,
              department: selectedDepartment,
              batch: selectedBatch,
              semester: selectedSemester,
              departmentOptions: safeDepartments,
              batchOptions: safeBatches,
              semesterOptions: safeSemesters,
              isSubmitting: _isSubmitting,
              onRoleChanged: (value) => setState(() => _role = value),
              onDepartmentChanged: (value) {
                final department = _findDepartment(academicOverview, value);
                final nextBatch =
                    _firstBatchNameForDepartment(
                      academicOverview,
                      department?.id,
                    ) ??
                    _fallbackBatches.first;

                setState(() {
                  _department = value;
                  _batch = nextBatch;
                });
              },
              onBatchChanged: (value) => setState(() => _batch = value),
              onSemesterChanged: (value) => setState(() => _semester = value),
              onCreateUser: () => _createUser(academicOverview),
            ),
            _RecentUsersList(users: overview.users),
          ],
        ),
      ],
    );
  }
}

class _UserSummaryCard extends StatelessWidget {
  const _UserSummaryCard({required this.overview});

  final AdminUsersOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final counts = _UserSummaryCounts.fromUsers(overview.users);

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'User Summary',
            icon: Icons.people_alt_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Students',
                  value: counts.students.toString(),
                  icon: Icons.school_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Teachers',
                  value: counts.teachers.toString(),
                  icon: Icons.co_present_rounded,
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
                  label: 'Admins',
                  value: counts.admins.toString(),
                  icon: Icons.admin_panel_settings_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Active',
                  value: counts.active.toString(),
                  icon: Icons.verified_user_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onCreateRole,
    required this.onResetPassword,
  });

  final ValueChanged<String> onCreateRole;
  final VoidCallback onResetPassword;

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
                label: 'Add Student',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () => onCreateRole('Student'),
              ),
              _ActionButton(
                label: 'Add Teacher',
                icon: Icons.co_present_rounded,
                onPressed: () => onCreateRole('Teacher'),
              ),
              _ActionButton(
                label: 'Add Admin',
                icon: Icons.admin_panel_settings_rounded,
                onPressed: () => onCreateRole('Admin'),
              ),
              _ActionButton(
                label: 'Reset Password',
                icon: Icons.lock_reset_rounded,
                onPressed: onResetPassword,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _UserSecurityNotice(),
        ],
      ),
    );
  }
}

class _AddUserPreviewForm extends StatelessWidget {
  const _AddUserPreviewForm({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.profileIdController,
    required this.parentEmailController,
    required this.role,
    required this.department,
    required this.batch,
    required this.semester,
    required this.departmentOptions,
    required this.batchOptions,
    required this.semesterOptions,
    required this.isSubmitting,
    required this.onRoleChanged,
    required this.onDepartmentChanged,
    required this.onBatchChanged,
    required this.onSemesterChanged,
    required this.onCreateUser,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController profileIdController;
  final TextEditingController parentEmailController;
  final String role;
  final String department;
  final String batch;
  final String semester;
  final List<String> departmentOptions;
  final List<String> batchOptions;
  final List<String> semesterOptions;
  final bool isSubmitting;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onBatchChanged;
  final ValueChanged<String> onSemesterChanged;
  final VoidCallback onCreateUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedRole = role.toLowerCase();
    final needsProfileId =
        normalizedRole == 'student' || normalizedRole == 'teacher';
    final profileLabel = normalizedRole == 'teacher'
        ? 'Employee ID'
        : 'Roll Number';

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Create User Plan',
            icon: Icons.manage_accounts_rounded,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'University Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Temporary Password',
              prefixIcon: Icon(Icons.password_rounded),
            ),
          ),
          const SizedBox(height: 10),
          _DropdownTile(
            label: 'Role',
            icon: Icons.badge_rounded,
            value: role,
            values: _roles,
            onChanged: onRoleChanged,
          ),
          if (needsProfileId) ...[
            const SizedBox(height: 10),
            TextField(
              controller: profileIdController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: profileLabel,
                prefixIcon: const Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 10),
            _DropdownTile(
              label: 'Department',
              icon: Icons.account_tree_rounded,
              value: department,
              values: departmentOptions,
              onChanged: onDepartmentChanged,
            ),
          ],
          if (normalizedRole == 'student') ...[
            const SizedBox(height: 10),
            _DropdownTile(
              label: 'Batch',
              icon: Icons.groups_rounded,
              value: batch,
              values: batchOptions,
              onChanged: onBatchChanged,
            ),
            const SizedBox(height: 10),
            _DropdownTile(
              label: 'Semester',
              icon: Icons.layers_rounded,
              value: semester,
              values: semesterOptions,
              onChanged: onSemesterChanged,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: parentEmailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Parent Email',
                prefixIcon: Icon(Icons.contact_mail_rounded),
              ),
            ),
          ],
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Create User',
            icon: Icons.person_add_rounded,
            isLoading: isSubmitting,
            minHeight: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onPressed: isSubmitting ? null : onCreateUser,
          ),
          const SizedBox(height: 10),
          Text(
            'Auth user creation runs through a secure Edge Function.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentUsersList extends StatelessWidget {
  const _RecentUsersList({required this.users});

  final List<AdminUserProfileModel> users;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Backend Users',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 12),
          if (users.isEmpty)
            const _EmptyUsersTile()
          else
            for (final user in users) ...[
              _RecentUserCard(user: user),
              if (user != users.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _RecentUserCard extends StatelessWidget {
  const _RecentUserCard({required this.user});

  final AdminUserProfileModel user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final roleColor = switch (user.normalizedRole) {
      'student' => colorScheme.secondary,
      'teacher' => colorScheme.primary,
      _ => colorScheme.tertiary,
    };
    final roleIcon = switch (user.normalizedRole) {
      'student' => Icons.school_rounded,
      'teacher' => Icons.co_present_rounded,
      _ => Icons.admin_panel_settings_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(roleIcon, color: roleColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.universityEmail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_display(user.idLabel, 'ID')}: ${_display(user.idValue, user.id)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _profileSubtitle(user),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: user.roleLabel,
                icon: roleIcon,
                color: roleColor,
              ),
              ModuleBadge(
                label: user.statusLabel,
                icon: user.isActive
                    ? Icons.check_circle_rounded
                    : Icons.block_rounded,
                color: user.isActive
                    ? colorScheme.secondary
                    : colorScheme.error,
              ),
              ModuleBadge(
                label: user.passwordChangedOnce
                    ? 'Password Changed'
                    : 'First Login',
                icon: user.passwordChangedOnce
                    ? Icons.lock_open_rounded
                    : Icons.lock_clock_rounded,
                color: user.passwordChangedOnce
                    ? colorScheme.secondary
                    : colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showUserDetails(context, user),
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserSummaryCounts {
  const _UserSummaryCounts({
    required this.students,
    required this.teachers,
    required this.admins,
    required this.active,
  });

  final int students;
  final int teachers;
  final int admins;
  final int active;

  factory _UserSummaryCounts.fromUsers(List<AdminUserProfileModel> users) {
    return _UserSummaryCounts(
      students: users.where((user) => user.normalizedRole == 'student').length,
      teachers: users.where((user) => user.normalizedRole == 'teacher').length,
      admins: users.where((user) => user.normalizedRole == 'admin').length,
      active: users.where((user) => user.isActive).length,
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: [
        for (final item in values)
          DropdownMenuItem<String>(value: item, child: Text(item)),
      ],
      onChanged: (nextValue) {
        if (nextValue != null) {
          onChanged(nextValue);
        }
      },
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

class _UsersLoadingPanel extends StatelessWidget {
  const _UsersLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading users',
        subtitle: 'Fetching app users and linked profiles from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _UsersErrorPanel extends StatelessWidget {
  const _UsersErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load users',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
      ),
    );
  }
}

class _EmptyUsersTile extends StatelessWidget {
  const _EmptyUsersTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModuleInfoTile(
      title: 'No users found',
      subtitle:
          'Create Supabase Auth users and profile rows to list them here.',
      icon: Icons.info_outline_rounded,
      color: colorScheme.tertiary,
    );
  }
}

class _UserSecurityNotice extends StatelessWidget {
  const _UserSecurityNotice();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModuleInfoTile(
      title: 'Auth account creation is pending secure backend work',
      subtitle:
          'Supabase Auth users and password resets should be handled by an Edge Function or Admin API, not by the Flutter anon client.',
      icon: Icons.security_rounded,
      color: colorScheme.tertiary,
    );
  }
}

String _safeSelection(List<String> values, String currentValue) {
  if (values.contains(currentValue)) {
    return currentValue;
  }

  return values.first;
}

String _profileSubtitle(AdminUserProfileModel user) {
  final pieces = [
    if (user.departmentName != null) user.departmentName!,
    if (user.batchName != null) user.batchName!,
    if (user.semesterName != null) user.semesterName!,
  ];

  if (pieces.isEmpty) {
    return user.linkedRecordId == null ? 'No linked profile record' : 'Linked';
  }

  return pieces.join(' - ');
}

void _showUserDetails(BuildContext context, AdminUserProfileModel user) {
  final colorScheme = Theme.of(context).colorScheme;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    requestFocus: false,
    backgroundColor: colorScheme.surface,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: user.name, icon: Icons.person_rounded),
              const SizedBox(height: 12),
              _DetailRow(label: 'Email', value: user.universityEmail),
              _DetailRow(label: 'Role', value: user.roleLabel),
              _DetailRow(
                label: _display(user.idLabel, 'ID'),
                value: _display(user.idValue, user.id),
              ),
              _DetailRow(label: 'Status', value: user.statusLabel),
              _DetailRow(
                label: 'Password State',
                value: user.passwordChangedOnce
                    ? 'Password changed'
                    : 'First login pending',
              ),
              _DetailRow(
                label: 'Department',
                value: _display(user.departmentName, 'Not linked'),
              ),
              if (user.batchName != null)
                _DetailRow(label: 'Batch', value: user.batchName!),
              if (user.semesterName != null)
                _DetailRow(label: 'Semester', value: user.semesterName!),
              _DetailRow(
                label: 'Linked Profile',
                value: _display(user.linkedRecordId, 'No linked profile'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
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

String _display(String? value, String fallback) {
  final trimmed = value?.trim();

  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }

  return fallback;
}

String? _validateCreateUserForm({
  required String role,
  required String name,
  required String email,
  required String temporaryPassword,
  required String? departmentId,
  required String? batchId,
  required String? semesterId,
  required String profileId,
}) {
  if (name.trim().isEmpty || email.trim().isEmpty) {
    return 'Enter the full name and university email.';
  }

  if (temporaryPassword.length < 6) {
    return 'Temporary password must be at least 6 characters.';
  }

  if (role != 'student' && role != 'teacher' && role != 'admin') {
    return 'Choose a valid user role.';
  }

  if (role != 'admin' && (departmentId == null || departmentId.isEmpty)) {
    return 'Choose a department for this user.';
  }

  if (role == 'student') {
    if (profileId.isEmpty) {
      return 'Enter the student roll number.';
    }

    if (batchId == null || batchId.isEmpty) {
      return 'Choose a batch for this student.';
    }

    if (semesterId == null || semesterId.isEmpty) {
      return 'Choose a semester for this student.';
    }
  }

  if (role == 'teacher' && profileId.isEmpty) {
    return 'Enter the teacher employee ID.';
  }

  return null;
}

DepartmentModel? _findDepartment(AcademicOverviewModel? overview, String name) {
  if (overview == null) {
    return null;
  }

  for (final department in overview.departments) {
    if (department.name == name) {
      return department;
    }
  }

  return null;
}

BatchSummaryModel? _findBatch(
  AcademicOverviewModel? overview,
  String name, {
  String? departmentId,
}) {
  if (overview == null) {
    return null;
  }

  for (final batch in overview.batches) {
    if (batch.name == name &&
        (departmentId == null || batch.departmentId == departmentId)) {
      return batch;
    }
  }

  return null;
}

SemesterModel? _findSemester(AcademicOverviewModel? overview, String name) {
  if (overview == null) {
    return null;
  }

  for (final semester in overview.semesters) {
    if (semester.name == name) {
      return semester;
    }
  }

  return null;
}

List<String> _departmentOptions(AcademicOverviewModel? overview) {
  if (overview == null) {
    return _fallbackDepartments;
  }

  return overview.departments
      .map((department) => department.name)
      .where((name) => name.trim().isNotEmpty)
      .toList(growable: false);
}

List<String> _batchOptions(
  AcademicOverviewModel? overview,
  String? departmentId,
) {
  if (overview == null || departmentId == null) {
    return _fallbackBatches;
  }

  return overview.batches
      .where((batch) => batch.departmentId == departmentId)
      .map((batch) => batch.name)
      .where((name) => name.trim().isNotEmpty)
      .toList(growable: false);
}

List<String> _semesterOptions(AcademicOverviewModel? overview) {
  if (overview == null) {
    return _fallbackSemesters;
  }

  return overview.semesters
      .map((semester) => semester.name)
      .where((name) => name.trim().isNotEmpty)
      .toList(growable: false);
}

String? _firstBatchNameForDepartment(
  AcademicOverviewModel? overview,
  String? departmentId,
) {
  if (overview == null || departmentId == null) {
    return null;
  }

  for (final batch in overview.batches) {
    if (batch.departmentId == departmentId) {
      return batch.name;
    }
  }

  return null;
}

String _cleanErrorMessage(Object error) {
  final text = error.toString();

  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }

  return text;
}
