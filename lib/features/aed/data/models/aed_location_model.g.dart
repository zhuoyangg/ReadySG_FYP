// HAND-WRITTEN Hive TypeAdapter for AEDLocationModel
// typeId: 5 (matches HiveBoxes.aedLocationModelId)
// Fields: 11 (indices 0-10)

import 'package:hive/hive.dart';
import 'aed_location_model.dart';

class AEDLocationModelAdapter extends TypeAdapter<AEDLocationModel> {
  @override
  final int typeId = 5;

  @override
  AEDLocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AEDLocationModel(
      aedId: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      buildingName: fields[3] as String,
      roadName: fields[4] as String,
      houseNumber: fields[5] as String,
      unitNumber: fields[6] as String?,
      postalCode: fields[7] as String,
      locationDescription: fields[8] as String,
      floorLevel: fields[9] as String,
      operatingHours: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AEDLocationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.aedId)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.buildingName)
      ..writeByte(4)
      ..write(obj.roadName)
      ..writeByte(5)
      ..write(obj.houseNumber)
      ..writeByte(6)
      ..write(obj.unitNumber)
      ..writeByte(7)
      ..write(obj.postalCode)
      ..writeByte(8)
      ..write(obj.locationDescription)
      ..writeByte(9)
      ..write(obj.floorLevel)
      ..writeByte(10)
      ..write(obj.operatingHours);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AEDLocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
