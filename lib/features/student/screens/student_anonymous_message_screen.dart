import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class StudentAnonymousMessageScreen extends StatefulWidget {
  const StudentAnonymousMessageScreen({super.key});

  @override
  State<StudentAnonymousMessageScreen> createState() =>
      _StudentAnonymousMessageScreenState();
}

class _StudentAnonymousMessageScreenState
    extends State<StudentAnonymousMessageScreen> {
  final _messageController = TextEditingController();
  String _selectedTeacher = 'Mr. Ahmad';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModuleScreenShell(
      title: 'Anonymous Message',
      subtitle: 'Send academic feedback safely.',
      fallbackRoute: AppRoutes.student,
      children: [
        ModulePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedTeacher,
                decoration: const InputDecoration(
                  labelText: 'Teacher',
                  prefixIcon: Icon(Icons.person_search_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Mr. Ahmad',
                    child: Text('Mr. Ahmad'),
                  ),
                  DropdownMenuItem(value: 'Ms. Sara', child: Text('Ms. Sara')),
                  DropdownMenuItem(
                    value: 'Mr. Bilal',
                    child: Text('Mr. Bilal'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTeacher = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 5,
                minLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Write your academic feedback...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Submit Preview',
                icon: Icons.send_rounded,
                minHeight: 50,
                onPressed: () {
                  showModuleSnackBar(context, 'Message preview submitted.');
                },
              ),
            ],
          ),
        ),
        ModulePanel(
          child: ModuleInfoTile(
            title: 'Privacy Note',
            subtitle:
                'Your identity remains hidden from teachers. Admin may review '
                'reported messages only when required.',
            icon: Icons.privacy_tip_rounded,
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
