// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookImageAdapter extends TypeAdapter<BookImage> {
  @override
  final int typeId = 106;

  @override
  BookImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookImage(
      isbn: fields[0] as String,
      coverUrl: fields[1] as String,
      resourceUrl: fields[2] as String,
      status: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BookImage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isbn)
      ..writeByte(1)
      ..write(obj.coverUrl)
      ..writeByte(2)
      ..write(obj.resourceUrl)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BookImageAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookImage _$BookImageFromJson(Map<String, dynamic> json) => BookImage(
      isbn: json['isbn'] as String,
      coverUrl: json['coverlink'] as String,
      resourceUrl: json['resourceLink'] as String,
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$BookImageToJson(BookImage instance) => <String, dynamic>{
      'isbn': instance.isbn,
      'coverlink': instance.coverUrl,
      'resourceLink': instance.resourceUrl,
      'status': instance.status,
    };
