import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/application.dart';
import '../page/detail.dart';
import '../using.dart';

class ApplicationTile extends StatelessWidget {
  final ApplicationMeta meta;
  final bool isHot;

  const ApplicationTile({super.key, required this.meta, required this.isHot});

  @override
  Widget build(BuildContext context) {
    final colorIndex = Random(meta.id.hashCode).nextInt(applicationColors.length);
    final color = applicationColors[colorIndex];
    final Widget views;
    if (isHot) {
      views = [
        Text(meta.count.toString()),
        const Icon(Icons.local_fire_department_rounded,color: Colors.red,),
      ].row(mas: MainAxisSize.min);
    } else {
      views = Text(meta.count.toString());
    }

    return ListTile(
      leading: Icon(meta.icon, size: 35, color: color).center().sized(w: 40, h: 40),
      title: Text(
        meta.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        meta.summary,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: views,
      onTap: () {
        final route = context.adaptive.makeRoute((_) => DetailPage(meta: meta));
        context.navigator.push(route);
      },
    );
  }
}
