// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaced_practice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpacedPracticeModelAdapter extends TypeAdapter<SpacedPracticeModel> {
  @override
  final int typeId = 10;

  @override
  SpacedPracticeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpacedPracticeModel(
      userId: fields[0] as String,
      lessonId: fields[1] as String,
      lastReviewedAt: fields[2] as DateTime,
      nextReviewAt: fields[3] as DateTime,
      intervalDays: fields[4] as int,
      reviewCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SpacedPracticeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.lessonId)
      ..writeByte(2)
      ..write(obj.lastReviewedAt)
      ..writeByte(3)
      ..write(obj.nextReviewAt)
      ..writeByte(4)
      ..write(obj.intervalDays)
      ..writeByte(5)
      ..write(obj.reviewCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpacedPracticeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
