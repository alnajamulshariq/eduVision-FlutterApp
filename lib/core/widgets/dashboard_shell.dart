import 'package:eduvision_app/core/widgets/dashboard_action_card.dart';
import 'package:eduvision_app/core/widgets/dashboard_header_card.dart';
import 'package:eduvision_app/core/widgets/dashboard_stat_card.dart';
import 'package:eduvision_app/core/widgets/premium_background.dart';
import 'package:eduvision_app/core/widgets/section_title.dart';
import 'package:flutter/material.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.roleLabel,
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.actions,
  });

  final String roleLabel;
  final String title;
  final String subtitle;
  final List<DashboardStat> stats;
  final List<DashboardActionCard> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: ScrollConfiguration(
            behavior: const _DashboardScrollBehavior(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeaderCard(
                        roleLabel: roleLabel,
                        title: title,
                        subtitle: subtitle,
                      ),
                      const SizedBox(height: 10),
                      _StatsSection(stats: stats),
                      const SizedBox(height: 12),
                      SectionTitle(
                        title: 'Modules',
                        trailing: Text('${actions.length} tools'),
                      ),
                      const SizedBox(height: 8),
                      for (final action in actions) ...[
                        action,
                        if (action != actions.last) const SizedBox(height: 9),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final List<DashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 310) {
          return Row(
            children: [
              for (final stat in stats) ...[
                if (stat != stats.first) const SizedBox(width: 8),
                Expanded(child: DashboardStatCard(stat: stat)),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stat in stats)
              SizedBox(
                width: (constraints.maxWidth - 8) / 2,
                child: DashboardStatCard(stat: stat),
              ),
          ],
        );
      },
    );
  }
}

class _DashboardScrollBehavior extends ScrollBehavior {
  const _DashboardScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
