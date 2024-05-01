import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sit/game/settings.dart';
import 'package:sit/utils/hive.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/school/settings.dart';
import 'package:sit/timetable/settings.dart';

import '../life/settings.dart';
import 'entity/proxy.dart';

class _K {
  static const ns = "/settings";
  static const campus = '$ns/campus';
  static const focusTimetable = '$ns/focusTimetable';
  static const lastSignature = '$ns/lastSignature';
}

class _UpdateK {
  static const ns = '/update';
  static const skippedVersion = '$ns/skippedVersion';
  static const lastSkipUpdateTime = '$ns/lastSkipUpdateTime';
}

// ignore: non_constant_identifier_names
late SettingsImpl Settings;

class SettingsImpl {
  final Box box;

  SettingsImpl(this.box);

  late final life = LifeSettings(box);
  late final timetable = TimetableSettings(box);
  late final school = SchoolSettings(box);
  late final game = GameSettings(box);
  late final theme = _Theme(box);
  late final proxy = _Proxy(box);

  Campus get campus => box.safeGet<Campus>(_K.campus) ?? Campus.fengxian;

  set campus(Campus newV) => box.safePut<Campus>(_K.campus, newV);

  late final $campus = box.provider<Campus>(_K.campus);

  bool get focusTimetable => box.safeGet<bool>(_K.focusTimetable) ?? false;

  set focusTimetable(bool newV) => box.safePut<bool>(_K.focusTimetable, newV);

  late final $focusTimetable = box.provider<bool>(_K.focusTimetable);

  String? get lastSignature => box.safeGet<String>(_K.lastSignature);

  set lastSignature(String? value) => box.safePut<String>(_K.lastSignature, value);

  String? get skippedVersion => box.safeGet<String>(_UpdateK.skippedVersion);

  set skippedVersion(String? newV) => box.safePut<String>(_UpdateK.skippedVersion, newV);

  DateTime? get lastSkipUpdateTime => box.safeGet<DateTime>(_UpdateK.lastSkipUpdateTime);

  set lastSkipUpdateTime(DateTime? newV) => box.safePut<DateTime>(_UpdateK.lastSkipUpdateTime, newV);
}

class _ThemeK {
  static const ns = '/theme';
  static const themeColorFromSystem = '$ns/themeColorFromSystem';
  static const themeColor = '$ns/themeColor';
  static const themeMode = '$ns/themeMode';
}

class _Theme {
  final Box box;

  _Theme(this.box);

  // theme
  Color? get themeColor {
    final value = box.safeGet<int>(_ThemeK.themeColor);
    if (value == null) {
      return null;
    } else {
      return Color(value);
    }
  }

  set themeColor(Color? v) {
    box.safePut<int>(_ThemeK.themeColor, v?.value);
  }

  late final $themeColor = box.provider<Color>(
    _ThemeK.themeColor,
    get: () => themeColor,
    set: (v) => themeColor = v,
  );

  bool get themeColorFromSystem => box.safeGet<bool>(_ThemeK.themeColorFromSystem) ?? true;

  set themeColorFromSystem(bool value) => box.safePut<bool>(_ThemeK.themeColorFromSystem, value);

  late final $themeColorFromSystem = box.provider<bool>(_ThemeK.themeColorFromSystem);

  /// [ThemeMode.system] by default.
  ThemeMode get themeMode => box.safeGet<ThemeMode>(_ThemeK.themeMode) ?? ThemeMode.system;

  set themeMode(ThemeMode value) => box.safePut<ThemeMode>(_ThemeK.themeMode, value);

  late final $themeMode = box.provider<ThemeMode>(_ThemeK.themeMode);
}

class _ProxyK {
  static const ns = '/proxy';

  static String address(ProxyCat type) => "$ns/${type.name}/address";

  static String enabled(ProxyCat type) => "$ns/${type.name}/enabled";

  static String proxyMode(ProxyCat type) => "$ns/${type.name}/proxyMode";
}

typedef ProxyProfileRecords = ({String? address, bool enabled, ProxyMode proxyMode});

class ProxyProfileLegacy {
  final Box box;
  final ProxyCat type;

  ProxyProfileLegacy(this.box, String ns, this.type);

  ProxyProfileRecords toRecords() => (address: address, enabled: enabled, proxyMode: proxyMode);

  String? get address => box.safeGet<String>(_ProxyK.address(type));

  set address(String? newV) => box.safePut<String>(_ProxyK.address(type), newV);

  /// [false] by default.
  bool get enabled => box.safeGet<bool>(_ProxyK.enabled(type)) ?? false;

  set enabled(bool newV) => box.safePut<bool>(_ProxyK.enabled(type), newV);

  /// [ProxyMode.schoolOnly] by default.
  ProxyMode get proxyMode => box.safeGet<ProxyMode>(_ProxyK.proxyMode(type)) ?? ProxyMode.schoolOnly;

  set proxyMode(ProxyMode newV) => box.safePut<ProxyMode>(_ProxyK.proxyMode(type), newV);

  bool get isDefaultAddress {
    final address = this.address;
    if (address == null) return true;
    final uri = Uri.tryParse(address);
    if (uri == null) return true;
    return type.isDefaultUri(uri);
  }
}

class _Proxy {
  final Box box;

  _Proxy(this.box)
      : http = ProxyProfileLegacy(box, _ProxyK.ns, ProxyCat.http),
        https = ProxyProfileLegacy(box, _ProxyK.ns, ProxyCat.https),
        all = ProxyProfileLegacy(box, _ProxyK.ns, ProxyCat.all);

  final ProxyProfileLegacy http;
  final ProxyProfileLegacy https;
  final ProxyProfileLegacy all;

  ProxyProfileLegacy resolve(ProxyCat type) {
    return switch (type) {
      ProxyCat.http => http,
      ProxyCat.https => https,
      ProxyCat.all => all,
    };
  }

  void setProfile(ProxyCat type, ProxyProfileRecords value) {
    final profile = resolve(type);
    profile.address = value.address;
    profile.enabled = value.enabled;
    profile.proxyMode = value.proxyMode;
  }

  bool get anyEnabled => http.enabled || https.enabled || all.enabled;

  set anyEnabled(bool value) {
    http.enabled = value;
    https.enabled = value;
    all.enabled = value;
  }

  Listenable listenAnyEnabled() => box.listenable(keys: ProxyCat.values.map((type) => _ProxyK.enabled(type)).toList());

  /// return null if their proxy mode are not identical.
  ProxyMode? getIntegratedProxyMode() {
    final httpMode = http.proxyMode;
    final httpsMode = https.proxyMode;
    final allMode = all.proxyMode;
    if (httpMode == httpsMode && httpMode == allMode) {
      return httpMode;
    } else {
      return null;
    }
  }

  setIntegratedProxyMode(ProxyMode mode) {
    http.proxyMode = mode;
    https.proxyMode = mode;
    all.proxyMode = mode;
  }

  /// return null if their proxy mode are not identical.
  bool hasAnyProxyMode(ProxyMode mode) {
    return http.proxyMode == mode || https.proxyMode == mode || all.proxyMode == mode;
  }

  Listenable listenProxyMode() => box.listenable(keys: ProxyCat.values.map((type) => _ProxyK.proxyMode(type)).toList());

  Listenable listenAnyChange({bool address = true, bool enabled = true, ProxyCat? type}) {
    if (type == null) {
      return box.listenable(keys: [
        if (address) ProxyCat.values.map((type) => _ProxyK.address(type)),
        if (enabled) ProxyCat.values.map((type) => _ProxyK.enabled(type)),
      ]);
    } else {
      return box.listenable(keys: [
        if (address) _ProxyK.address(type),
        if (enabled) _ProxyK.enabled(type),
      ]);
    }
  }
}
