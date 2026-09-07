// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azkar_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AzkarModelAdapter extends TypeAdapter<AzkarModel> {
  @override
  final typeId = 3;

  @override
  AzkarModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AzkarModel(
      id: (fields[0] as num).toInt(),
      text: fields[1] as String,
      count: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AzkarModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AzkarModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
