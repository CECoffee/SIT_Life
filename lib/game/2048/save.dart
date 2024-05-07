import 'package:json_annotation/json_annotation.dart';
import 'package:sit/game/storage/save.dart';
import 'package:sit/storage/hive/init.dart';

part "save.g.dart";

List<int> _defaultTiles() {
  return List.generate(16, (index) => -1);
}

@JsonSerializable()
class Save2048 {
  @JsonKey(defaultValue: 0)
  final int score;
  @JsonKey(defaultValue: _defaultTiles)
  final List<int> tiles;

  const Save2048({required this.score, required this.tiles});

  Map<String, dynamic> toJson() => _$Save2048ToJson(this);

  factory Save2048.fromJson(Map<String, dynamic> json) => _$Save2048FromJson(json);

  static final storage = GameSaveStorage<Save2048>(
    () => HiveInit.game2048,
    prefix: "/2048/1",
    serialize: (save) => save.toJson(),
    deserialize: Save2048.fromJson,
  );
}
