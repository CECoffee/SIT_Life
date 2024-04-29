import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/utils/error.dart';

import '../widgets/patch/copy_day.dart';
import '../widgets/patch/move_day.dart';
import '../widgets/patch/remove_day.dart';
import '../widgets/patch/swap_day.dart';
import 'loc.dart';
import 'timetable.dart';
import '../i18n.dart';

part "patch.g.dart";

@JsonEnum(alwaysCreate: true)
enum TimetablePatchType {
  // addLesson,
  // removeLesson,
  // replaceLesson,
  // swapLesson,
  // moveLesson,
  // addDay,
  moveDay(TimetableMoveDayPatch.onCreate),
  removeDay(TimetableRemoveDayPatch.onCreate),
  copyDay(TimetableCopyDayPatch.onCreate),
  swapDays(TimetableSwapDaysPatch.onCreate),
  unknown(TimetableSwapDaysPatch.onCreate),
  ;

  static const creatable = [
    moveDay,
    removeDay,
    copyDay,
    swapDays,
  ];

  final FutureOr<TimetablePatch?> Function(BuildContext context, SitTimetable timetable) onCreate;

  const TimetablePatchType(this.onCreate);

  String l10n() => "timetable.patch.type.$name".tr();
}

/// To opt-in [JsonSerializable], please specify `toJson` parameter to [TimetablePatch.toJson].
sealed class TimetablePatch {
  TimetablePatchType get type;

  const TimetablePatch();

  factory TimetablePatch.fromJson(Map<String, dynamic> json) {
    final type = $enumDecode(_$TimetablePatchTypeEnumMap, json["type"], unknownValue: TimetablePatchType.unknown);
    try {
      return switch (type) {
        // TimetablePatchType.addLesson => TimetableAddLessonPatch.fromJson(json),
        // TimetablePatchType.removeLesson => TimetableAddLessonPatch.fromJson(json),
        // TimetablePatchType.replaceLesson => TimetableAddLessonPatch.fromJson(json),
        // TimetablePatchType.swapLesson => TimetableAddLessonPatch.fromJson(json),
        // TimetablePatchType.moveLesson => TimetableAddLessonPatch.fromJson(json),
        // TimetablePatchType.addDay => TimetableAddLessonPatch.fromJson(json),
        TimetablePatchType.unknown => TimetableUnknownPatch.fromJson(json),
        TimetablePatchType.removeDay => TimetableRemoveDayPatch.fromJson(json),
        TimetablePatchType.swapDays => TimetableSwapDaysPatch.fromJson(json),
        TimetablePatchType.moveDay => TimetableMoveDayPatch.fromJson(json),
        TimetablePatchType.copyDay => TimetableCopyDayPatch.fromJson(json),
      };
    } catch (error, stackTrace) {
      debugPrintError(error, stackTrace);
      return const TimetableUnknownPatch();
    }
  }

  @mustCallSuper
  Map<String, dynamic> toJson() => _toJsonImpl()..["type"] = _$TimetablePatchTypeEnumMap[type];

  Map<String, dynamic> _toJsonImpl();

  Widget build(BuildContext context, SitTimetable timetable, ValueChanged<TimetablePatch> onChanged);

  String toDartCode();

  String l10n();
}

class TimetablePatchSet {
  final String name;
  final List<TimetablePatch> patches;

  const TimetablePatchSet({
    required this.name,
    required this.patches,
  });
}

class BuiltinTimetablePatchSet implements TimetablePatchSet {
  final String key;

  @override
  String get name => "timetable.patch.builtin.$key".tr();
  @override
  final List<TimetablePatch> patches;

  const BuiltinTimetablePatchSet({
    required this.key,
    required this.patches,
  });
}

//
// @JsonSerializable()
// class TimetableAddLessonPatch extends TimetablePatch {
//   @override
//   final type = TimetablePatchType.addLesson;
//
//   const TimetableAddLessonPatch();
//
//   factory TimetableAddLessonPatch.fromJson(Map<String, dynamic> json) => _$TimetableAddLessonPatchFromJson(json);
//
//   @override
//   Map<String, dynamic> _toJsonImpl() => _$TimetableAddLessonPatchToJson(this);
// }

// @JsonSerializable()
// class TimetableRemoveLessonPatch extends TimetablePatch {
//   @override
//   final type = TimetablePatchType.removeLesson;
//
//   const TimetableRemoveLessonPatch();
//
//   factory TimetableRemoveLessonPatch.fromJson(Map<String, dynamic> json) => _$TimetableRemoveLessonPatchFromJson(json);
//
//   @override
//   Map<String, dynamic> _toJsonImpl() => _$TimetableRemoveLessonPatchToJson(this);
// }
//
// @JsonSerializable()
// class TimetableMoveLessonPatch extends TimetablePatch {
//   @override
//   final type = TimetablePatchType.moveLesson;
//
//   const TimetableMoveLessonPatch();
//
//   factory TimetableMoveLessonPatch.fromJson(Map<String, dynamic> json) => _$TimetableMoveLessonPatchFromJson(json);
//
//   @override
//   Map<String, dynamic> _toJsonImpl() => _$TimetableMoveLessonPatchToJson(this);
// }

@JsonSerializable()
class TimetableUnknownPatch extends TimetablePatch {
  @override
  TimetablePatchType get type => TimetablePatchType.unknown;

  final Map<String, dynamic>? legacy;

  const TimetableUnknownPatch({this.legacy});

  factory TimetableUnknownPatch.fromJson(Map<String, dynamic> json) {
    return TimetableUnknownPatch(legacy: json);
  }

  @override
  Map<String, dynamic> _toJsonImpl() => legacy ?? {};

  @override
  Widget build(BuildContext context, SitTimetable timetable, ValueChanged<TimetablePatch> onChanged) {
    throw UnimplementedError("Unknown timetable patch not creatable");
  }

  @override
  String toDartCode() {
    return "TimetableUnknownPatch(legacy:$legacy)";
  }

  @override
  String l10n() {
    return i18n.unknown;
  }
}

@JsonSerializable()
class TimetableRemoveDayPatch extends TimetablePatch {
  @override
  TimetablePatchType get type => TimetablePatchType.removeDay;

  @JsonKey()
  final TimetableDayLoc loc;

  const TimetableRemoveDayPatch({
    required this.loc,
  });

  factory TimetableRemoveDayPatch.fromJson(Map<String, dynamic> json) => _$TimetableRemoveDayPatchFromJson(json);

  @override
  Map<String, dynamic> _toJsonImpl() => _$TimetableRemoveDayPatchToJson(this);

  @override
  Widget build(BuildContext context, SitTimetable timetable, ValueChanged<TimetableRemoveDayPatch> onChanged) {
    return TimetableRemoveDayPatchWidget(
      patch: this,
      timetable: timetable,
      onChanged: onChanged,
    );
  }

  static Future<TimetableRemoveDayPatch?> onCreate(BuildContext context, SitTimetable timetable) async {
    final patch = await context.show$Sheet$(
      (ctx) => TimetableRemoveDayPatchSheet(
        timetable: timetable,
        patch: null,
      ),
    );
    return patch;
  }

  @override
  String toDartCode() {
    return "TimetableRemoveDayPatch(loc:${loc.toDartCode()})";
  }

  @override
  String l10n() {
    return i18n.patch.removeDay(loc.l10n());
  }
}

@JsonSerializable()
class TimetableMoveDayPatch extends TimetablePatch {
  @override
  TimetablePatchType get type => TimetablePatchType.moveDay;
  @JsonKey()
  final TimetableDayLoc source;
  @JsonKey()
  final TimetableDayLoc target;

  const TimetableMoveDayPatch({
    required this.source,
    required this.target,
  });

  factory TimetableMoveDayPatch.fromJson(Map<String, dynamic> json) => _$TimetableMoveDayPatchFromJson(json);

  @override
  Map<String, dynamic> _toJsonImpl() => _$TimetableMoveDayPatchToJson(this);

  @override
  Widget build(BuildContext context, SitTimetable timetable, ValueChanged<TimetableMoveDayPatch> onChanged) {
    return TimetableMoveDayPatchWidget(
      patch: this,
      timetable: timetable,
      onChanged: onChanged,
    );
  }

  static Future<TimetableMoveDayPatch?> onCreate(BuildContext context, SitTimetable timetable) async {
    final patch = await context.show$Sheet$(
      (ctx) => TimetableMoveDayPatchSheet(
        timetable: timetable,
        patch: null,
      ),
    );
    return patch;
  }

  @override
  String toDartCode() {
    return "TimetableMoveDayPatch(source:${source.toDartCode()},target:${target.toDartCode()},)";
  }

  @override
  String l10n() {
    return i18n.patch.moveDay(source.l10n(), target.l10n());
  }
}

@JsonSerializable()
class TimetableCopyDayPatch extends TimetablePatch {
  @override
  TimetablePatchType get type => TimetablePatchType.copyDay;
  @JsonKey()
  final TimetableDayLoc source;
  @JsonKey()
  final TimetableDayLoc target;

  const TimetableCopyDayPatch({
    required this.source,
    required this.target,
  });

  factory TimetableCopyDayPatch.fromJson(Map<String, dynamic> json) => _$TimetableCopyDayPatchFromJson(json);

  @override
  Map<String, dynamic> _toJsonImpl() => _$TimetableCopyDayPatchToJson(this);

  @override
  Widget build(BuildContext context, SitTimetable timetable, ValueChanged<TimetableCopyDayPatch> onChanged) {
    return TimetableCopyDayPatchWidget(
      patch: this,
      timetable: timetable,
      onChanged: onChanged,
    );
  }

  static Future<TimetableCopyDayPatch?> onCreate(BuildContext context, SitTimetable timetable) async {
    final patch = await context.show$Sheet$(
      (ctx) => TimetableCopyDayPatchSheet(
        timetable: timetable,
        patch: null,
      ),
    );
    return patch;
  }

  @override
  String l10n() {
    return i18n.patch.copyDay(source.l10n(), target.l10n());
  }

  @override
  String toDartCode() {
    return "TimetableCopyDayPatch(source:${source.toDartCode()},target:${target.toDartCode()})";
  }
}

@JsonSerializable()
class TimetableSwapDaysPatch extends TimetablePatch {
  @override
  TimetablePatchType get type => TimetablePatchType.swapDays;
  @JsonKey()
  final TimetableDayLoc a;
  @JsonKey()
  final TimetableDayLoc b;

  const TimetableSwapDaysPatch({
    required this.a,
    required this.b,
  });

  factory TimetableSwapDaysPatch.fromJson(Map<String, dynamic> json) => _$TimetableSwapDaysPatchFromJson(json);

  @override
  Map<String, dynamic> _toJsonImpl() => _$TimetableSwapDaysPatchToJson(this);

  @override
  Widget build(BuildContext context, SitTimetable timetable, ValueChanged<TimetableSwapDaysPatch> onChanged) {
    return TimetableSwapDaysPatchWidget(
      patch: this,
      timetable: timetable,
      onChanged: onChanged,
    );
  }

  static Future<TimetableSwapDaysPatch?> onCreate(BuildContext context, SitTimetable timetable) async {
    final patch = await context.show$Sheet$(
      (ctx) => TimetableSwapDaysPatchSheet(
        timetable: timetable,
        patch: null,
      ),
    );
    return patch;
  }

  @override
  String l10n() {
    return i18n.patch.swapDays(a.l10n(), b.l10n());
  }

  @override
  String toDartCode() {
    return "TimetableSwapDayPatch(a:${a.toDartCode()},b:${b.toDartCode()})";
  }
}
// factory .fromJson(Map<String, dynamic> json) => _$FromJson(json);
//
// Map<String, dynamic> toJson() => _$ToJson(this);
