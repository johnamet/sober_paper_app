// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catholic_reading_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingAdapter extends TypeAdapter<Reading> {
  @override
  final int typeId = 10;

  @override
  Reading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reading(
      type: fields[0] as String,
      reference: fields[1] as String,
      text: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Reading obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.reference)
      ..writeByte(2)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyCatholicReadingAdapter extends TypeAdapter<DailyCatholicReading> {
  @override
  final int typeId = 11;

  @override
  DailyCatholicReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyCatholicReading(
      date: fields[0] as String,
      feast: fields[1] as String?,
      readings: (fields[2] as List).cast<Reading>(),
      fetchDate: fields[3] as DateTime,
      massVideoUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyCatholicReading obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.feast)
      ..writeByte(2)
      ..write(obj.readings)
      ..writeByte(3)
      ..write(obj.fetchDate)
      ..writeByte(4)
      ..write(obj.massVideoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyCatholicReadingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MassMediaAdapter extends TypeAdapter<MassMedia> {
  @override
  final int typeId = 12;

  @override
  MassMedia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MassMedia(
      date: fields[0] as String,
      url: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as MediaType,
    );
  }

  @override
  void write(BinaryWriter writer, MassMedia obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MassMediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaTypeAdapter extends TypeAdapter<MediaType> {
  @override
  final int typeId = 13;

  @override
  MediaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MediaType.video;
      case 1:
        return MediaType.audio;
      case 2:
        return MediaType.livestream;
      default:
        return MediaType.video;
    }
  }

  @override
  void write(BinaryWriter writer, MediaType obj) {
    switch (obj) {
      case MediaType.video:
        writer.writeByte(0);
        break;
      case MediaType.audio:
        writer.writeByte(1);
        break;
      case MediaType.livestream:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
