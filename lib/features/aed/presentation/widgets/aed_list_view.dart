import 'package:flutter/material.dart';

import '../../../../shared/widgets/ready_skeleton.dart';
import '../../data/models/aed_location_model.dart';
import '../../providers/aed_provider.dart';

class AedListView extends StatelessWidget {
  final AEDProvider provider;
  final ValueChanged<AEDLocationModel> onAedTapped;

  const AedListView({
    super.key,
    required this.provider,
    required this.onAedTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.aeds.isEmpty && provider.isLoading) {
      return const ReadySkeletonList(count: 6);
    }

    if (provider.aeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off,
                size: 56,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No AED data available',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Connect to the internet to load AED locations.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
          ],
        ),
      );
    }

    final sorted = provider.sortedByDistance;

    return RefreshIndicator(
      onRefresh: provider.refreshAeds,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final aed = sorted[index];
          return _AEDListTile(
            aed: aed,
            distance: provider.distanceTo(aed),
            onTap: () => onAedTapped(aed),
          );
        },
      ),
    );
  }
}

class _AEDListTile extends StatelessWidget {
  final AEDLocationModel aed;
  final double distance;
  final VoidCallback onTap;

  const _AEDListTile({
    required this.aed,
    required this.distance,
    required this.onTap,
  });

  String get _distLabel {
    if (distance.isInfinite) return '';
    return distance < 1000
        ? '${distance.round()} m'
        : '${(distance / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.error.withValues(alpha: 0.12),
          ),
          child: Icon(Icons.medical_services,
              color: colorScheme.error, size: 22),
        ),
        title: Text(
          aed.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          aed.floorLevel.isNotEmpty
              ? '${aed.roadName} - ${aed.floorLevel}'
              : aed.roadName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _distLabel.isEmpty
            ? const Icon(Icons.chevron_right)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _distLabel,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
      ),
    );
  }
}
