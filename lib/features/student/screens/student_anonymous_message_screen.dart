import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

const _teacherOptions = [
  _TeacherOption(name: 'Mr. Ahmad', subject: 'Database Systems'),
  _TeacherOption(name: 'Ms. Sara', subject: 'Web Engineering'),
  _TeacherOption(name: 'Mr. Bilal', subject: 'Artificial Intelligence'),
];

const _suggestions = [
  _MessageSuggestion(
    label: 'Lecture was difficult',
    text: 'Sir, Lecture 4 was difficult to understand.',
  ),
  _MessageSuggestion(
    label: 'Need more practice',
    text: 'Please provide additional practice exercises.',
  ),
  _MessageSuggestion(
    label: 'Classroom issue',
    text: 'The classroom projector is not working properly.',
  ),
  _MessageSuggestion(
    label: 'Request extra material',
    text: 'Please share extra material for revision.',
  ),
];

class StudentAnonymousMessageScreen extends StatefulWidget {
  const StudentAnonymousMessageScreen({super.key});

  @override
  State<StudentAnonymousMessageScreen> createState() =>
      _StudentAnonymousMessageScreenState();
}

class _StudentAnonymousMessageScreenState
    extends State<StudentAnonymousMessageScreen> {
  final _messageController = TextEditingController();
  int _selectedTeacherIndex = 0;
  bool _submitted = false;

  _TeacherOption get _selectedTeacher => _teacherOptions[_selectedTeacherIndex];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _selectTeacher(int index) {
    setState(() {
      _selectedTeacherIndex = index;
      _submitted = false;
    });
  }

  void _applySuggestion(String text) {
    final current = _messageController.text.trim();
    final next = current.isEmpty ? text : '$current\n$text';
    _messageController.text = next;
    _messageController.selection = TextSelection.collapsed(
      offset: _messageController.text.length,
    );
    setState(() => _submitted = false);
  }

  void _submitMessage() {
    if (_messageController.text.trim().isEmpty) {
      showModuleSnackBar(context, 'Please write a message first.');
      return;
    }

    setState(() => _submitted = true);
    showModuleSnackBar(context, 'Anonymous message preview submitted.');
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Anonymous Message',
      subtitle: 'Send academic feedback safely.',
      fallbackRoute: AppRoutes.student,
      children: [
        const _PrivacyStatusCard(),
        _TeacherSelector(
          teachers: _teacherOptions,
          selectedIndex: _selectedTeacherIndex,
          onSelected: _selectTeacher,
        ),
        _MessageComposer(
          controller: _messageController,
          suggestions: _suggestions,
          selectedTeacher: _selectedTeacher,
          submitted: _submitted,
          onSuggestionTap: _applySuggestion,
          onSubmit: _submitMessage,
        ),
        const _PrivacyNoteCard(),
      ],
    );
  }
}

class _PrivacyStatusCard extends StatelessWidget {
  const _PrivacyStatusCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  title: 'Privacy Status',
                  icon: Icons.privacy_tip_rounded,
                ),
              ),
              ModuleBadge(
                label: 'Safe Channel',
                icon: Icons.shield_rounded,
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: 'Identity',
            subtitle: 'Hidden from Teacher',
            icon: Icons.visibility_off_rounded,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: 'Admin Review',
            subtitle: 'Only if reported',
            icon: Icons.admin_panel_settings_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: 'Message Type',
            subtitle: 'Academic Feedback',
            icon: Icons.school_rounded,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _TeacherSelector extends StatelessWidget {
  const _TeacherSelector({
    required this.teachers,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_TeacherOption> teachers;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Teacher Selector',
            icon: Icons.person_search_rounded,
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < teachers.length; index++) ...[
            _TeacherOptionTile(
              teacher: teachers[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
            if (index != teachers.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _TeacherOptionTile extends StatelessWidget {
  const _TeacherOptionTile({
    required this.teacher,
    required this.selected,
    required this.onTap,
  });

  final _TeacherOption teacher;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: (selected ? colorScheme.primary : colorScheme.surface)
                .withValues(alpha: selected ? 0.12 : 0.34),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (selected ? colorScheme.primary : colorScheme.outline)
                  .withValues(alpha: selected ? 0.78 : 0.38),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (selected ? colorScheme.primary : colorScheme.surface)
                      .withValues(alpha: selected ? 0.16 : 0.48),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        (selected ? colorScheme.primary : colorScheme.outline)
                            .withValues(alpha: 0.42),
                  ),
                ),
                child: Icon(
                  Icons.co_present_rounded,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: textTheme.titleSmall?.copyWith(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      teacher.subject,
                      softWrap: true,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.suggestions,
    required this.selectedTeacher,
    required this.submitted,
    required this.onSuggestionTap,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final List<_MessageSuggestion> suggestions;
  final _TeacherOption selectedTeacher;
  final bool submitted;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Message Composer',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 5,
            minLines: 4,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.35,
            ),
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Write your academic concern or feedback...',
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.forum_rounded, color: colorScheme.primary),
              filled: true,
              fillColor: colorScheme.surface.withValues(alpha: 0.42),
              contentPadding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.46),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quick suggestions',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in suggestions)
                ActionChip(
                  avatar: Icon(
                    Icons.add_comment_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  label: Text(suggestion.label),
                  onPressed: () => onSuggestionTap(suggestion.text),
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.52),
                  ),
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Submit Anonymous Message',
            icon: Icons.send_rounded,
            minHeight: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onPressed: onSubmit,
          ),
          if (submitted) ...[
            const SizedBox(height: 12),
            _SubmissionPreviewCard(teacher: selectedTeacher),
          ],
        ],
      ),
    );
  }
}

class _SubmissionPreviewCard extends StatelessWidget {
  const _SubmissionPreviewCard({required this.teacher});

  final _TeacherOption teacher;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleInfoTile(
            title: 'Message submitted anonymously.',
            subtitle: 'Teacher: ${teacher.name}',
            icon: Icons.check_circle_rounded,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: 'Status: Pending Review',
                icon: Icons.hourglass_top_rounded,
                color: colorScheme.tertiary,
              ),
              ModuleBadge(
                label: 'Identity: Hidden',
                icon: Icons.visibility_off_rounded,
                color: colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyNoteCard extends StatelessWidget {
  const _PrivacyNoteCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your identity remains hidden from teachers. Admin may review '
              'reported messages only when required for safety or discipline.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
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

class _TeacherOption {
  const _TeacherOption({required this.name, required this.subject});

  final String name;
  final String subject;
}

class _MessageSuggestion {
  const _MessageSuggestion({required this.label, required this.text});

  final String label;
  final String text;
}
