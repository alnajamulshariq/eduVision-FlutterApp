import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class AdminMessageReportsScreen extends StatefulWidget {
  const AdminMessageReportsScreen({super.key});

  @override
  State<AdminMessageReportsScreen> createState() =>
      _AdminMessageReportsScreenState();
}

class _AdminMessageReportsScreenState extends State<AdminMessageReportsScreen> {
  bool _senderRevealed = false;

  void _toggleSenderReveal() {
    setState(() => _senderRevealed = !_senderRevealed);
    if (_senderRevealed) {
      showModuleSnackBar(context, 'Sender revealed for preview.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Message Reports',
      subtitle: 'Review reported anonymous messages preview.',
      fallbackRoute: AppRoutes.admin,
      children: [
        const _ReportOverviewCard(),
        const _ReportedMessageCard(),
        _InvestigationPanel(
          senderRevealed: _senderRevealed,
          onRevealSender: _toggleSenderReveal,
        ),
        const _PrivacyAccountabilityCard(),
      ],
    );
  }
}

class _ReportOverviewCard extends StatelessWidget {
  const _ReportOverviewCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Report Overview',
            icon: Icons.dashboard_customize_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Pending',
                  value: '1',
                  icon: Icons.hourglass_top_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Resolved',
                  value: '2',
                  icon: Icons.check_circle_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ModuleMetricCard(
            label: 'Safety Alerts',
            value: '0',
            icon: Icons.health_and_safety_rounded,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ReportedMessageCard extends StatelessWidget {
  const _ReportedMessageCard();

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
            title: 'Reported Message',
            icon: Icons.report_rounded,
          ),
          const SizedBox(height: 8),
          ModuleBadge(
            label: 'Pending Review',
            icon: Icons.pending_actions_rounded,
            color: colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.34),
              ),
            ),
            child: Text(
              '"The classroom projector is not working properly."',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _ReportDetailTile(
                label: 'Reported By',
                value: 'Mr. Ahmad',
                icon: Icons.co_present_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                label: 'Subject',
                value: 'Database Systems',
                icon: Icons.storage_rounded,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                label: 'Reason',
                value: 'Classroom issue review',
                icon: Icons.rule_rounded,
                color: colorScheme.tertiary,
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                label: 'Identity',
                value: 'Hidden until admin investigation',
                icon: Icons.visibility_off_rounded,
                color: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportDetailTile extends StatelessWidget {
  const _ReportDetailTile({
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
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestigationPanel extends StatelessWidget {
  const _InvestigationPanel({
    required this.senderRevealed,
    required this.onRevealSender,
  });

  final bool senderRevealed;
  final VoidCallback onRevealSender;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Admin Investigation',
            icon: Icons.admin_panel_settings_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModuleSnackBar(context, 'Report opened in preview.');
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Review Report'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModuleSnackBar(
                      context,
                      'Report marked safe in preview.',
                    );
                  },
                  icon: const Icon(Icons.verified_rounded, size: 18),
                  label: const Text('Mark Safe'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRevealSender,
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: const Text('Reveal Sender Preview'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showModuleSnackBar(context, 'Report escalated in preview.');
              },
              icon: const Icon(Icons.priority_high_rounded, size: 18),
              label: const Text('Escalate'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          if (senderRevealed) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModuleInfoTile(
                    title: 'Sender: Ali Khan',
                    subtitle: 'Roll No: BSIT-2022-001',
                    icon: Icons.person_search_rounded,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: colorScheme.tertiary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Identity revealed only for admin investigation preview.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacyAccountabilityCard extends StatelessWidget {
  const _PrivacyAccountabilityCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.policy_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'EduVision protects student identity for normal feedback. Admin '
              'can identify the sender only when a message is reported for '
              'harassment, threats, offensive language, or disciplinary review.',
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
