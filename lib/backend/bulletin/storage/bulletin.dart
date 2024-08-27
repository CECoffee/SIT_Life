import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/utils/json.dart';

import '../entity/bulletin.dart';

class _K {
  static const latest = "/latest";
  static const list = "/list";
}

class BulletinStorage {
  Box get box => HiveInit.bulletin;

  BulletinStorage();

  MimirBulletin? get latest => decodeJsonObject(
        box.safeGet<String>(_K.latest),
        (obj) => MimirBulletin.fromJson(obj),
      );

  set latest(MimirBulletin? newV) => box.safePut<String>(
        _K.latest,
        encodeJsonObject(newV),
      );
  late final $latest = box.provider(
    _K.latest,
    get: () => latest,
    set: (v) => latest = v,
  );

  List<MimirBulletin>? get list => box.safeGet(_K.list);

  set list(List<MimirBulletin>? newV) {
    box.safePut(_K.list, newV);
  }
}
