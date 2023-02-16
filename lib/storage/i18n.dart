import 'using.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "localStorage";

  String get title => "$ns.title".tr();

  String get selectBoxTip => "$ns.selectBoxTip".tr();

  String get clearBoxDesc => "$ns.clearBoxDesc".tr();

  String get deleteItemDesc => "$ns.deleteItemDesc".tr();

  String get emptyValueDesc => "$ns.emptyValueDesc".tr();
  String get emptyContent => "$ns.emptyContent".tr();
}