import 'package:flutter/material.dart';
import 'package:sit/credentials/entity/credential.dart';
import 'package:sit/credentials/entity/login_status.dart';
import 'package:sit/credentials/entity/user_type.dart';
import 'package:sit/design/adaptive/editor.dart';
import 'package:sit/entity/campus.dart';

import 'package:flutter/foundation.dart';
import 'package:sit/credentials/init.dart';
import 'package:sit/lifecycle.dart';
import 'package:sit/session/mimir.dart';
import 'package:sit/settings/entity/proxy.dart';
import 'package:sit/storage/hive/init.dart';
import 'package:sit/session/class2nd.dart';
import 'package:sit/session/pg_registration.dart';
import 'package:sit/session/library.dart';
import 'package:sit/session/ywb.dart';
import 'package:sit/life/electricity/init.dart';
import 'package:sit/life/expense_records/init.dart';
import 'package:sit/login/init.dart';
import 'package:sit/me/edu_email/init.dart';
import 'package:sit/school/ywb/init.dart';
import 'package:sit/school/exam_arrange/init.dart';
import 'package:sit/school/library/init.dart';
import 'package:sit/school/oa_announce/init.dart';
import 'package:sit/school/class2nd/init.dart';
import 'package:sit/school/exam_result/init.dart';
import 'package:sit/school/yellow_pages/init.dart';
import 'package:sit/session/ug_registration.dart';
import 'package:sit/timetable/init.dart';
import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:sit/storage/hive/cookie.dart';
import 'package:sit/network/dio.dart';
import 'package:sit/session/sso.dart';
import 'package:sit/update/init.dart';

import '../widgets/captcha_box.dart';

class Init {
  const Init._();

  static late CookieJar cookieJar;
  static late Dio dio;
  static late Dio mimirDio;
  static late Dio dioNoCookie;
  static late MimirSession mimirSession;
  static late SsoSession ssoSession;
  static late UgRegistrationSession ugRegSession;
  static late PgRegistrationSession pgRegSession;
  static late YwbSession ywbSession;
  static late LibrarySession librarySession;
  static late Class2ndSession class2ndSession;

  static Future<void> initNetwork() async {
    debugPrint("Initializing network");
    if (kIsWeb) {
      cookieJar = WebCookieJar();
    } else {
      cookieJar = PersistCookieJar(
        storage: HiveCookieJar(HiveInit.cookies),
      );
    }
    final dioOptions = BaseOptions(
      connectTimeout: const Duration(milliseconds: 8000),
      receiveTimeout: const Duration(milliseconds: 8000),
      sendTimeout: const Duration(milliseconds: 8000),
    );
    dio = await DioInit.init(
      cookieJar: cookieJar,
      config: dioOptions,
    );
    dioNoCookie = await DioInit.init(
      config: dioOptions,
    );
    mimirDio = await DioInit.init(
      config: dioOptions,
    );
    mimirSession = MimirSession(
      dio: mimirDio,
    );
    ssoSession = SsoSession(
      dio: dio,
      cookieJar: cookieJar,
      inputCaptcha: _inputCaptcha,
    );
    ugRegSession = UgRegistrationSession(
      ssoSession: ssoSession,
    );
    ywbSession = YwbSession(
      dio: dio,
    );
    librarySession = LibrarySession(
      dio: dio,
    );
    class2ndSession = Class2ndSession(
      ssoSession: ssoSession,
    );
    pgRegSession = PgRegistrationSession(
      ssoSession: ssoSession,
    );
  }

  static Future<void> initModules() async {
    debugPrint("Initializing modules");
    CredentialsInit.init();
    TimetableInit.init();
    if (!kIsWeb) {
      UpdateInit.init();
      OaAnnounceInit.init();
      ExamResultInit.init();
      ExamArrangeInit.init();
      ExpenseRecordsInit.init();
      LibraryInit.init();
      YwbInit.init();
      Class2ndInit.init();
      ElectricityBalanceInit.init();
    }
    YellowPagesInit.init();
    EduEmailInit.init();
    LoginInit.init();
  }

  static Future<void> initStorage() async {
    debugPrint("Initializing module storage");
    CredentialsInit.initStorage();
    TimetableInit.initStorage();
    if (!kIsWeb) {
      UpdateInit.initStorage();
      OaAnnounceInit.initStorage();
      ExamResultInit.initStorage();
      ExamArrangeInit.initStorage();
      ExpenseRecordsInit.initStorage();
      LibraryInit.initStorage();
      YwbInit.initStorage();
      Class2ndInit.initStorage();
      ElectricityBalanceInit.initStorage();
    }
    YellowPagesInit.initStorage();
    EduEmailInit.initStorage();
    LoginInit.initStorage();
  }

  static void registerCustomEditor() {
    EditorEx.registerEnumEditor(Campus.values);
    EditorEx.registerEnumEditor(ThemeMode.values);
    EditorEx.registerEnumEditor(ProxyMode.values);
    Editor.registerEditor<Credentials>((ctx, desc, initial) => StringsEditor(
          fields: [
            (name: "account", initial: initial.account),
            (name: "password", initial: initial.password),
          ],
          title: desc,
          ctor: (values) => Credentials(account: values[0], password: values[1]),
        ));
    EditorEx.registerEnumEditor(LoginStatus.values);
    EditorEx.registerEnumEditor(OaUserType.values);
  }
}

Future<String?> _inputCaptcha(Uint8List imageBytes) async {
  final context = $key.currentContext!;
// return await context.show$Sheet$(
//   (ctx) => CaptchaSheetPage(
//     captchaData: imageBytes,
//   ),
// );
  return await showAdaptiveDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CaptchaDialog(captchaData: imageBytes),
  );
}
