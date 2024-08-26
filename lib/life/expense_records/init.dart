import 'package:mimir/settings/dev.dart';

import 'service/fetch.dart';
import 'service/fetch.demo.dart';
import 'storage/local.dart';

class ExpenseRecordsInit {
  static late ExpenseService service;
  static late ExpenseStorage storage;

  static void init() {
    service = Dev.demoMode ? const DemoExpenseService() : const ExpenseService();
  }

  static void initStorage() {
    storage = ExpenseStorage();
  }
}
