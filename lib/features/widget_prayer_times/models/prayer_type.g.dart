// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTypeAdapter extends TypeAdapter<PrayerType> {
  @override
  final typeId = 5;

  @override
  PrayerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PrayerType.fajr;
      case 1:
        return PrayerType.sunrise;
      case 2:
        return PrayerType.dhuhr;
      case 3:
        return PrayerType.asr;
      case 4:
        return PrayerType.maghrib;
      case 5:
        return PrayerType.isha;
      default:
        return PrayerType.fajr;
    }
  }

  @override
  void write(BinaryWriter writer, PrayerType obj) {
    switch (obj) {
      case PrayerType.fajr:
        writer.writeByte(0);
      case PrayerType.sunrise:
        writer.writeByte(1);
      case PrayerType.dhuhr:
        writer.writeByte(2);
      case PrayerType.asr:
        writer.writeByte(3);
      case PrayerType.maghrib:
        writer.writeByte(4);
      case PrayerType.isha:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
