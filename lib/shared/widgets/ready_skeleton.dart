import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_tokens.dart';

/// A single shimmer rectangle — use as a building block for skeleton layouts.
class ReadySkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ReadySkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = AppSemanticColors.of(context).subtleText.withValues(alpha: 0.15);
    final highlightColor = AppSemanticColors.of(context).subtleText.withValues(alpha: 0.3);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A card-shaped skeleton for list items.
class ReadySkeletonCard extends StatelessWidget {
  final double height;

  const ReadySkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final baseColor = AppSemanticColors.of(context).subtleText.withValues(alpha: 0.15);
    final highlightColor = AppSemanticColors.of(context).subtleText.withValues(alpha: 0.3);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// A column of [count] skeleton cards — use for list loading states.
class ReadySkeletonList extends StatelessWidget {
  final int count;

  const ReadySkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: List.generate(
          count,
          (i) => ReadySkeletonCard(key: ValueKey(i)),
        ),
      ),
    );
  }
}

/// A grid of [count] skeleton boxes — use for grid loading states.
class ReadySkeletonGrid extends StatelessWidget {
  final int count;
  final int crossAxisCount;

  const ReadySkeletonGrid({
    super.key,
    this.count = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = AppSemanticColors.of(context).subtleText.withValues(alpha: 0.15);
    final highlightColor = AppSemanticColors.of(context).subtleText.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: count,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }
}
