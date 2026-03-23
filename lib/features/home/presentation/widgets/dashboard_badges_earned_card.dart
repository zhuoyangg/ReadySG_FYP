import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../gamification/data/models/badge_model.dart';
import '../../../gamification/presentation/utils/badge_display_utils.dart';
import 'dashboard_section_card.dart';

class DashboardBadgesEarnedCard extends StatelessWidget {
  final List<BadgeModel> allBadges;
  final Set<String> earnedBadgeIds;
  final VoidCallback onTap;

  const DashboardBadgesEarnedCard({
    super.key,
    required this.allBadges,
    required this.earnedBadgeIds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    final earned = allBadges
        .where((badge) => earnedBadgeIds.contains(badge.id))
        .take(4)
        .toList();
    final preview = earned.isNotEmpty ? earned : allBadges.take(4).toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: DashboardSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionTitle(
              icon: Icons.workspace_premium_outlined,
              title: 'Badges Earned',
              color: tokens.points,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: tokens.subtleText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${earnedBadgeIds.length}/${allBadges.length} badges collected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.subtleText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (preview.isEmpty)
              Text(
                'No badges available yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.subtleText),
              )
            else
              Row(
                children: preview.map((badge) {
                  final isEarned = earnedBadgeIds.contains(badge.id);
                  final badgeColor = badgeCategoryColor(badge.category, tokens);
                  final color = isEarned
                      ? badgeColor
                      : Theme.of(context).colorScheme.outline;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(
                                alpha: isEarned ? 0.14 : 0.08,
                              ),
                            ),
                            child: Icon(
                              badgeIconData(badge.iconName),
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: isEarned
                                      ? Theme.of(context).colorScheme.onSurface
                                      : tokens.subtleText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
