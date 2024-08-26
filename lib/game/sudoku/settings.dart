import 'package:hive/hive.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/utils/json.dart';

import 'entity/pref.dart';

class _K {
  static const ns = "/settings";
  static const pref = '$ns/pref';
}

class SettingsSudoku {
  static final $ = SettingsSudoku._();

  Box get box => HiveInit.gameSudoku;

  SettingsSudoku._();

  /// [false] by default.
  GamePrefSudoku get pref =>
      decodeJsonObject(box.safeGet<String>(_K.pref), (obj) => GamePrefSudoku.fromJson(obj)) ?? const GamePrefSudoku();

  set pref(GamePrefSudoku newV) => box.safePut<String>(_K.pref, encodeJsonObject(newV));

  late final $pref = box.providerWithDefault<GamePrefSudoku>(
    _K.pref,
    get: () => pref,
    set: (v) => pref = v,
    () => const GamePrefSudoku(),
  );
}
