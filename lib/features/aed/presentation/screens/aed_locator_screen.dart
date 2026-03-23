import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ready_offline_banner.dart';
import '../../data/models/aed_location_model.dart';
import '../../providers/aed_provider.dart';
import '../widgets/aed_detail_sheet.dart';
import '../widgets/aed_hero.dart';
import '../widgets/aed_list_view.dart';
import '../widgets/aed_map_view.dart';
import '../widgets/aed_view_toggle_card.dart';

/// AED locator screen with a map and sortable list of all Singapore AED locations.
///
/// Embedded in HomeScreen's IndexedStack (no Scaffold of its own).
/// UX:
///   - SegmentedButton toggles between Map view and List view
///   - Map: OSM tiles, red AED markers, blue user-location dot, re-centre FAB
///   - List: AEDs sorted by distance, pull-to-refresh
///   - Tapping any AED (marker or list tile) opens a modal bottom sheet with details
class AEDLocatorScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignIn;

  const AEDLocatorScreen({super.key, this.onBack, this.onSignIn});

  @override
  State<AEDLocatorScreen> createState() => _AEDLocatorScreenState();
}

class _AEDLocatorScreenState extends State<AEDLocatorScreen>
    with WidgetsBindingObserver {
  bool _showMap = false;
  final _mapController = MapController();
  AEDLocationModel? _selectedAed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AEDProvider>();
      provider.loadAeds();
      provider.startLiveLocationUpdates();
    });
  }

  @override
  void dispose() {
    context.read<AEDProvider>().stopLiveLocationUpdates();
    _mapController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<AEDProvider>();
    if (state == AppLifecycleState.resumed) {
      provider.startLiveLocationUpdates();
      if (provider.userPosition == null || provider.hasLocationError) {
        provider.refreshLocation();
      }
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      provider.stopLiveLocationUpdates();
    }
  }

  void _onMapAedTapped(AEDLocationModel aed) {
    setState(() => _selectedAed = aed);
  }

  void _clearSelection() {
    setState(() => _selectedAed = null);
  }

  void _showListDetail(AEDLocationModel aed) {
    final distance = context.read<AEDProvider>().distanceTo(aed);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AedDetailSheet(aed: aed, distance: distance),
    );
  }

  void _handleViewSelection(bool showMap) {
    setState(() {
      _showMap = showMap;
      if (!showMap) {
        _selectedAed = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = AppScale.of(context).compactPhone;
    return Consumer<AEDProvider>(
      builder: (context, provider, _) {
        return Container(
          color: const Color(0xFFFFF5F5),
          child: Column(
            children: [
              AedHero(onBack: widget.onBack, onSignIn: widget.onSignIn),
              AedViewToggleCard(
                compact: compact,
                isLocating: provider.isLocating,
                showMap: _showMap,
                onSelectionChanged: _handleViewSelection,
              ),
              ReadyOfflineBanner(
                visible: provider.syncFailed && provider.hasData,
              ),
              if (provider.isLoading && provider.aeds.isEmpty)
                const LinearProgressIndicator(),
              Expanded(
                child: _showMap
                    ? AedMapView(
                        provider: provider,
                        mapController: _mapController,
                        selectedAed: _selectedAed,
                        onAedTapped: _onMapAedTapped,
                        onSelectionCleared: _clearSelection,
                      )
                    : AedListView(
                        provider: provider,
                        onAedTapped: _showListDetail,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
