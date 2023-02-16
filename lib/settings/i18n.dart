import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  final campus = const _Campus();
  final changeOaPwd = const _ChangeOaPwd();
  final clearCache = const _ClearCache();
  final darkMode = const _DarkMode();
  final detailedXcpDialog = const _DetailedXcpDialog();
  final httpProxy = const _HttpProxy();
  final language = const _Language();
  final localStorage = const _LocalStorage();
  final reload = const _Reload();
  final testConnect2School = const _TestConnect2School();
  final testLoginKite = const _TestLoginKite();
  final wipeData = const _WipeData();
  static const ns = "settings";
}

class _Campus {
  const _Campus();

  static const ns = "${_I18n.ns}.campus";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();
}

class _ChangeOaPwd {
  const _ChangeOaPwd();

  static const ns = "${_I18n.ns}.changeOaPwd";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();
}

class _ClearCache {
  const _ClearCache();

  static const ns = "${_I18n.ns}.clearCache";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();

  String get request => "$ns.request".tr();
}

class _DarkMode {
  const _DarkMode();

  static const ns = "${_I18n.ns}.darkMode";

  String get title => "$ns.title".tr();

  String get dark => "$ns.dark".tr();

  String get light => "$ns.light".tr();

  String get followSystem => "$ns.followSystem".tr();
}

class _DetailedXcpDialog {
  const _DetailedXcpDialog();

  static const ns = "${_I18n.ns}.detailedXcpDialog";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();
}

class _HttpProxy {
  const _HttpProxy();

  static const ns = "${_I18n.ns}.httpProxy";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();

  String get global => "$ns.global".tr();

  String get globalDesc => "$ns.globalDesc".tr();

  String get proxyAddress => "$ns.proxyAddress".tr();
}

class _Language {
  const _Language();

  static const ns = "${_I18n.ns}.language";
}

class _LocalStorage {
  const _LocalStorage();

  static const ns = "${_I18n.ns}.localStorage";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();
}

class _Reload {
  const _Reload();

  static const ns = "${_I18n.ns}.reload";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();
}

class _TestConnect2School {
  const _TestConnect2School();

  static const ns = "${_I18n.ns}.testConnect2School";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();
}

class _TestLoginKite {
  const _TestLoginKite();

  static const ns = "${_I18n.ns}.testLoginKite";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();
}

class _WipeData {
  const _WipeData();

  static const ns = "${_I18n.ns}.wipeData";

  String get title => "$ns.title".tr();

  String get desc => "$ns.desc".tr();

  String get request => "$ns.request".tr();

  String get requestDesc => "$ns.requestDesc".tr();
}