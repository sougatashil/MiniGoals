// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as HabitCategory,
      startDate: fields[3] as DateTime,
      progress: (fields[4] as List?)?.cast<bool>(),
      isCompleted: fields[5] as bool,
      completedDate: fields[6] as DateTime?,
      totalCycles: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedDate)
      ..writeByte(7)
      ..write(obj.totalCycles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitCategoryAdapter extends TypeAdapter<HabitCategory> {
  @override
  final int typeId = 1;

  @override
  HabitCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitCategory.health;
      case 1:
        return HabitCategory.productivity;
      case 2:
        return HabitCategory.learning;
      case 3:
        return HabitCategory.mindfulness;
      case 4:
        return HabitCategory.creative;
      case 5:
        return HabitCategory.finance;
      case 6:
        return HabitCategory.social;
      default:
        return HabitCategory.health;
    }
  }

  @override
  void write(BinaryWriter writer, HabitCategory obj) {
    switch (obj) {
      case HabitCategory.health:
        writer.writeByte(0);
        break;
      case HabitCategory.productivity:
        writer.writeByte(1);
        break;
      case HabitCategory.learning:
        writer.writeByte(2);
        break;
      case HabitCategory.mindfulness:
        writer.writeByte(3);
        break;
      case HabitCategory.creative:
        writer.writeByte(4);
        break;
      case HabitCategory.finance:
        writer.writeByte(5);
        break;
      case HabitCategory.social:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
