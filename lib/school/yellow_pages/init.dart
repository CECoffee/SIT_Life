import 'package:mimir/school/yellow_pages/storage/contact.dart';

class YellowPagesInit {
  static late YellowPagesStorage storage;

  static void init() {}
  static void initStorage() {
    storage = YellowPagesStorage();
  }
}
