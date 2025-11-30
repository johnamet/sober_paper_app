// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catholic_reflection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyReflectionAdapter extends TypeAdapter<DailyReflection> {
  @override
  final int typeId = 14;

  @override
  DailyReflection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyReflection(
      date: fields[0] as DateTime,
      title: fields[1] as String,
      content: fields[2] as String,
      bibleVerse: fields[3] as String?,
      verseReference: fields[4] as String?,
      prayer: fields[5] as String,
      author: fields[6] as String?,
      fetchedAt: fields[7] as DateTime,
      imageUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyReflection obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.bibleVerse)
      ..writeByte(4)
      ..write(obj.verseReference)
      ..writeByte(5)
      ..write(obj.prayer)
      ..writeByte(6)
      ..write(obj.author)
      ..writeByte(7)
      ..write(obj.fetchedAt)
      ..writeByte(8)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyReflectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
