// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimesModelAdapter extends TypeAdapter<PrayerTimesModel> {
  @override
  final typeId = 9;

  @override
  PrayerTimesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimesModel(
      timings: (fields[0] as Map).cast<PrayerType, String>(),
      imsak: fields[1] as String,
      sunset: fields[2] as String,
      midnight: fields[3] as String,
      firstThird: fields[4] as String,
      lastThird: fields[5] as String,
      readableDate: fields[6] as String,
      hijri: fields[7] as HijriDateModel,
      gregorian: fields[8] as PrayerDateModel,
      meta: fields[9] as PrayerMetaModel,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimesModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.timings)
      ..writeByte(1)
      ..write(obj.imsak)
      ..writeByte(2)
      ..write(obj.sunset)
      ..writeByte(3)
      ..write(obj.midnight)
      ..writeByte(4)
      ..write(obj.firstThird)
      ..writeByte(5)
      ..write(obj.lastThird)
      ..writeByte(6)
      ..write(obj.readableDate)
      ..writeByte(7)
      ..write(obj.hijri)
      ..writeByte(8)
      ..write(obj.gregorian)
      ..writeByte(9)
      ..write(obj.meta);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
