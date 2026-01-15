// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionResultAdapter extends TypeAdapter<SessionResult> {
  @override
  final int typeId = 0;

  @override
  SessionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionResult(
      date: fields[0] as DateTime,
      instrument: fields[1] as String,
      score: fields[2] as int,
      totalNotes: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SessionResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.instrument)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.totalNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
