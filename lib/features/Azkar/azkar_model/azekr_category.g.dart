// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azekr_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AzekrCategoryAdapter extends TypeAdapter<AzekrCategory> {
  @override
  final typeId = 4;

  @override
  AzekrCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AzekrCategory(
      morningAzkar: (fields[0] as List).cast<AzkarModel>(),
      eveningAzkar: (fields[1] as List).cast<AzkarModel>(),
      prayerAzkar: (fields[2] as List).cast<AzkarModel>(),
      prayerLaterAzkar: (fields[3] as List).cast<AzkarModel>(),
      sleepAzkar: (fields[4] as List).cast<AzkarModel>(),
      wakeUpAzkar: (fields[5] as List).cast<AzkarModel>(),
      mosqueAzkar: (fields[6] as List).cast<AzkarModel>(),
      miscellaneousAzkar: (fields[7] as List).cast<AzkarModel>(),
      adhanAzkar: (fields[8] as List).cast<AzkarModel>(),
      wuduAzkar: (fields[9] as List).cast<AzkarModel>(),
      homeAzkar: (fields[10] as List).cast<AzkarModel>(),
      khalaAzkar: (fields[11] as List).cast<AzkarModel>(),
      foodAzkar: (fields[12] as List).cast<AzkarModel>(),
      hajjAndUmrahAzkar: (fields[13] as List).cast<AzkarModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, AzekrCategory obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.morningAzkar)
      ..writeByte(1)
      ..write(obj.eveningAzkar)
      ..writeByte(2)
      ..write(obj.prayerAzkar)
      ..writeByte(3)
      ..write(obj.prayerLaterAzkar)
      ..writeByte(4)
      ..write(obj.sleepAzkar)
      ..writeByte(5)
      ..write(obj.wakeUpAzkar)
      ..writeByte(6)
      ..write(obj.mosqueAzkar)
      ..writeByte(7)
      ..write(obj.miscellaneousAzkar)
      ..writeByte(8)
      ..write(obj.adhanAzkar)
      ..writeByte(9)
      ..write(obj.wuduAzkar)
      ..writeByte(10)
      ..write(obj.homeAzkar)
      ..writeByte(11)
      ..write(obj.khalaAzkar)
      ..writeByte(12)
      ..write(obj.foodAzkar)
      ..writeByte(13)
      ..write(obj.hajjAndUmrahAzkar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AzekrCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
