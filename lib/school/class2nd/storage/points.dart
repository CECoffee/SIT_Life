import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/storage/hive/init.dart';

import '../entity/application.dart';
import '../entity/attended.dart';

class _K {
  static const pointsSummary = "/pointsSummary";
  static const pointItemList = "/pointItemList";
  static const applicationList = "/applicationList";
}

class Class2ndPointsStorage {
  Box get box => HiveInit.class2nd;

  Class2ndPointsStorage();

  Class2ndPointsSummary? get pointsSummary => box.safeGet<Class2ndPointsSummary>(_K.pointsSummary);

  set pointsSummary(Class2ndPointsSummary? newValue) => box.safePut<Class2ndPointsSummary>(_K.pointsSummary, newValue);

  ValueListenable<Box> listenPointsSummary() => box.listenable(keys: [_K.pointsSummary]);

  late final $pointsSummary = box.provider<Class2ndPointsSummary>(_K.pointsSummary);

  List<Class2ndPointItem>? get pointItemList => box.safeGet<List>(_K.pointItemList)?.cast<Class2ndPointItem>();

  set pointItemList(List<Class2ndPointItem>? newValue) => box.safePut<List>(_K.pointItemList, newValue);

  List<Class2ndActivityApplication>? get applicationList =>
      box.safeGet<List>(_K.applicationList)?.cast<Class2ndActivityApplication>();

  set applicationList(List<Class2ndActivityApplication>? newValue) => box.safePut<List>(_K.applicationList, newValue);
}
