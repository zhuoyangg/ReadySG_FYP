// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_guide_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmergencyGuideModelAdapter extends TypeAdapter<EmergencyGuideModel> {
  @override
  final int typeId = 4;

  @override
  EmergencyGuideModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmergencyGuideModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      contentJson: fields[3] as String,
      sortOrder: fields[4] as int,
      isPublished: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyGuideModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.contentJson)
      ..writeByte(4)
      ..write(obj.sortOrder)
      ..writeByte(5)
      ..write(obj.isPublished)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyGuideModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyGuideModel _$EmergencyGuideModelFromJson(
        Map<String, dynamic> json) =>
    EmergencyGuideModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      contentJson: json['contentJson'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isPublished: json['isPublished'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EmergencyGuideModelToJson(
        EmergencyGuideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'contentJson': instance.contentJson,
      'sortOrder': instance.sortOrder,
      'isPublished': instance.isPublished,
      'createdAt': instance.createdAt.toIso8601String(),
    };
