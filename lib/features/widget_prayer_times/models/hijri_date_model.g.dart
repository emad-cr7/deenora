// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hijri_date_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HijriDateModelAdapter extends TypeAdapter<HijriDateModel> {
  @override
  final typeId = 7;

  @override
  HijriDateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HijriDateModel(
      date: fields[0] as String,
      day: fields[1] as String,
      weekdayEn: fields[2] as String,
      weekdayAr: fields[3] as String,
      monthEn: fields[4] as String,
      monthAr: fields[5] as String,
      monthNumber: (fields[6] as num).toInt(),
      year: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HijriDateModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.day)
      ..writeByte(2)
      ..write(obj.weekdayEn)
      ..writeByte(3)
      ..write(obj.weekdayAr)
      ..writeByte(4)
      ..write(obj.monthEn)
      ..writeByte(5)
      ..write(obj.monthAr)
      ..writeByte(6)
      ..write(obj.monthNumber)
      ..writeByte(7)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HijriDateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
