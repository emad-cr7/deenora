// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_date_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerDateModelAdapter extends TypeAdapter<PrayerDateModel> {
  @override
  final typeId = 6;

  @override
  PrayerDateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerDateModel(
      date: fields[0] as String,
      day: fields[1] as String,
      weekdayEn: fields[2] as String,
      monthEn: fields[3] as String,
      monthNumber: (fields[4] as num).toInt(),
      year: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerDateModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.day)
      ..writeByte(2)
      ..write(obj.weekdayEn)
      ..writeByte(3)
      ..write(obj.monthEn)
      ..writeByte(4)
      ..write(obj.monthNumber)
      ..writeByte(5)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerDateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
