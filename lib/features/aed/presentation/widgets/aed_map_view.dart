import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/models/aed_location_model.dart';
import '../../providers/aed_provider.dart';

Future<void> _launchAedRoute(AEDLocationModel aed, BuildContext context) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=${aed.latitude},${aed.longitude}&travelmode=walking',
  );
  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open maps application')),
    );
  }
}

class AedMapView extends StatelessWidget {
  static const LatLng _singaporeCenter = LatLng(1.3521, 103.8198);

  final AEDProvider provider;
  final MapController mapController;
  final ValueChanged<AEDLocationModel> onAedTapped;

  final AEDLocationModel? selectedAed;
  final VoidCallback onSelectionCleared;

  const AedMapView({
    super.key,
    required this.provider,
    required this.mapController,
    required this.selectedAed,
    required this.onAedTapped,
    required this.onSelectionCleared,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final userPos = provider.userPosition;
    if (userPos == null && provider.aeds.isEmpty) {
      final tokens = AppSemanticColors.of(context);
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: scale.space(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: scale.space(14)),
              Text(
                'Getting your current location...',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: scale.space(8)),
              Text(
                provider.hasLocationError && !provider.isLocating
                    ? 'Location permission is unavailable and no cached AED data was found yet.'
                    : 'Allow location permission to sort AEDs by distance once data loads.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.subtleText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    final userLatLng = userPos != null
        ? LatLng(userPos.latitude, userPos.longitude)
        : (selectedAed != null
            ? LatLng(selectedAed!.latitude, selectedAed!.longitude)
            : provider.aeds.isNotEmpty
                ? LatLng(provider.aeds.first.latitude, provider.aeds.first.longitude)
                : _singaporeCenter);
    final initialZoom = userPos != null ? 17.5 : 12.2;
    final summaryAed = selectedAed ??
        (provider.sortedByDistance.isNotEmpty ? provider.sortedByDistance.first : null);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasSummary = selectedAed != null || summaryAed != null;
        final compact = constraints.maxWidth < 360 || constraints.maxHeight < 620;
        final mapHeight = hasSummary
            ? (constraints.maxHeight * (compact ? 0.6 : 0.66)).clamp(240.0, 430.0)
            : constraints.maxHeight;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            scale.space(16),
            0,
            scale.space(16),
            scale.space(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                SizedBox(
                  height: mapHeight,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(scale.radius(16)),
                      border: Border.all(color: const Color(0xFFD5DDE7)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: userLatLng,
                            initialZoom: initialZoom,
                            onTap: (_, _) => onSelectionCleared(),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.readysg.app',
                            ),
                            const SimpleAttributionWidget(
                              source: Text('OpenStreetMap contributors'),
                            ),
                            MarkerClusterLayerWidget(
                              options: MarkerClusterLayerOptions(
                                maxClusterRadius: 80,
                                zoomToBoundsOnClick: false,
                                spiderfyCluster: false,
                                disableClusteringAtZoom: 18,
                                onClusterTap: (cluster) =>
                                    mapController.move(cluster.bounds.center, 18.5),
                                size: Size(scale.space(46), scale.space(46)),
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(scale.space(50)),
                                markers: provider.aeds.map((aed) {
                                  final isSelected = selectedAed?.aedId == aed.aedId;
                                  return Marker(
                                    point: LatLng(aed.latitude, aed.longitude),
                                    width: scale.space(isSelected ? 52 : 42),
                                    height: scale.space(isSelected ? 62 : 50),
                                    alignment: Alignment.bottomCenter,
                                    child: Semantics(
                                      label:
                                          '${aed.displayName} AED${isSelected ? ', selected' : ''}',
                                      hint: 'Tap to select',
                                      button: true,
                                      child: GestureDetector(
                                        onTap: () => onAedTapped(aed),
                                        child: _AEDPinMarker(isSelected: isSelected),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                builder: (context, markers) =>
                                    _ClusterPin(count: markers.length),
                              ),
                            ),
                            if (userPos != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: userLatLng,
                                    width: scale.icon(22),
                                    height: scale.icon(22),
                                    child: Semantics(
                                      label: 'Your current location',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: scale.space(3),
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (userPos == null)
                          Positioned(
                            left: scale.space(14),
                            right: scale.space(14),
                            top: scale.space(14),
                            child: _LocationFallbackBanner(
                              hasLocationError: provider.hasLocationError,
                            ),
                          ),
                        Positioned(
                          left: scale.space(14),
                          bottom: scale.space(14),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: scale.space(10),
                              vertical: scale.space(6),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.56),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${provider.aeds.length} AEDs',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scale.font(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: scale.space(14),
                          bottom: scale.space(14),
                          child: FloatingActionButton.small(
                            heroTag: userPos != null
                                ? 'aed_recenter'
                                : 'aed_location_settings',
                            onPressed: () async {
                              if (userPos != null) {
                                mapController.move(userLatLng, 18.0);
                                return;
                              }
                              await Geolocator.openAppSettings();
                              if (!context.mounted) return;
                              context.read<AEDProvider>().refreshLocation();
                            },
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            child: Icon(
                              userPos != null
                                  ? Icons.my_location
                                  : Icons.settings_outlined,
                              size: scale.icon(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedAed != null || summaryAed != null)
                  SizedBox(height: scale.space(14)),
                if (selectedAed != null)
                  _SelectedAEDPanel(
                    aed: selectedAed!,
                    distance: provider.distanceTo(selectedAed!),
                    onClose: onSelectionCleared,
                  )
                else if (summaryAed != null)
                  _AedSummaryCard(
                    aed: summaryAed,
                    distance: provider.distanceTo(summaryAed),
                    isSelected: false,
                    hasUserLocation: userPos != null,
                    onNavigate: () async {
                      onAedTapped(summaryAed);
                      mapController.move(
                        LatLng(summaryAed.latitude, summaryAed.longitude),
                        18.5,
                      );
                      await _launchAedRoute(summaryAed, context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AEDPinMarker extends StatelessWidget {
  final bool isSelected;
  const _AEDPinMarker({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final pinColor = isSelected
        ? const Color(0xFF0D47A1)
        : AppSemanticColors.of(context).danger;
    final size = AppScale.of(context).space(isSelected ? 52 : 42);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Icon(Icons.location_on, size: size, color: pinColor),
        Positioned(
          top: size * 0.13,
          child: Icon(Icons.medical_services, size: size * 0.37, color: Colors.white),
        ),
      ],
    );
  }
}

class _ClusterPin extends StatelessWidget {
  final int count;
  const _ClusterPin({required this.count});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Container(
      width: scale.space(46),
      height: scale.space(46),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1), shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: scale.space(2)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AED',
              style: TextStyle(
                color: Colors.white,
                fontSize: scale.font(8),
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            Text(
              count > 99 ? '99+' : '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: scale.font(13),
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AedSummaryCard extends StatelessWidget {
  final AEDLocationModel aed;
  final double distance;
  final bool isSelected;
  final bool hasUserLocation;
  final VoidCallback onNavigate;

  const _AedSummaryCard({
    required this.aed,
    required this.distance,
    required this.isSelected,
    required this.hasUserLocation,
    required this.onNavigate,
  });

  String get _distanceLabel {
    if (distance.isInfinite) return '';
    return distance < 1000
        ? '${distance.round()} m away'
        : '${(distance / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final infoColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSelected
                  ? 'Selected AED'
                  : hasUserLocation
                      ? 'Nearest AED'
                      : 'AED Location',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
            ),
            SizedBox(height: scale.space(4)),
            Text(
              aed.displayName,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (_distanceLabel.isNotEmpty) ...[
              SizedBox(height: scale.space(2)),
              Text(
                _distanceLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
              ),
            ],
          ],
        );
        final navigateButton = FilledButton.icon(
          onPressed: onNavigate,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(scale.radius(12)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: scale.space(16),
              vertical: scale.space(12),
            ),
          ),
          icon: Icon(Icons.navigation_outlined, size: scale.icon(18)),
          label: Text(
            'Navigate',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: scale.font(14),
            ),
          ),
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(scale.space(compact ? 12 : 14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(scale.radius(16)),
            border: Border.all(color: const Color(0xFFDDE4EE)),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    infoColumn,
                    SizedBox(height: scale.space(12)),
                    navigateButton,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: infoColumn),
                    SizedBox(width: scale.space(12)),
                    navigateButton,
                  ],
                ),
        );
      },
    );
  }
}

class _LocationFallbackBanner extends StatelessWidget {
  final bool hasLocationError;

  const _LocationFallbackBanner({required this.hasLocationError});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final message = hasLocationError
        ? 'Showing AEDs without distance sorting because location permission is unavailable.'
        : 'Showing AEDs while your current location is still loading.';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.space(12),
        vertical: scale.space(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(scale.radius(12)),
        border: Border.all(color: const Color(0xFFD5DDE7)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: scale.icon(18),
            color: Color(0xFF2563EB),
          ),
          SizedBox(width: scale.space(8)),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                    fontSize: scale.font(12),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedAEDPanel extends StatelessWidget {
  final AEDLocationModel aed;
  final double distance;
  final VoidCallback onClose;

  const _SelectedAEDPanel({required this.aed, required this.distance, required this.onClose});

  String get _distLabel {
    if (distance.isInfinite) return '';
    return distance < 1000
        ? '${distance.round()} m'
        : '${(distance / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = AppScale.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(scale.space(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.radius(16)),
        border: Border.all(color: const Color(0xFFDDE4EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: scale.icon(36),
                height: scale.icon(36),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: Color(0xFFE57373),
                  size: scale.icon(18),
                ),
              ),
              SizedBox(width: scale.space(12)),
              Expanded(
                child: Text(
                  aed.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2B1F1F),
                    fontSize: scale.font(scale.compactPhone ? 20 : 22),
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Close AED detail',
                icon: Icon(Icons.close_rounded, size: scale.icon(18)),
                color: const Color(0xFF6B7280),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                ),
              ),
            ],
          ),
          SizedBox(height: scale.space(14)),
          if (aed.locationDescription.isNotEmpty)
            _DetailRow(
              icon: Icons.place_outlined,
              text: aed.locationDescription,
            ),
          _DetailRow(
            icon: Icons.location_on_outlined,
            text: '${aed.addressLine}, Singapore ${aed.postalCode}',
          ),
          if (aed.floorLevel.isNotEmpty)
            _DetailRow(
              icon: Icons.map_outlined,
              text: 'Floor: ${aed.floorLevel}',
            ),
          if (aed.operatingHours.isNotEmpty)
            _DetailRow(
              icon: Icons.access_time_outlined,
              text: aed.operatingHours,
            ),
          if (_distLabel.isNotEmpty)
            _DetailRow(
              icon: Icons.directions_walk_outlined,
              text: _distLabel,
            ),
          SizedBox(height: scale.space(12)),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _launchAedRoute(aed, context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(scale.radius(12)),
                ),
                padding: EdgeInsets.symmetric(vertical: scale.space(12)),
              ),
              icon: Icon(Icons.navigation_outlined, size: scale.icon(18)),
              label: Text(
                'Navigate',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: scale.font(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7C6F6F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B4B4B),
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
