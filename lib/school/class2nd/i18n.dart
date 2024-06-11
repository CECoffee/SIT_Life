import 'package:easy_localization/easy_localization.dart';
import 'package:sit/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "class2nd";

  final apply = const _Apply();
  final attended = const _Attended();
  final info = const _Info();

  String get title => "$ns.title".tr();

  String get noAttendedActivities => "$ns.noAttendedActivities".tr();

  String get noActivities => "$ns.noActivities".tr();

  String get activityAction => "$ns.activity".tr();

  String get attendedAction => "$ns.attended.title".tr();

  String get refreshSuccessTip => "$ns.refreshSuccessTip".tr();

  String get refreshFailedTip => "$ns.refreshFailedTip".tr();

  String get viewDetails => "$ns.viewDetails".tr();
}

class _Apply {
  const _Apply();

  static const ns = "${_I18n.ns}.apply";

  String get btn => "$ns.btn".tr();

  String get replyTip => "$ns.replyTip".tr();

  String get applyRequest => "$ns.applyRequest".tr();

  String get applyRequestDesc => "$ns.applyRequestDesc".tr();

  String get applySuccessTip => "$ns.applySuccessTip".tr();

  String get applyFailureTip => "$ns.applyFailureTip".tr();
}

class _Attended {
  const _Attended();

  static const ns = "${_I18n.ns}.attended";

  String get title => "$ns.title".tr();

  String get withdrawApplicationAction => "$ns.withdrawApplicationAction".tr();

  String get withdrawApplication => "$ns.withdrawApplication.title".tr();

  String get withdrawApplicationDesc => "$ns.withdrawApplication.desc".tr();
}

class _Info {
  const _Info();

  static const ns = "${_I18n.ns}.info";

  String get applicationId => "$ns.applicationId".tr();

  String get activityId => "$ns.activityId".tr();

  String applicationOf(int applicationId) => "$ns.applicationOf".tr(
        args: [applicationId.toString()],
      );

  String activityOf(int activityId) => "$ns.activityOf".tr(
        args: [activityId.toString()],
      );

  String get name => "$ns.name".tr();

  String get tags => "$ns.tags".tr();

  String get category => "$ns.category".tr();

  String get scoreType => "$ns.scoreType".tr();

  String get honestyPoints => "$ns.honestyPoints".tr();

  String get totalPoints => "$ns.totalPoints".tr();

  String get applicationTime => "$ns.applicationTime".tr();

  String get status => "$ns.status".tr();

  String get duration => "$ns.duration".tr();

  String get location => "$ns.location".tr();

  String get organizer => "$ns.organizer".tr();

  String get principal => "$ns.principal".tr();

  String get signInTime => "$ns.signInTime".tr();

  String get signOutTime => "$ns.signOutTime".tr();

  String get startTime => "$ns.startTime".tr();

  String get undertaker => "$ns.undertaker".tr();

  String get contactInfo => "$ns.contactInfo".tr();
}
