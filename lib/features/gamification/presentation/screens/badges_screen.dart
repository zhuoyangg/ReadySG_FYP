import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../auth/providers/auth_provider.dart';
import '../utils/badge_display_utils.dart';
import '../../../../shared/widgets/ready_empty_state.dart';
import '../../../../shared/widgets/ready_error_state.dart';
import '../../../../shared/widgets/ready_offline_banner.dart';
import '../../../../shared/widgets/ready_skeleton.dart';
import '../../data/models/badge_model.dart';
import '../../providers/gamification_provider.dart';

/// Shows all available badges - earned ones are coloured, unearned are greyed out.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationProvider>();
    final all = gamification.allBadges;
    final earnedIds = gamification.earnedBadgeIds;
    final scale = AppScale.of(context);

    // Sort: earned first, then unearned
    final sorted = [...all]..sort((a, b) {
        final aEarned = earnedIds.contains(a.id) ? 0 : 1;
        final bEarned = earnedIds.contains(b.id) ? 0 : 1;
        return aEarned.compareTo(bEarned);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges'),
        centerTitle: true,
      ),
      body: gamification.isLoading && !gamification.hasData
          ? const ReadySkeletonGrid(count: 6, crossAxisCount: 3)
          : !gamification.hasData && gamification.syncFailed
              ? ReadyErrorState(
                  message: 'Failed to load badges. Go back and pull to refresh.',
                  onRetry: () {
                    final userId = context.read<AuthProvider>().currentUser?.id;
                    if (userId != null) {
                      context.read<GamificationProvider>().load(userId);
                    }
                  },
                )
              : sorted.isEmpty
                  ? const ReadyEmptyState(
                      icon: Icons.military_tech_outlined,
                      title: 'No badges loaded yet.',
                    )
                  : Column(
                      children: [
                        ReadyOfflineBanner(
                          visible:
                              gamification.syncFailed && gamification.hasData,
                        ),
                        // Summary banner
                        Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: scale.space(14),
                    horizontal: scale.space(20),
                  ),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    '${earnedIds.length} / ${all.length} badges collected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 360;
                      return GridView.builder(
                        padding: EdgeInsets.all(scale.space(16)),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: scale.space(12),
                          crossAxisSpacing: scale.space(12),
                          childAspectRatio: compact ? 0.74 : 0.85,
                        ),
                        itemCount: sorted.length,
                        itemBuilder: (context, i) {
                          final badge = sorted[i];
                          final earned = earnedIds.contains(badge.id);
                          return _BadgeCard(badge: badge, earned: earned);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// Badge card

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool earned;

  const _BadgeCard({required this.badge, required this.earned});

  String _requirementText() {
    switch (badge.category) {
      case 'milestone':
        return 'Complete ${badge.threshold} lessons';
      case 'streak':
        return '${badge.threshold}-day streak';
      case 'quiz':
        return 'Score ${badge.threshold}% on a quiz';
      default:
        return 'Special achievement';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final scale = AppScale.of(context);
    final color = earned
        ? badgeCategoryColor(badge.category, tokens)
        : tokens.subtleText;
    final bgColor = earned
        ? badgeCategoryColor(badge.category, tokens).withValues(alpha: 0.1)
        : colorScheme.surfaceContainerHighest;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 160;

        return Card(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scale.radius(16)),
            side: BorderSide(
              color: earned
                  ? color.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(scale.space(compact ? 12 : 16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: scale.size(compact ? 54 : 60),
                      height: scale.size(compact ? 54 : 60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: earned ? 0.15 : 0.06),
                      ),
                      child: Icon(
                        badgeIconData(badge.iconName),
                        size: scale.icon(compact ? 28 : 32),
                        color: color,
                      ),
                    ),
                    if (earned)
                      Container(
                        padding: EdgeInsets.all(scale.space(2)),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: scale.icon(16),
                          color: tokens.success,
                        ),
                      ),
                    if (!earned)
                      Container(
                        padding: EdgeInsets.all(scale.space(2)),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: scale.icon(14),
                          color: tokens.subtleText,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: scale.space(compact ? 8 : 10)),
                Text(
                  badge.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scale.font(compact ? 12 : 13),
                    color: earned ? colorScheme.onSurface : tokens.subtleText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: scale.space(4)),
                Text(
                  earned ? badge.description : _requirementText(),
                  style: TextStyle(
                    fontSize: scale.font(compact ? 10.5 : 11),
                    color: earned
                        ? colorScheme.onSurface.withValues(alpha: 0.6)
                        : tokens.subtleText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (earned && badge.pointsReward > 0) ...[
                  SizedBox(height: scale.space(6)),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: scale.space(8),
                        vertical: scale.space(2),
                      ),
                      decoration: BoxDecoration(
                        color: tokens.points.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(scale.radius(10)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '+${badge.pointsReward} pts',
                          style: TextStyle(
                            fontSize: scale.font(11),
                            fontWeight: FontWeight.bold,
                            color: tokens.points,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      );
      },
    );
  }
}
