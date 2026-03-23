import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../data/models/emergency_guide_model.dart';

class EmergencyGuidesGrid extends StatelessWidget {
  final List<EmergencyGuideModel> guides;
  final IconData Function(String title) iconForTitle;

  const EmergencyGuidesGrid({
    super.key,
    required this.guides,
    required this.iconForTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = width < 360
              ? 2
              : width < 760
                  ? 3
                  : 4;
          final spacing = width < 390 ? 8.0 : 10.0;
          final childAspectRatio = crossAxisCount == 2
              ? (width < 340 ? 1.24 : 1.16)
              : (width < 430 ? 0.96 : 1.02);

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final guide = guides[index];
              return _GuideTile(
                title: guide.title,
                icon: iconForTitle(guide.title),
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push(AppRouter.guidePath(guide.id));
                },
              );
            }, childCount: guides.length),
          );
        },
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _GuideTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        label: '$title emergency guide',
        hint: 'Tap to open guide',
        button: true,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 120;
              final veryCompact = constraints.maxWidth < 108;
              final iconSize = veryCompact
                  ? 18.0
                  : compact
                      ? 20.0
                      : 24.0;
              final badgeSize = veryCompact
                  ? 34.0
                  : compact
                      ? 38.0
                      : 42.0;
              final fontSize = veryCompact
                  ? 12.5
                  : compact
                      ? 14.0
                      : 16.0;
              final verticalPadding = veryCompact
                  ? 6.0
                  : compact
                      ? 8.0
                      : 10.0;
              final horizontalPadding = veryCompact
                  ? 6.0
                  : compact
                      ? 6.0
                      : 8.0;
              final iconGap = veryCompact
                  ? 4.0
                  : compact
                      ? 6.0
                      : 8.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: iconSize),
                    ),
                    SizedBox(height: iconGap),
                    Flexible(
                      child: Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: fontSize,
                                height: veryCompact ? 1.05 : 1.15,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
