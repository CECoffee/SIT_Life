import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rettulf/rettulf.dart';
import '../entity/entity.dart';
import '../using.dart';

Widget buildButton(BuildContext ctx, String text, {VoidCallback? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(fontSize: ctx.textTheme.bodyLarge?.fontSize) ,
      ),
    ),
  );
}

extension Wrapper on Widget {
  Widget vwrap() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: this,
    );
  }
}

Widget buildInfo(BuildContext ctx, SitCourse course, {required int maxLines}) {
  return AutoSizeText.rich(
    TextSpan(children: [
      TextSpan(
        text: stylizeCourseName(course.courseName),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
      ),
      TextSpan(
        text: "\n${formatPlace(course.place)}\n${course.teachers.join(',')}",
        style: TextStyle(color: ctx.textColor.withOpacity(0.65), fontSize: 12.sp),
      ),
    ]),
    minFontSize: 0,
    stepGranularity: 0.1,
    maxLines: maxLines,
    textAlign: TextAlign.center,
  );
}
