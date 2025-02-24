import 'package:flutter/cupertino.dart';
import 'package:mimir/utils/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _kClass2ndAutoRefresh = true;

class SchoolSettings {
  final Box box;

  SchoolSettings(this.box);

  late final class2nd = _Class2nd(box);

  static const ns = "/school";
}

class _Class2ndK {
  static const ns = "${SchoolSettings.ns}/class2nd";
  static const autoRefresh = "$ns/autoRefresh";
}

class _Class2nd {
  final Box box;

  const _Class2nd(this.box);

  bool get autoRefresh => box.safeGet<bool>(_Class2ndK.autoRefresh) ?? _kClass2ndAutoRefresh;

  set autoRefresh(bool newV) => box.safePut<bool>(_Class2ndK.autoRefresh, newV);
}
