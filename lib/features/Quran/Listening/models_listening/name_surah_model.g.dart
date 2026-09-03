// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name_surah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NameSurahModelAdapter extends TypeAdapter<NameSurahModel> {
  @override
  final typeId = 2;

  @override
  NameSurahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NameSurahModel(
      id: (fields[0] as num).toInt(),
      revelationPlace: fields[1] as String,
      revelationOrder: (fields[2] as num).toInt(),
      nameSimple: fields[3] as String,
      nameComplex: fields[4] as String,
      nameArabic: fields[5] as String,
      versesCount: (fields[6] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, NameSurahModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.revelationPlace)
      ..writeByte(2)
      ..write(obj.revelationOrder)
      ..writeByte(3)
      ..write(obj.nameSimple)
      ..writeByte(4)
      ..write(obj.nameComplex)
      ..writeByte(5)
      ..write(obj.nameArabic)
      ..writeByte(6)
      ..write(obj.versesCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameSurahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
