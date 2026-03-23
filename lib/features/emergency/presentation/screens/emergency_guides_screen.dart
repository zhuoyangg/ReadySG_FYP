import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/ready_empty_state.dart';
import '../../../../shared/widgets/ready_offline_banner.dart';
import '../../../../shared/widgets/ready_skeleton.dart';
import '../../providers/emergency_guides_provider.dart';
import '../widgets/emergency_guides_grid.dart';
import '../widgets/emergency_guides_hero.dart';
import '../widgets/emergency_situation_card.dart';
import '../widgets/important_reminder_card.dart';

/// Lists all emergency guides in a quick-scan icon grid.
class EmergencyGuidesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignIn;

  const EmergencyGuidesScreen({super.key, this.onBack, this.onSignIn});

  @override
  State<EmergencyGuidesScreen> createState() => _EmergencyGuidesScreenState();
}

class _EmergencyGuidesScreenState extends State<EmergencyGuidesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyGuidesProvider>().loadGuides();
    });
  }

  static IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('cpr')) return Icons.favorite;
    if (t.contains('bleed')) return Icons.bloodtype;
    if (t.contains('burn') || t.contains('fire')) {
      return Icons.local_fire_department;
    }
    if (t.contains('chok')) return Icons.no_food;
    if (t.contains('poison')) return Icons.science;
    if (t.contains('bite')) return Icons.pets;
    if (t.contains('drown')) return Icons.pool;
    if (t.contains('stroke')) return Icons.psychology_alt;
    if (t.contains('heart')) return Icons.monitor_heart;
    if (t.contains('fracture') || t.contains('sprain')) {
      return Icons.accessibility_new;
    }
    if (t.contains('unconscious') || t.contains('faint')) {
      return Icons.airline_seat_flat;
    }
    return Icons.emergency;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyGuidesProvider>(
      builder: (context, provider, _) {
        final guides = provider.guides;

        Widget body;

        if (provider.isLoading && !provider.hasData) {
          body = const ReadySkeletonGrid(
            key: ValueKey('guides-skeleton'),
            count: 6,
            crossAxisCount: 2,
          );
        } else {
          body = RefreshIndicator(
            key: const ValueKey('guides-content'),
            onRefresh: provider.refreshGuides,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: EmergencyGuidesHero(
                    onBack: widget.onBack,
                    onSignIn: widget.onSignIn,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: EmergencySituationCard(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ReadyOfflineBanner(
                    visible: provider.syncFailed && provider.hasData,
                  ),
                ),
                if (guides.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ReadyEmptyState(
                      icon: Icons.wifi_off,
                      title: 'No guides available',
                      subtitle:
                          'Connect to the internet to load emergency guides.',
                      onRetry: provider.refreshGuides,
                    ),
                  )
                else
                  EmergencyGuidesGrid(
                    guides: guides,
                    iconForTitle: _iconForTitle,
                  ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: ImportantReminderCard(),
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: body,
        );
      },
    );
  }
}
