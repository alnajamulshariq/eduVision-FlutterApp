import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

const _roles = ['Student', 'Teacher', 'Admin'];
const _departments = ['BSIT', 'BSSE', 'BBA'];
const _batches = ['2022', '2023', '2024'];

const _recentUsers = [
  _RecentUser(
    name: 'Ali Khan',
    idLabel: 'Roll No',
    idValue: 'BSIT-2022-001',
    role: 'Student',
    department: 'BSIT',
    status: 'Active',
  ),
  _RecentUser(
    name: 'Sara Ahmed',
    idLabel: 'Roll No',
    idValue: 'BSIT-2022-002',
    role: 'Student',
    department: 'BSIT',
    status: 'Active',
  ),
  _RecentUser(
    name: 'Mr. Ahmad',
    idLabel: 'Employee ID',
    idValue: 'TCH-001',
    role: 'Teacher',
    department: 'Computer Science',
    status: 'Active',
  ),
  _RecentUser(
    name: 'Admin User',
    idLabel: 'Employee ID',
    idValue: 'ADM-001',
    role: 'Admin',
    department: 'Administration',
    status: 'Active',
  ),
];

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = _roles.first;
  String _department = _departments.first;
  String _batch = _batches.first;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showPreviewAction() {
    showModuleSnackBar(context, 'Preview action only.');
  }

  void _showCreatePreview() {
    showModuleSnackBar(context, 'User creation preview only.');
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'User Management',
      subtitle: 'Manage students, teachers, and admin accounts preview.',
      fallbackRoute: AppRoutes.admin,
      children: [
        const _UserSummaryCard(),
        _QuickActionsCard(onAction: _showPreviewAction),
        _AddUserPreviewForm(
          nameController: _nameController,
          emailController: _emailController,
          role: _role,
          department: _department,
          batch: _batch,
          onRoleChanged: (value) => setState(() => _role = value),
          onDepartmentChanged: (value) => setState(() => _department = value),
          onBatchChanged: (value) => setState(() => _batch = value),
          onCreatePreview: _showCreatePreview,
        ),
        const _RecentUsersList(users: _recentUsers),
      ],
    );
  }
}

class _UserSummaryCard extends StatelessWidget {
  const _UserSummaryCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                child: _SummaryStatCard(
                  label: 'Students',
                  value: '120',
                  icon: Icons.school_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatCard(
                  label: 'Teachers',
                  value: '18',
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
                child: _SummaryStatCard(
                  label: 'Admins',
                  value: '2',
                  icon: Icons.admin_panel_settings_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatCard(
                  label: 'Active',
                  value: '140',
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
  const _QuickActionsCard({required this.onAction});

  final VoidCallback onAction;

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
                onPressed: onAction,
              ),
              _ActionButton(
                label: 'Add Teacher',
                icon: Icons.co_present_rounded,
                onPressed: onAction,
              ),
              _ActionButton(
                label: 'Add Admin',
                icon: Icons.admin_panel_settings_rounded,
                onPressed: onAction,
              ),
              _ActionButton(
                label: 'Reset Password',
                icon: Icons.lock_reset_rounded,
                onPressed: onAction,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            softWrap: true,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddUserPreviewForm extends StatelessWidget {
  const _AddUserPreviewForm({
    required this.nameController,
    required this.emailController,
    required this.role,
    required this.department,
    required this.batch,
    required this.onRoleChanged,
    required this.onDepartmentChanged,
    required this.onBatchChanged,
    required this.onCreatePreview,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final String role;
  final String department;
  final String batch;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onBatchChanged;
  final VoidCallback onCreatePreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Create User Preview',
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
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
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
          const SizedBox(height: 10),
          _DropdownTile(
            label: 'Department',
            icon: Icons.account_tree_rounded,
            value: department,
            values: _departments,
            onChanged: onDepartmentChanged,
          ),
          const SizedBox(height: 10),
          _DropdownTile(
            label: 'Batch',
            icon: Icons.groups_rounded,
            value: batch,
            values: _batches,
            onChanged: onBatchChanged,
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Create User Preview',
            icon: Icons.person_add_rounded,
            minHeight: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onPressed: onCreatePreview,
          ),
          const SizedBox(height: 10),
          Text(
            'Preview only. No account is saved and no authentication is changed.',
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

  final List<_RecentUser> users;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Recent Users',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 12),
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

  final _RecentUser user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final roleColor = switch (user.role) {
      'Student' => colorScheme.secondary,
      'Teacher' => colorScheme.primary,
      _ => colorScheme.tertiary,
    };
    final roleIcon = switch (user.role) {
      'Student' => Icons.school_rounded,
      'Teacher' => Icons.co_present_rounded,
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
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.idLabel}: ${user.idValue}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Department: ${user.department}',
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
              ModuleBadge(label: user.role, icon: roleIcon, color: roleColor),
              ModuleBadge(
                label: user.status,
                icon: Icons.check_circle_rounded,
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showModuleSnackBar(context, 'User details preview only.');
              },
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: const Text('View'),
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

class _RecentUser {
  const _RecentUser({
    required this.name,
    required this.idLabel,
    required this.idValue,
    required this.role,
    required this.department,
    required this.status,
  });

  final String name;
  final String idLabel;
  final String idValue;
  final String role;
  final String department;
  final String status;
}
