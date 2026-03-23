import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';

/// Wraps geolocator to handle permission requests and position fetching.
/// Returns null instead of throwing when location is unavailable or denied.
abstract class ILocationService {
  Future<Position?> getCurrentPosition();
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  });
}

class LocationService implements ILocationService {
  /// Requests permission (if needed) and returns the current device position.
  /// Returns null if:
  ///   - Location services are disabled on the device
  ///   - The user denies or permanently denies the permission
  ///   - A timeout or platform error occurs (e.g. Windows desktop)
  @override
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      AppLogger.warning(
        'Failed to get current position',
        scope: 'location',
        error: e,
      );
      return null;
    }
  }

  @override
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
