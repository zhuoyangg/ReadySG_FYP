import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/models/aed_location_model.dart';

class AedDetailSheet extends StatelessWidget {
  final AEDLocationModel aed;
  final double distance;

  const AedDetailSheet({super.key, required this.aed, required this.distance});

  String get _distLabel {
    if (distance.isInfinite) return '';
    return distance < 1000
        ? '${distance.round()} m away'
        : '${(distance / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppSemanticColors.of(context).subtleText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.medical_services,
                    color: AppSemanticColors.of(context).danger, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    aed.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Specific location in building
            if (aed.locationDescription.isNotEmpty) ...[
              _Row(Icons.place, aed.locationDescription),
              const SizedBox(height: 6),
            ],
            // Address
            _Row(
              Icons.location_on_outlined,
              '${aed.addressLine}, Singapore ${aed.postalCode}',
            ),
            // Floor
            if (aed.floorLevel.isNotEmpty) ...[
              const SizedBox(height: 6),
              _Row(Icons.stairs_outlined, 'Floor: ${aed.floorLevel}'),
            ],
            // Operating hours
            if (aed.operatingHours.isNotEmpty) ...[
              const SizedBox(height: 6),
              _Row(Icons.access_time_outlined, aed.operatingHours),
            ],
            // Distance
            if (_distLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              _Row(Icons.directions_walk_outlined, _distLabel),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Row(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
