import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sit/credentials/entity/credential.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/school/settings.dart';
import 'package:sit/timetable/settings.dart';
import 'package:sit/utils/collection.dart';

import '../life/settings.dart';

class _K {
  static const ns = "/settings";
  static const campus = '$ns/campus';
  static const focusTimetable = '$ns/focusTimetable';
  static const lastSignature = '$ns/lastSignature';
}

class _DeveloperK {
  static const ns = '/developer';
  static const devMode = '$ns/devMode';
  static const savedOaCredentialsList = '$ns/savedOaCredentialsList';
}

// ignore: non_constant_identifier_names
late SettingsImpl Settings;

class SettingsImpl {
  final Box box;

  SettingsImpl(this.box);

  late final life = LifeSettings(box);
  late final timetable = TimetableSettings(box);
  late final school = SchoolSettings(box);
  late final theme = _Theme(box);
  late final httpProxy = _HttpProxy(box);

  Campus get campus => box.get(_K.campus) ?? Campus.fengxian;

  set campus(Campus newV) => box.put(_K.campus, newV);

  ValueListenable<Box> listenCampus() => box.listenable(keys: [_K.campus]);

  bool get focusTimetable => box.get(_K.focusTimetable) ?? false;

  set focusTimetable(bool newV) => box.put(_K.focusTimetable, newV);

  ValueListenable<Box> listenFocusTimetable() => box.listenable(keys: [_K.focusTimetable]);

  String? get lastSignature => box.get(_K.lastSignature);

  set lastSignature(String? value) => box.put(_K.lastSignature, value);

  /// [false] by default.
  bool get isDeveloperMode => box.get(_DeveloperK.devMode) ?? false;

  set isDeveloperMode(bool newV) => box.put(_DeveloperK.devMode, newV);

  ValueListenable<Box> listenIsDeveloperMode() => box.listenable(keys: [_DeveloperK.devMode]);

  List<Credentials>? getSavedOaCredentialsList() =>
      (box.get(_DeveloperK.savedOaCredentialsList) as List?)?.cast<Credentials>();

  Future<void> setSavedOaCredentialsList(List<Credentials>? newV) async {
    newV?.distinctBy((c) => c.account);
    await box.put(_DeveloperK.savedOaCredentialsList, newV);
  }
}

class _ThemeK {
  static const ns = '/theme';
  static const themeColor = '$ns/themeColor';
  static const themeMode = '$ns/themeMode';
}

class _Theme {
  final Box box;

  const _Theme(this.box);

  // theme
  Color? get themeColor {
    final value = box.get(_ThemeK.themeColor);
    if (value == null) {
      return null;
    } else {
      return Color(value);
    }
  }

  set themeColor(Color? v) {
    box.put(_ThemeK.themeColor, v?.value);
  }

  /// [ThemeMode.system] by default.
  ThemeMode get themeMode => box.get(_ThemeK.themeMode) ?? ThemeMode.system;

  set themeMode(ThemeMode value) => box.put(_ThemeK.themeMode, value);

  ValueListenable<Box> listenThemeMode() => box.listenable(keys: [_ThemeK.themeMode]);

  ValueListenable<Box> listenThemeChange() => box.listenable(keys: [_ThemeK.themeMode, _ThemeK.themeColor]);
}

class _HttpProxyK {
  static const ns = '/httpProxy';
  static const address = '$ns/address';
  static const useHttpProxy = '$ns/useHttpProxy';
  static const globalMode = '$ns/globalMode';
}

class _HttpProxy {
  final Box box;

  const _HttpProxy(this.box);

  // network
  String get address => box.get(_HttpProxyK.address) ?? "http://localhost:80";

  set address(String newV) => box.put(_HttpProxyK.address, newV);

  /// [false] by default.
  bool get enableHttpProxy => box.get(_HttpProxyK.useHttpProxy) ?? false;

  set enableHttpProxy(bool newV) => box.put(_HttpProxyK.useHttpProxy, newV);

  /// [false] by default.
  bool get globalMode => box.get(_HttpProxyK.globalMode) ?? false;

  set globalMode(bool newV) => box.put(_HttpProxyK.globalMode, newV);

  ValueListenable listenEnableHttpProxy() => box.listenable(keys: [_HttpProxyK.useHttpProxy]);

  ValueListenable listenGlobalMode() => box.listenable(keys: [_HttpProxyK.globalMode]);

  ValueListenable listenAddress() => box.listenable(keys: [_HttpProxyK.address]);
}
