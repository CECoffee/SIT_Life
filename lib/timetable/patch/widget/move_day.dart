import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/timetable/entity/loc.dart';
import 'package:mimir/utils/save.dart';

import '../../entity/timetable.dart';
import '../../page/preview.dart';
import '../../i18n.dart';
import '../entity/patch.dart';
import 'shared.dart';

class TimetableMoveDayPatchSheet extends StatefulWidget {
  final SitTimetable timetable;
  final TimetableMoveDayPatch? patch;

  const TimetableMoveDayPatchSheet({
    super.key,
    required this.timetable,
    required this.patch,
  });

  @override
  State<TimetableMoveDayPatchSheet> createState() => _TimetableMoveDayPatchSheetState();
}

class _TimetableMoveDayPatchSheetState extends State<TimetableMoveDayPatchSheet> {
  TimetableDayLoc? get initialSource => widget.patch?.source;

  TimetableDayLoc? get initialTarget => widget.patch?.target;
  late var mode = initialSource?.mode ?? TimetableDayLocMode.date;
  late var sourcePos = initialSource?.mode == TimetableDayLocMode.pos ? initialSource?.pos : null;
  late var sourceDate = initialSource?.mode == TimetableDayLocMode.date ? initialSource?.date : null;
  late var targetPos = initialTarget?.mode == TimetableDayLocMode.pos ? initialTarget?.pos : null;
  late var targetDate = initialTarget?.mode == TimetableDayLocMode.date ? initialTarget?.date : null;
  var anyChanged = false;

  void markChanged() => anyChanged |= true;

  bool canSave() => buildPatch() != null;

  @override
  Widget build(BuildContext context) {
    final patch = buildPatch();
    return PromptSaveBeforeQuitScope(
      changed: anyChanged && canSave(),
      onSave: onSave,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: TimetablePatchType.moveDay.l10n().text(),
              actions: [
                PlatformTextButton(
                  onPressed: onPreview,
                  child: i18n.preview.text(),
                ),
                PlatformTextButton(
                  onPressed: canSave() ? onSave : null,
                  child: i18n.save.text(),
                ),
              ],
            ),
            SliverList.list(children: [
              buildMode().padSymmetric(v: 8, h: 16),
              if (patch != null && !patch.allLocInRange(widget.timetable)) const PatchOutOfRangeWarningTile(),
              ...switch (mode) {
                TimetableDayLocMode.pos => buildPosTab(),
                TimetableDayLocMode.date => buildDateTab(),
              },
              if (patch != null)
                ListTile(
                  title: patch.l10n().text(),
                )
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildMode() {
    return TimetableDayLocModeSwitcher(
      selected: mode,
      onSelected: (newMode) async {
        setState(() {
          mode = newMode;
        });
      },
    );
  }

  List<Widget> buildPosTab() {
    return [
      TimetableDayLocPosSelectionTile(
        icon: Icons.output,
        title: i18n.patch.moveSource,
        timetable: widget.timetable,
        pos: sourcePos,
        onChanged: (newPos) {
          setState(() {
            sourcePos = newPos;
          });
          markChanged();
        },
      ),
      TimetableDayLocPosSelectionTile(
        icon: Icons.input,
        title: i18n.patch.moveTarget,
        timetable: widget.timetable,
        pos: targetPos,
        onChanged: (newPos) {
          setState(() {
            targetPos = newPos;
          });
          markChanged();
        },
      ),
    ];
  }

  List<Widget> buildDateTab() {
    return [
      TimetableDayLocDateSelectionTile(
        icon: Icons.output,
        title: i18n.patch.moveSource,
        timetable: widget.timetable,
        date: sourceDate,
        onChanged: (newPos) {
          setState(() {
            sourceDate = newPos;
          });
          markChanged();
        },
      ),
      TimetableDayLocDateSelectionTile(
        icon: Icons.input,
        title: i18n.patch.moveTarget,
        timetable: widget.timetable,
        date: targetDate,
        onChanged: (newPos) {
          setState(() {
            targetDate = newPos;
          });
          markChanged();
        },
      ),
    ];
  }

  Future<void> onPreview() async {
    await previewTimetable(context, timetable: buildTimetable());
  }

  void onSave() {
    context.pop(buildPatch());
  }

  SitTimetable buildTimetable() {
    final patch = buildPatch();
    final newPatches = List.of(widget.timetable.patches);
    if (patch != null) {
      newPatches.add(patch);
    }
    return widget.timetable.copyWith(
      patches: newPatches,
    );
  }

  TimetableMoveDayPatch? buildPatch() {
    final sourcePos = this.sourcePos;
    final sourceDate = this.sourceDate;
    final targetPos = this.targetPos;
    final targetDate = this.targetDate;
    final source = switch (mode) {
      TimetableDayLocMode.pos => sourcePos != null ? TimetableDayLoc.pos(sourcePos) : null,
      TimetableDayLocMode.date => sourceDate != null ? TimetableDayLoc.date(sourceDate) : null,
    };
    final target = switch (mode) {
      TimetableDayLocMode.pos => targetPos != null ? TimetableDayLoc.pos(targetPos) : null,
      TimetableDayLocMode.date => targetDate != null ? TimetableDayLoc.date(targetDate) : null,
    };
    return source != null && target != null ? TimetableMoveDayPatch(source: source, target: target) : null;
  }
}
