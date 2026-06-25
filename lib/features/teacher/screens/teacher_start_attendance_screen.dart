import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/data/models/attendance_session_model.dart';
import 'package:eduvision_app/data/models/timetable_model.dart';
import 'package:eduvision_app/features/teacher/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum AttendanceDemoStatus { idle, validating, scanning, calculating, completed }

class TeacherStartAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherStartAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherStartAttendanceScreen> createState() =>
      _TeacherStartAttendanceScreenState();
}

class _TeacherStartAttendanceScreenState
    extends ConsumerState<TeacherStartAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  AttendanceDemoStatus _status = AttendanceDemoStatus.idle;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _startDemoSession(TimetableModel activeClass) async {
    if (_status != AttendanceDemoStatus.idle) {
      return;
    }

    await _setDemoState(AttendanceDemoStatus.validating);

    final now = DateTime.now();
    final session = AttendanceSessionModel(
      id: '',
      teacherId: activeClass.teacherId,
      subjectId: activeClass.subjectId,
      departmentId: activeClass.departmentId,
      batchId: activeClass.batchId,
      semesterId: activeClass.semesterId,
      date: DateTime(now.year, now.month, now.day),
      startTime: activeClass.startTime,
      endTime: activeClass.endTime,
      status: 'active',
    );

    final sessionResult = await ref
        .read(teacherAttendanceRepositoryProvider)
        .createAttendanceSession(session: session);

    if (_disposed) {
      return;
    }

    if (sessionResult case Failure<AttendanceSessionModel>(:final exception)) {
      await _setDemoState(AttendanceDemoStatus.idle);
      _showSnackBar(exception.message);
      return;
    }

    if (sessionResult case Success<AttendanceSessionModel>(:final data)) {
      _showSnackBar('Attendance session created successfully.');

      final recordResult = await ref
          .read(teacherAttendanceRepositoryProvider)
          .saveDemoAttendanceRecordForSession(session: data);

      if (_disposed) {
        return;
      }

      if (recordResult case Failure<void>(:final exception)) {
        await _setDemoState(AttendanceDemoStatus.idle);
        _showSnackBar(exception.message);
        return;
      }

      _showSnackBar('Attendance record saved successfully.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_disposed) {
      return;
    }

    _scanController.repeat(reverse: true);
    await _setDemoState(AttendanceDemoStatus.scanning);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (_disposed) {
      return;
    }

    _scanController.stop();
    await _setDemoState(AttendanceDemoStatus.calculating);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (_disposed) {
      return;
    }

    await _setDemoState(AttendanceDemoStatus.completed);
  }

  Future<void> _setDemoState(AttendanceDemoStatus status) async {
    if (!mounted) {
      return;
    }
    setState(() => _status = status);
  }

  void _restartDemo() {
    _scanController.stop();
    _scanController.value = 0;
    setState(() => _status = AttendanceDemoStatus.idle);
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final inProgress =
        _status == AttendanceDemoStatus.validating ||
        _status == AttendanceDemoStatus.scanning ||
        _status == AttendanceDemoStatus.calculating;

    final activeClassAsync = ref.watch(teacherActiveClassProvider);
    final activeClass = activeClassAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final canStartAttendance = activeClass != null;

    return ModuleScreenShell(
      title: 'Start Attendance',
      subtitle: 'Face recognition and dynamic QR attendance preview.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        _ActiveClassCard(activeClassAsync: activeClassAsync),
        ModulePanel(
          padding: const EdgeInsets.all(14),
          child: PrimaryButton(
            label: _primaryButtonLabel(
              isCheckingTimetable: activeClassAsync.isLoading,
              hasTimetableError: activeClassAsync.hasError,
              canStartAttendance: canStartAttendance,
            ),
            icon: _status == AttendanceDemoStatus.completed
                ? Icons.check_circle_rounded
                : _status == AttendanceDemoStatus.idle && !canStartAttendance
                ? Icons.lock_clock_rounded
                : Icons.play_arrow_rounded,
            minHeight: 50,
            isLoading: inProgress || activeClassAsync.isLoading,
            onPressed:
                _status == AttendanceDemoStatus.idle && activeClass != null
                ? () => _startDemoSession(activeClass)
                : null,
          ),
        ),
        _ProcessTimeline(status: _status),
        _FaceRecognitionPreview(
          status: _status,
          scanAnimation: _scanController,
        ),
        if (_status == AttendanceDemoStatus.completed) ...[
          const _AttendanceSummaryCard(),
          const _AttendanceResultsPanel(),
          ModulePanel(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restartDemo,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Restart Demo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'View QR Scanner',
                    icon: Icons.qr_code_scanner_rounded,
                    minHeight: 46,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    onPressed: () => context.push(AppRoutes.teacherQrScanner),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _primaryButtonLabel({
    required bool isCheckingTimetable,
    required bool hasTimetableError,
    required bool canStartAttendance,
  }) {
    if (_status == AttendanceDemoStatus.idle) {
      if (isCheckingTimetable) {
        return 'Checking timetable...';
      }

      if (hasTimetableError) {
        return 'Timetable check failed';
      }

      if (!canStartAttendance) {
        return 'No Active Class';
      }

      return 'Start Attendance';
    }

    return switch (_status) {
      AttendanceDemoStatus.validating => 'Creating attendance session...',
      AttendanceDemoStatus.scanning => 'Capturing face frames...',
      AttendanceDemoStatus.calculating => 'Calculating attendance...',
      AttendanceDemoStatus.completed => 'Preview Completed',
      AttendanceDemoStatus.idle => 'Start Attendance',
    };
  }
}

class _ActiveClassCard extends StatelessWidget {
  const _ActiveClassCard({required this.activeClassAsync});

  final AsyncValue<TimetableModel?> activeClassAsync;

  @override
  Widget build(BuildContext context) {
    return activeClassAsync.when(
      loading: () => const ModulePanel(
        padding: EdgeInsets.all(14),
        child: ModuleInfoTile(
          title: 'Checking active class',
          subtitle: 'Validating today\'s timetable from backend.',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.cyan,
          trailing: ModuleBadge(label: 'Checking', color: AppColors.cyan),
        ),
      ),
      error: (_, _) => const ModulePanel(
        padding: EdgeInsets.all(14),
        child: ModuleInfoTile(
          title: 'Unable to validate timetable',
          subtitle:
              'Start Attendance is disabled until backend validation works.',
          icon: Icons.error_outline_rounded,
          color: AppColors.amber,
          trailing: ModuleBadge(label: 'Blocked', color: AppColors.amber),
        ),
      ),
      data: (activeClass) {
        if (activeClass == null) {
          final textTheme = Theme.of(context).textTheme;
          final colorScheme = Theme.of(context).colorScheme;

          return ModulePanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModuleInfoTile(
                  title: 'No active class right now',
                  subtitle:
                      'Start Attendance is disabled until a scheduled class is active.',
                  icon: Icons.event_busy_rounded,
                  color: AppColors.amber,
                  trailing: ModuleBadge(
                    label: 'Locked',
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Timetable validation prevents attendance from starting outside the assigned class window.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        }

        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return ModulePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Active Scheduled Class',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const ModuleBadge(
                    label: 'Active',
                    icon: Icons.bolt_rounded,
                    color: AppColors.cyan,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ModuleBadge(
                    label: 'Subject ${_shortId(activeClass.subjectId)}',
                    icon: Icons.menu_book_rounded,
                  ),
                  ModuleBadge(
                    label: 'Department ${_shortId(activeClass.departmentId)}',
                    icon: Icons.account_tree_rounded,
                  ),
                  ModuleBadge(
                    label: 'Batch ${_shortId(activeClass.batchId)}',
                    icon: Icons.groups_rounded,
                  ),
                  ModuleBadge(
                    label: 'Semester ${_shortId(activeClass.semesterId)}',
                    icon: Icons.school_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ModuleInfoTile(
                title:
                    '${_formatTime(activeClass.startTime)} to ${_formatTime(activeClass.endTime)}',
                subtitle: 'Assigned class window',
                icon: Icons.schedule_rounded,
                color: AppColors.blue,
              ),
              const SizedBox(height: 9),
              ModuleInfoTile(
                title: 'Teacher ${_shortId(activeClass.teacherId)}',
                subtitle: 'Validated from timetable',
                icon: Icons.co_present_rounded,
                color: AppColors.amber,
              ),
              const SizedBox(height: 12),
              Text(
                'Timetable validation confirmed this session can start during the assigned class window.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String value) {
    final parts = value.trim().split(':');

    if (parts.length < 2) {
      return value;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return value;
    }

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(0, 8);
  }
}

class _ProcessTimeline extends StatelessWidget {
  const _ProcessTimeline({required this.status});

  final AttendanceDemoStatus status;

  static const _steps = [
    _ProcessStep('Validate timetable', AttendanceDemoStatus.validating),
    _ProcessStep('Create attendance session', AttendanceDemoStatus.scanning),
    _ProcessStep('Capture face frames', AttendanceDemoStatus.scanning),
    _ProcessStep(
      'Compare student embeddings',
      AttendanceDemoStatus.calculating,
    ),
    _ProcessStep(
      'Calculate attendance percentage',
      AttendanceDemoStatus.calculating,
    ),
    _ProcessStep('Save attendance preview', AttendanceDemoStatus.completed),
  ];

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Attendance Process',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < _steps.length; index++) ...[
            _ProcessRow(label: _steps[index].label, state: _rowState(index)),
            if (index != _steps.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  _ProcessRowState _rowState(int index) {
    final currentIndex = _currentStepIndex;
    if (status == AttendanceDemoStatus.completed || index < currentIndex) {
      return _ProcessRowState.completed;
    }
    if (index == currentIndex && status != AttendanceDemoStatus.idle) {
      return _ProcessRowState.active;
    }
    return _ProcessRowState.inactive;
  }

  int get _currentStepIndex {
    return switch (status) {
      AttendanceDemoStatus.idle => 0,
      AttendanceDemoStatus.validating => 0,
      AttendanceDemoStatus.scanning => 2,
      AttendanceDemoStatus.calculating => 4,
      AttendanceDemoStatus.completed => _steps.length,
    };
  }
}

class _ProcessStep {
  const _ProcessStep(this.label, this.status);

  final String label;
  final AttendanceDemoStatus status;
}

enum _ProcessRowState { inactive, active, completed }

class _ProcessRow extends StatelessWidget {
  const _ProcessRow({required this.label, required this.state});

  final String label;
  final _ProcessRowState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = state == _ProcessRowState.active;
    final isCompleted = state == _ProcessRowState.completed;
    final color = isCompleted || isActive
        ? colorScheme.secondary
        : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: (isActive ? colorScheme.secondary : colorScheme.surface)
            .withValues(alpha: isActive ? 0.12 : 0.30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isActive ? colorScheme.secondary : colorScheme.outline)
              .withValues(alpha: isActive ? 0.36 : 0.32),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : isActive
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCompleted || isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceRecognitionPreview extends StatelessWidget {
  const _FaceRecognitionPreview({
    required this.status,
    required this.scanAnimation,
  });

  final AttendanceDemoStatus status;
  final Animation<double> scanAnimation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isScanning = status == AttendanceDemoStatus.scanning;
    final isCompleted = status == AttendanceDemoStatus.completed;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF07111F),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.36),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.16),
                          Colors.transparent,
                          colorScheme.secondary.withValues(alpha: 0.10),
                        ],
                      ),
                    ),
                  ),
                ),
                const _FaceBox(left: 36, top: 42, width: 76, height: 88),
                const _FaceBox(left: 156, top: 34, width: 82, height: 98),
                const _FaceBox(left: 278, top: 54, width: 70, height: 82),
                if (isScanning)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: AnimatedBuilder(
                        animation: scanAnimation,
                        builder: (context, child) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final top =
                                  (constraints.maxHeight - 4) *
                                  scanAnimation.value;
                              return Stack(
                                children: [
                                  Positioned(
                                    top: top,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: colorScheme.secondary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.secondary
                                                .withValues(alpha: 0.45),
                                            blurRadius: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                Positioned(
                  left: 14,
                  bottom: 12,
                  child: ModuleBadge(
                    label: isCompleted ? 'Completed' : 'Camera Preview',
                    icon: isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.videocam_rounded,
                    color: isCompleted ? AppColors.cyan : AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isCompleted
                ? 'Face recognition preview completed.'
                : isScanning
                ? 'Detecting visible students...'
                : 'Face recognition preview is ready.',
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              color: isCompleted ? colorScheme.secondary : colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceBox extends StatelessWidget {
  const _FaceBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.78), width: 1.4),
          color: color.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard();

  @override
  Widget build(BuildContext context) {
    return const ModulePanel(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleInfoTile(
            title: 'Preview Completed',
            subtitle: 'Session Status',
            icon: Icons.verified_rounded,
            color: AppColors.cyan,
            trailing: ModuleBadge(label: 'Completed', color: AppColors.cyan),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Total Students',
                  value: '4',
                  icon: Icons.groups_rounded,
                  color: AppColors.cyan,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Present',
                  value: '3',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Absent',
                  value: '1',
                  icon: Icons.warning_rounded,
                  color: AppColors.amber,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Face Recognized',
                  value: '3',
                  icon: Icons.face_retouching_natural_rounded,
                  color: Color(0xFFB48CFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ModuleMetricCard(
            label: 'QR Backup',
            value: '1',
            icon: Icons.qr_code_2_rounded,
            color: Color(0xFFFF8A7A),
          ),
        ],
      ),
    );
  }
}

class _AttendanceResultsPanel extends StatelessWidget {
  const _AttendanceResultsPanel();

  static const _results = [
    _AttendanceResult(
      name: 'Ali Khan',
      frames: '18/20',
      attendance: 90,
      method: 'Face Recognition',
    ),
    _AttendanceResult(
      name: 'Sara Ahmed',
      frames: '16/20',
      attendance: 80,
      method: 'Face Recognition',
    ),
    _AttendanceResult(
      name: 'Ahmed Raza',
      frames: '14/20',
      attendance: 70,
      method: 'Face Recognition',
    ),
    _AttendanceResult(
      name: 'Fatima Noor',
      frames: 'QR Backup',
      attendance: 100,
      method: 'Dynamic QR',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Results',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final result in _results) ...[
            _AttendanceResultTile(result: result),
            if (result != _results.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _AttendanceResultTile extends StatelessWidget {
  const _AttendanceResultTile({required this.result});

  final _AttendanceResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPresent = result.attendance >= 75;
    final statusColor = isPresent ? colorScheme.secondary : AppColors.red;
    final methodColor = result.method == 'Dynamic QR'
        ? AppColors.amber
        : colorScheme.primary;

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
            children: [
              Expanded(
                child: Text(
                  result.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ModuleBadge(
                label: isPresent ? 'Present' : 'Absent',
                icon: isPresent ? Icons.check_rounded : Icons.warning_rounded,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: 'Frames: ${result.frames}',
                icon: Icons.photo_camera_rounded,
                color: colorScheme.secondary,
              ),
              ModuleBadge(
                label: '${result.attendance}%',
                icon: Icons.percent_rounded,
                color: statusColor,
              ),
              ModuleBadge(
                label: result.method,
                icon: result.method == 'Dynamic QR'
                    ? Icons.qr_code_2_rounded
                    : Icons.face_retouching_natural_rounded,
                color: methodColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceResult {
  const _AttendanceResult({
    required this.name,
    required this.frames,
    required this.attendance,
    required this.method,
  });

  final String name;
  final String frames;
  final int attendance;
  final String method;
}
