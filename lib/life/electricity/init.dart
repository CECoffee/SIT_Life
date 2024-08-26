import 'package:mimir/life/electricity/service/electricity.demo.dart';
import 'package:mimir/settings/dev.dart';

import 'service/electricity.dart';
import 'storage/electricity.dart';

class ElectricityBalanceInit {
  static late ElectricityStorage storage;
  static late ElectricityService service;

  static void init() {
    service = Dev.demoMode ? const DemoElectricityService() : const ElectricityService();
  }

  static void initStorage() {
    storage = ElectricityStorage();
  }
}
