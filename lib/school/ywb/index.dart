import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/widgets/app.dart';
import 'package:mimir/school/ywb/init.dart';
import 'package:mimir/school/ywb/storage/application.dart';
import 'package:rettulf/rettulf.dart';

import "i18n.dart";
import 'widgets/application.dart';

const _applicationLength = 2;

class YwbAppCard extends StatefulWidget {
  const YwbAppCard({super.key});

  @override
  State<YwbAppCard> createState() => _YwbAppCardState();
}

class _YwbAppCardState extends State<YwbAppCard> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: i18n.title.text(),
      view: buildRunningCard(),
      leftActions: [
        FilledButton.icon(
          onPressed: () {
            context.push("/ywb");
          },
          icon: const Icon(Icons.list_alt),
          label: i18n.seeAll.text(),
        ),
        OutlinedButton.icon(
          onPressed: () {
            context.push("/ywb/mine");
          },
          label: i18n.mineAction.text(),
          icon: const Icon(Icons.mail_outlined),
        )
      ],
    );
  }

  Widget buildRunningCard() {
    final mine = YwbInit.applicationStorage.myApplications;
    if (mine == null) return const SizedBox();
    final applications = mine.running.sublist(0, min(_applicationLength, mine.running.length));
    return applications.map((e) => YwbApplicationTile(e).inCard()).toList().column();
  }
}
