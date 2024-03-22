import 'package:easy_localization/easy_localization.dart';
import 'package:sit/game/i18n.dart';
import 'package:sit/game/minesweeper/model/mode.dart';
import 'package:sit/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin, CommonGameI18nMixin {
  const _I18n();

  static const ns = "game.minesweeper";

  String get title => "$ns.title".tr();

  String timeSpent(String time) => "$ns.timeSpent".tr(args: [time]);
}

extension GameModeI18nX on GameMode {
  String l10n() => "${_I18n.ns}.gameMode.$name".tr();
}
