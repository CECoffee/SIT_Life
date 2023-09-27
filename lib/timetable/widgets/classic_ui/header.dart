import 'package:flutter/material.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/timetable/widgets/style.dart';
import 'package:rettulf/rettulf.dart';

import '../../i18n.dart';

class TimetableHeader extends StatefulWidget {
  /// 当前显示的周次
  final int currentWeek;

  /// 当前初始选中的日 (1-7)
  final int selectedDay;

  /// 点击的回调
  final Function(int)? onDayTap;

  final DateTime startDate;

  const TimetableHeader({
    super.key,
    required this.currentWeek,
    required this.selectedDay,
    required this.startDate,
    this.onDayTap,
  });

  @override
  State<StatefulWidget> createState() => _TimetableHeaderState();
}

class _TimetableHeaderState extends State<TimetableHeader> {
  int get selectedDay => widget.selectedDay;

  @override
  void initState() {
    super.initState();
  }

  /// 布局标题栏下方的时间选择行
  ///
  /// 将该行分为 2 + 7 * 3 一共 23 个小份, 左侧的周数占 2 份, 每天的日期占 3 份.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= 7; ++i) buildDayNameHeader(i),
      ],
    );
  }

  Widget buildDayHeader(BuildContext ctx, int day, String name) {
    final isSelected = day == selectedDay;
    final (:text, :bg) = ctx.makeTabHeaderTextBgColors(isSelected);
    final side = getBorderSide(ctx);
    return AnimatedContainer(
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: day == 1 ? side : BorderSide.none, right: day != 7 ? side : BorderSide.none),
      ),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastEaseInToSlowEaseOut,
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(color: text),
      ).padOnly(t: 5, b: 5),
    );
  }

  ///每天的列
  Widget buildDayNameHeader(int day) {
    final date = parseWeekDayNumberToDate(week: widget.currentWeek, day: day, basedOn: widget.startDate);
    final dateString = '${date.month}/${date.day}';
    final onDayTap = widget.onDayTap;
    return Expanded(
      flex: 3,
      child: InkWell(
          onTap: onDayTap != null
              ? () {
                  widget.onDayTap?.call(day);
                }
              : null,
          child: buildDayHeader(context, day, '${i18n.weekdayShort(index: day - 1)}\n$dateString')),
    );
  }
}

BorderSide getBorderSide(BuildContext ctx) => BorderSide(color: ctx.colorScheme.primary.withOpacity(0.4), width: 0.8);