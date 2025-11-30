// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saint_of_the_day_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaintOfTheDayAdapter extends TypeAdapter<SaintOfTheDay> {
  @override
  final int typeId = 15;

  @override
  SaintOfTheDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaintOfTheDay(
      date: fields[0] as DateTime,
      name: fields[1] as String,
      feastType: fields[2] as String?,
      imageUrl: fields[3] as String,
      reflectionUrl: fields[4] as String,
      summary: fields[5] as String?,
      fullReflection: fields[6] as String?,
      bibleVerse: fields[7] as String?,
      verseReference: fields[8] as String?,
      prayer: fields[9] as String?,
      fetchedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SaintOfTheDay obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.feastType)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.reflectionUrl)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.fullReflection)
      ..writeByte(7)
      ..write(obj.bibleVerse)
      ..writeByte(8)
      ..write(obj.verseReference)
      ..writeByte(9)
      ..write(obj.prayer)
      ..writeByte(10)
      ..write(obj.fetchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaintOfTheDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
