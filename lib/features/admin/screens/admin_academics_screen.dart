import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

const _assignmentSteps = [
  'Create department',
  'Create batch',
  'Add semester',
  'Add subject',
  'Assign teacher',
  'Enroll students',
];

class AdminAcademicsScreen extends StatelessWidget {
  const AdminAcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Academic Management',
      subtitle:
          'Departments, batches, semesters, subjects, and assignments preview.',
      fallbackRoute: AppRoutes.admin,
      children: [
        const _AcademicSummaryCard(),
        const _AcademicStructureCard(),
        const _SubjectAssignmentCard(),
        const _AssignmentFlowCard(steps: _assignmentSteps),
        _AcademicQuickActions(
          onAction: () {
            showModuleSnackBar(context, 'Academic setup preview only.');
          },
        ),
      ],
    );
  }
}

class _AcademicSummaryCard extends StatelessWidget {
  const _AcademicSummaryCard();

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
                child: _SummaryStatCard(
                  label: 'Departments',
                  value: '3',
                  icon: Icons.account_tree_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatCard(
                  label: 'Batches',
                  value: '4',
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
                child: _SummaryStatCard(
                  label: 'Semesters',
                  value: '8',
                  icon: Icons.layers_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatCard(
                  label: 'Subjects',
                  value: '12',
                  icon: Icons.menu_book_rounded,
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

class _AcademicStructureCard extends StatelessWidget {
  const _AcademicStructureCard();

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
          ModuleInfoTile(
            title: 'Department: Computer Science',
            subtitle: 'Programs: BSIT, BSSE',
            icon: Icons.account_tree_rounded,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 10),
          ModuleInfoTile(
            title: 'Batch: BSIT 2022',
            subtitle: 'Semester: 8th Semester',
            icon: Icons.groups_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 10),
          ModuleInfoTile(
            title: 'Subject: Database Systems',
            subtitle: 'Code: CS-408',
            icon: Icons.storage_rounded,
            color: colorScheme.tertiary,
          ),
          const SizedBox(height: 10),
          ModuleInfoTile(
            title: 'Teacher: Mr. Ahmad',
            subtitle: 'Assigned to Database Systems',
            icon: Icons.assignment_ind_rounded,
            color: colorScheme.primary,
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

class _SubjectAssignmentCard extends StatelessWidget {
  const _SubjectAssignmentCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  title: 'Subject Assignment',
                  icon: Icons.assignment_turned_in_rounded,
                ),
              ),
              ModuleBadge(
                label: 'Active',
                icon: Icons.check_circle_rounded,
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Database Systems',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: 'Teacher: Mr. Ahmad',
                icon: Icons.co_present_rounded,
                color: colorScheme.primary,
              ),
              ModuleBadge(
                label: 'Department: BSIT',
                icon: Icons.account_tree_rounded,
                color: colorScheme.secondary,
              ),
              ModuleBadge(
                label: 'Batch: 2022',
                icon: Icons.groups_rounded,
                color: colorScheme.tertiary,
              ),
              ModuleBadge(
                label: '8th Semester',
                icon: Icons.school_rounded,
                color: colorScheme.primary,
              ),
              ModuleBadge(
                label: 'Students: 42',
                icon: Icons.people_alt_rounded,
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: 'Active Assignment',
            subtitle: 'Students enrolled: 42',
            icon: Icons.verified_rounded,
            color: colorScheme.secondary,
          ),
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
  const _AcademicQuickActions({required this.onAction});

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
                label: 'Add Department',
                icon: Icons.account_tree_rounded,
                onPressed: onAction,
              ),
              _ActionButton(
                label: 'Add Batch',
                icon: Icons.groups_rounded,
                onPressed: onAction,
              ),
              _ActionButton(
                label: 'Add Subject',
                icon: Icons.menu_book_rounded,
                onPressed: onAction,
              ),
              _ActionButton(
                label: 'Assign Teacher',
                icon: Icons.assignment_ind_rounded,
                onPressed: onAction,
              ),
              _ActionButton(
                label: 'Enroll Students',
                icon: Icons.how_to_reg_rounded,
                onPressed: onAction,
              ),
            ],
          ),
        ],
      ),
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
