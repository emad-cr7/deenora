// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_meta_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerMetaModelAdapter extends TypeAdapter<PrayerMetaModel> {
  @override
  final typeId = 8;

  @override
  PrayerMetaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerMetaModel(
      latitude: (fields[0] as num).toDouble(),
      longitude: (fields[1] as num).toDouble(),
      timezone: fields[2] as String,
      methodName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerMetaModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.timezone)
      ..writeByte(3)
      ..write(obj.methodName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerMetaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
