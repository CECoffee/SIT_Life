// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamEntry _$ExamEntryFromJson(Map<String, dynamic> json) => ExamEntry(
      courseName: json['courseName'] as String,
      place: json['place'] as String,
      campus: json['campus'] as String,
      time: _$recordConvertNullable(
        json['time'],
        ($jsonValue) => (
          end: DateTime.parse($jsonValue['end'] as String),
          start: DateTime.parse($jsonValue['start'] as String),
        ),
      ),
      seatNumber: json['seatNumber'] as int?,
      isRetake: json['isRetake'] as bool?,
    );

Map<String, dynamic> _$ExamEntryToJson(ExamEntry instance) => <String, dynamic>{
      'courseName': instance.courseName,
      'time': instance.time == null
          ? null
          : {
              'end': instance.time!.end.toIso8601String(),
              'start': instance.time!.start.toIso8601String(),
            },
      'place': instance.place,
      'campus': instance.campus,
      'seatNumber': instance.seatNumber,
      'isRetake': instance.isRetake,
    };

$Rec? _$recordConvertNullable<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    value == null ? null : convert(value as Map<String, dynamic>);
