// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_day_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HadithDayModelAdapter extends TypeAdapter<HadithDayModel> {
  @override
  final typeId = 10;

  @override
  HadithDayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HadithDayModel(
      textArabic: fields[0] as String,
      textEnglish: fields[1] as String,
      collection: fields[2] as String,
      bookNumber: fields[3] as String,
      hadithNumber: fields[4] as String,
      chapterTitleAr: fields[5] as String,
      chapterTitleEn: fields[6] as String,
      savedDate: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HadithDayModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.textArabic)
      ..writeByte(1)
      ..write(obj.textEnglish)
      ..writeByte(2)
      ..write(obj.collection)
      ..writeByte(3)
      ..write(obj.bookNumber)
      ..writeByte(4)
      ..write(obj.hadithNumber)
      ..writeByte(5)
      ..write(obj.chapterTitleAr)
      ..writeByte(6)
      ..write(obj.chapterTitleEn)
      ..writeByte(7)
      ..write(obj.savedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithDayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
