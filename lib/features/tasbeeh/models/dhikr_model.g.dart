// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikr_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DhikrModelAdapter extends TypeAdapter<DhikrModel> {
  @override
  final typeId = 2;

  @override
  DhikrModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DhikrModel(
      id: fields[0] as String,
      name: fields[1] as String,
      arabic: fields[2] as String,
      narratedCount: (fields[3] as num?)?.toInt(),
      customGoal: (fields[4] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, DhikrModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.arabic)
      ..writeByte(3)
      ..write(obj.narratedCount)
      ..writeByte(4)
      ..write(obj.customGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
