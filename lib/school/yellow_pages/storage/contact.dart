import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sit/utils/hive.dart';
import 'package:sit/storage/hive/init.dart';

import '../entity/contact.dart';

class _K {
  static const history = "/interactHistory";
}

class YellowPagesStorage {
  Box get box => HiveInit.yellowPages;
  final int maxHistoryLength;

  const YellowPagesStorage({
    this.maxHistoryLength = 2,
  });

  List<SchoolContact>? get interactHistory => box.safeGet<List>(_K.history)?.cast<SchoolContact>();

  set interactHistory(List<SchoolContact>? newV) {
    if (newV != null) {
      newV = newV.sublist(0, min(newV.length, maxHistoryLength));
    }
    box.safePut<List>(_K.history, newV);
  }

  ValueListenable<Box> listenHistory() => box.listenable(keys: [_K.history]);
}

extension YellowPagesStorageX on YellowPagesStorage {
  void addInteractHistory(SchoolContact contact) {
    final interactHistory = this.interactHistory ?? <SchoolContact>[];
    if (interactHistory.any((e) => e == contact)) return;
    interactHistory.insert(0, contact);
    this.interactHistory = interactHistory;
  }
}
