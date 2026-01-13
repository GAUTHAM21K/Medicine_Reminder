// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineModelAdapter extends TypeAdapter<MedicineModel> {
  @override
  final int typeId = 0;

  @override
  MedicineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      dosage: fields[2] as String,
      scheduledTime: fields[3] as DateTime,
      isTaken: fields[4] as bool,
      takenAt: fields[5] as DateTime?,
      snoozedUntil: fields[6] as DateTime?,
      isSkipped: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.scheduledTime)
      ..writeByte(4)
      ..write(obj.isTaken)
      ..writeByte(5)
      ..write(obj.takenAt)
      ..writeByte(6)
      ..write(obj.snoozedUntil)
      ..writeByte(7)
      ..write(obj.isSkipped);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
