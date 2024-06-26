import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/timetable/widgets/style.dart';

import '../../entity/display.dart';
import '../../entity/pos.dart';
import '../../entity/timetable_entity.dart';
import 'background.dart';
import 'daily.dart';
import 'weekly.dart';

class TimetableBoard extends StatelessWidget {
  final SitTimetableEntity timetable;

  final ValueNotifier<DisplayMode> $displayMode;

  final ValueNotifier<TimetablePos> $currentPos;

  const TimetableBoard({
    super.key,
    required this.timetable,
    required this.$displayMode,
    required this.$currentPos,
  });

  @override
  Widget build(BuildContext context) {
    final style = TimetableStyle.of(context);
    final background = style.background;
    if (background.enabled) {
      return [
        Positioned.fill(
          child: TimetableBackground(
            background: background,
          ),
        ),
        buildBoard(),
      ].stack();
    }
    return buildBoard();
  }

  Widget buildBoard() {
    return $displayMode >>
        (ctx, mode) => AnimatedSwitcher(
              duration: Durations.short4,
              child: mode == DisplayMode.daily
                  ? DailyTimetable(
                      $currentPos: $currentPos,
                      timetable: timetable,
                    )
                  : WeeklyTimetable(
                      $currentPos: $currentPos,
                      timetable: timetable,
                    ),
            );
  }
}
