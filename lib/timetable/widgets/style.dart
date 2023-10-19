import 'package:flutter/material.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/timetable/entity/platte.dart';
import 'package:sit/timetable/platte.dart';

import '../init.dart';

class CourseCellStyle {
  final bool showTeachers;
  final bool grayOutTakenLessons;
  final bool harmonizeWithThemeColor;
  final double alpha;

  const CourseCellStyle({
    required this.showTeachers,
    required this.grayOutTakenLessons,
    required this.harmonizeWithThemeColor,
    required this.alpha,
  });

  CourseCellStyle copyWith({
    bool? showTeachers,
    bool? grayOutTakenLessons,
    bool? harmonizeWithThemeColor,
    double? alpha,
  }) {
    return CourseCellStyle(
      showTeachers: showTeachers ?? this.showTeachers,
      grayOutTakenLessons: grayOutTakenLessons ?? this.grayOutTakenLessons,
      harmonizeWithThemeColor: harmonizeWithThemeColor ?? this.harmonizeWithThemeColor,
      alpha: alpha ?? this.alpha,
    );
  }

  static CourseCellStyle fromStorage() {
    return CourseCellStyle(
      showTeachers: Settings.timetable.cell.showTeachers,
      grayOutTakenLessons: Settings.timetable.cell.grayOutTakenLessons,
      harmonizeWithThemeColor: Settings.timetable.cell.harmonizeWithThemeColor,
      alpha: Settings.timetable.cell.alpha,
    );
  }
}

class TimetableStyleData {
  final TimetablePalette platte;
  final CourseCellStyle cell;

  const TimetableStyleData({
    required this.platte,
    required this.cell,
  });

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is TimetableStyleData &&
        runtimeType == other.runtimeType &&
        platte == other.platte &&
        cell == other.cell;
  }
}

class TimetableStyle extends InheritedWidget {
  final TimetableStyleData data;

  const TimetableStyle({
    super.key,
    required this.data,
    required super.child,
  });

  static TimetableStyleData of(BuildContext context) {
    final TimetableStyle? result = context.dependOnInheritedWidgetOfExactType<TimetableStyle>();
    assert(result != null, 'No TimetableStyle found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(TimetableStyle oldWidget) {
    return data != oldWidget.data;
  }
}

class TimetableStyleProv extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, TimetableStyleData style)? builder;

  const TimetableStyleProv({super.key, this.child, this.builder})
      : assert(builder != null || child != null, "TimetableStyleProv should have at least one child.");

  @override
  TimetableStyleProvState createState() => TimetableStyleProvState();
}

class TimetableStyleProvState extends State<TimetableStyleProv> {
  final $palette = TimetableInit.storage.palette.$selected;
  final $cellStyle = Settings.timetable.cell.listenStyle();
  var palette = TimetableInit.storage.palette.selectedRow ?? BuiltinTimetablePalettes.classic;
  var cellStyle = CourseCellStyle.fromStorage();

  @override
  void initState() {
    super.initState();
    $palette.addListener(refreshPalette);
    $cellStyle.addListener(refreshCellStyle);
  }

  @override
  void dispose() {
    $palette.removeListener(refreshPalette);
    $cellStyle.removeListener(refreshCellStyle);
    super.dispose();
  }

  void refreshPalette() {
    setState(() {
      palette = TimetableInit.storage.palette.selectedRow ?? BuiltinTimetablePalettes.classic;
    });
  }

  void refreshCellStyle() {
    setState(() {
      cellStyle = CourseCellStyle.fromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = TimetableStyleData(
      platte: palette,
      cell: cellStyle,
    );
    return TimetableStyle(
      data: data,
      child: buildChild(data),
    );
  }

  Widget buildChild(TimetableStyleData data) {
    final child = widget.child;
    if (child != null) {
      return child;
    }
    final builder = widget.builder;
    if (builder != null) {
      return Builder(builder: (ctx) => builder(ctx, data));
    }
    return const SizedBox();
  }
}
