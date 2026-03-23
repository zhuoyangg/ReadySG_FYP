import 'package:hive/hive.dart';

/// Represents a single AED (Automated External Defibrillator) location.
///
/// Data source: data.gov.sg dataset d_4e6b82c58a8a832f6f1fee5dfa6d47ea
/// Synced via Supabase Edge Function -> aed_locations table -> Hive cache.
@HiveType(typeId: 5)
class AEDLocationModel extends HiveObject {
  @HiveField(0)
  final String aedId; // AED_ID (primary key)

  @HiveField(1)
  final double latitude; // LATITUDE

  @HiveField(2)
  final double longitude; // LONGITUDE

  @HiveField(3)
  final String buildingName; // BUILDING_NAME

  @HiveField(4)
  final String roadName; // ROAD_NAME

  @HiveField(5)
  final String houseNumber; // HOUSE_NUMBER

  @HiveField(6)
  final String? unitNumber; // UNIT_NUMBER (nullable)

  @HiveField(7)
  final String postalCode; // POSTAL_CODE

  @HiveField(8)
  final String locationDescription; // AED_LOCATION_DESCRIPTION

  @HiveField(9)
  final String floorLevel; // AED_LOCATION_FLOOR_LEVEL

  @HiveField(10)
  final String operatingHours; // OPERATING_HOURS

  AEDLocationModel({
    required this.aedId,
    required this.latitude,
    required this.longitude,
    required this.buildingName,
    required this.roadName,
    required this.houseNumber,
    this.unitNumber,
    required this.postalCode,
    required this.locationDescription,
    required this.floorLevel,
    required this.operatingHours,
  });

  /// Primary label for map marker or list tile title.
  String get displayName =>
      buildingName.isNotEmpty ? buildingName : '$houseNumber $roadName'.trim();

  /// Short address line (house + road + unit).
  String get addressLine {
    final parts = <String>[];
    if (houseNumber.isNotEmpty) parts.add(houseNumber);
    if (roadName.isNotEmpty) parts.add(roadName);
    if (unitNumber != null && unitNumber!.isNotEmpty) {
      parts.add('#$unitNumber');
    }
    return parts.join(' ');
  }
}
