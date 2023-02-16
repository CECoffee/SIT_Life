import 'package:mimir/credential/symbol.dart';
import 'package:mimir/home/page/index.dart';
import 'package:mimir/navigation/static_route.dart';
import 'package:mimir/settings/page/index.dart';

import 'module/exam_result/page/evaluation.dart';
import 'module/simple_page/page/browser.dart';
import 'module/symbol.dart';

class Routes {
  Routes._();

  static const root = '/';
  static const home = '/home';
  static const activity = '/activity';
  static const application = '/application';
  static const networkTool = '/network_tool';
  static const eduEmail = '/edu_email';
  static const electricityBill = '/electricity_bill';
  static const reportTemp = '/report_temp';
  static const login = '/login';
  static const expense = '/expense';
  static const examResult = '/exam_result';
  static const examResultEvaluation = '/exam_result/evaluation';
  static const library = '/library';
  static const timetable = '/timetable';
  static const timetableImport = '$timetable/import';
  static const timetableMine = '$timetable/mine';
  static const settings = '/settings';
  static const yellowPages = '/yellow_pages';
  static const oaAnnouncement = '/oa_announcement';
  static const examArrangement = '/exam_arrangement';
  static const scanner = '/scanner';
  static const browser = '/browser';
  static const notFound = '/not_found';
  static const simpleHtml = '/simple_html';
  static const relogin = '/relogin';
}

final defaultRouteTable = StaticRouteTable(
  table: {
    Routes.home: (context, args) => const HomePage(),
    Routes.reportTemp: (context, args) => const DailyReportIndexPage(),
    Routes.login: (context, args) => args["disableOffline"] == true
        ? const LoginPage(
            disableOffline: true,
          )
        : const LoginPage(
            disableOffline: false,
          ),
    Routes.expense: (context, args) => const ExpenseTrackerPage(),
    Routes.networkTool: (context, args) => const NetworkToolPage(),
    Routes.electricityBill: (context, args) => const ElectricityBillPage(),
    Routes.examResult: (context, args) => const ExamResultPage(),
    Routes.application: (context, args) => const ApplicationIndexPage(),
    Routes.library: (context, args) => const LibraryPage(),
    Routes.timetable: (context, args) => const TimetableIndexPage(),
    Routes.timetableImport: (context, args) => const ImportTimetableIndexPage(),
    Routes.timetableMine: (context, args) => const MyTimetablePage(),
    Routes.settings: (context, args) => const SettingsPage(),
    Routes.yellowPages: (context, args) => const YellowPagesPage(),
    Routes.oaAnnouncement: (context, args) => const OaAnnouncePage(),
    Routes.eduEmail: (context, args) => const MailPage(),
    Routes.activity: (context, args) => const ActivityIndexPage(),
    Routes.examArrangement: (context, args) => const ExamArrangementPage(),
    Routes.scanner: (context, args) => const ScannerPage(),
    Routes.browser: (context, args) {
      return BrowserPage(
        initialUrl: args['initialUrl'],
        fixedTitle: args['fixedTitle'],
        showSharedButton: args['showSharedButton'],
        showRefreshButton: args['showRefreshButton'],
        showLoadInBrowser: args['showLoadInBrowser'],
        userAgent: args['userAgent'],
        showLaunchButtonIfUnsupported: args['showLaunchButtonIfUnsupported'],
        showTopProgressIndicator: args['showTopProgressIndicator'],
        javascript: args['javascript'],
        javascriptUrl: args['javascriptUrl'],
      );
    },
    Routes.notFound: (context, args) => NotFoundPage(args['routeName']),
    Routes.simpleHtml: (context, args) {
      return SimpleHtmlPage(
        title: args['title'],
        url: args['url'],
        htmlContent: args['htmlContent'],
      );
    },
    Routes.relogin: (context, args) => const UnauthorizedTipPage(),
    Routes.examResultEvaluation: (context, args) => const EvaluationPage(),
  },
  onNotFound: (context, routeName, args) => NotFoundPage(routeName),
  rootRoute: (context, table, args) {
    // The freshmen and OA users who ever logged in can directly land on the homepage.
    // While, the offline users have to click the `Offline Mode` button every time.
    final routeName = Auth.lastOaAuthTime != null ? Routes.home : Routes.login;
    return table.onGenerateRoute(routeName, args)(context);
  },
);
