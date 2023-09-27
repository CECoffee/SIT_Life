import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "examResult";

  String get title => "$ns.title".tr();

  String get check => "$ns.check".tr();

  String get teacherEval => "$ns.teacherEval".tr();

  String get teacherEvalTitle => "$ns.teacherEvalTitle".tr();

  String get lessonEvaluationBtn => "$ns.lessonEvaluationBtn".tr();

  String get noResultsTip => "$ns.noResultsTip".tr();

  String get lessonNotEvaluated => "$ns.lessonNotEvaluated".tr();

  String lessonSelected(int count) => "$ns.lessonSelected".tr(args: [
        count.toString(),
      ]);

  String gpaResult(double point) => "$ns.gpaResult".tr(args: [
        point.toStringAsPrecision(2),
      ]);

  String get compulsory => "$ns.compulsory".tr();

  String get credit => "$ns.credit".tr();

  String get elective => "$ns.elective".tr();
}