import 'package:mimir/l10n/time.dart';
import 'package:mimir/settings/dev.dart';
import 'package:statistics/statistics.dart';

import '../patch/entity/patch.dart';
import 'timetable.dart';
import 'timetable_entity.dart';

enum TimetableIssueType {
  empty,
  cbeCourse,
  patchOutOfRange,
  courseOverlaps,
  ;
}

sealed class TimetableIssue {
  TimetableIssueType get type;
}

class TimetableEmptyIssue implements TimetableIssue {
  @override
  TimetableIssueType get type => TimetableIssueType.empty;

  const TimetableEmptyIssue();
}

/// Credit by Examination
class TimetableCbeIssue implements TimetableIssue {
  @override
  TimetableIssueType get type => TimetableIssueType.cbeCourse;
  final int courseKey;

  const TimetableCbeIssue({
    required this.courseKey,
  });

  static bool detect(SitCourse course) {
    if (course.courseName.contains("自修") || course.courseName.contains("免听")) {
      return true;
    }
    return false;
  }
}

/// Credit by Examination
class TimetablePatchOutOfRangeIssue implements TimetableIssue {
  @override
  TimetableIssueType get type => TimetableIssueType.patchOutOfRange;
  final TimetablePatch patch;

  const TimetablePatchOutOfRangeIssue({
    required this.patch,
  });

  static bool detect(Timetable timetable, TimetablePatch patch) {
    if (patch is WithTimetableDayLoc) {
      if (!(patch as WithTimetableDayLoc).allLocInRange(timetable)) {
        return true;
      }
    }
    return false;
  }
}

class TimetableCourseOverlapIssue implements TimetableIssue {
  @override
  TimetableIssueType get type => TimetableIssueType.courseOverlaps;
  final List<int> courseKeys;
  final int weekIndex;
  final Weekday weekday;
  final ({int start, int end}) timeslots;

  const TimetableCourseOverlapIssue({
    required this.courseKeys,
    required this.weekIndex,
    required this.weekday,
    required this.timeslots,
  });

  bool isSameOne(TimetableCourseOverlapIssue other) {
    if (courseKeys.toSet().equalsElements(other.courseKeys.toSet())) {
      return true;
    }
    return false;
  }
}

extension SitTimetable4IssueX on Timetable {
  List<TimetableIssue> inspect() {
    final issues = <TimetableIssue>[];
    // check if empty
    if (courses.isEmpty) {
      issues.add(const TimetableEmptyIssue());
    }

    // check if any cbe
    for (final course in courses.values) {
      if (!course.hidden && TimetableCbeIssue.detect(course)) {
        issues.add(TimetableCbeIssue(
          courseKey: course.courseKey,
        ));
      }
    }

    // TODO: finish overlap issue inspection
    if (Dev.on) {
      final overlaps = <TimetableCourseOverlapIssue>[];
      final entity = resolve();
      for (final day in entity.days) {
        for (var timeslot = 0; timeslot < day.timeslot2LessonSlot.length; timeslot++) {
          final lessonSlot = day.timeslot2LessonSlot[timeslot];
          if (lessonSlot.lessons.length >= 2) {
            final issue = TimetableCourseOverlapIssue(
              courseKeys: lessonSlot.lessons.map((l) => l.course.courseKey).toList(),
              weekIndex: day.weekIndex,
              weekday: day.weekday,
              timeslots: (start: timeslot, end: timeslot),
            );
            if (overlaps.every((overlap) => !overlap.isSameOne(issue))) {
              overlaps.add(issue);
            }
          }
        }
      }
      issues.addAll(overlaps);
    }
    if (Dev.on) {
      for (var i = 0; i < patches.length; i++) {
        final patch = patches[i];
        if (patch is TimetablePatch) {
          if (TimetablePatchOutOfRangeIssue.detect(this, patch)) {
            issues.add(TimetablePatchOutOfRangeIssue(
              patch: patch,
            ));
          }
        }
      }
    }
    return issues;
  }
}
