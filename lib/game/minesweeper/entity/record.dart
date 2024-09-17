import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:mimir/game/entity/game_result.dart';
import 'package:mimir/game/entity/record.dart';
import 'package:uuid/uuid.dart';

import 'blueprint.dart';
import 'board.dart';
import 'mode.dart';

part "record.g.dart";

@JsonSerializable()
@immutable
class RecordMinesweeper extends GameRecord {
  final GameResult result;
  final int rows;
  final int columns;
  final int mines;
  final Duration playtime;
  final GameModeMinesweeper mode;
  final String blueprint;

  const RecordMinesweeper({
    required super.uuid,
    required super.ts,
    required this.result,
    required this.rows,
    required this.columns,
    required this.mines,
    required this.playtime,
    required this.mode,
    required this.blueprint,
  });

  factory RecordMinesweeper.createFrom({
    required CellBoard board,
    required Duration playtime,
    required GameModeMinesweeper mode,
    required GameResult result,
    required ({int row, int column}) firstClick,
  }) {
    final blueprint = BlueprintMinesweeper(
      firstClick: firstClick,
      builder: board.toBuilder(),
      mode: mode,
    );
    return RecordMinesweeper(
      uuid: const Uuid().v4(),
      ts: DateTime.now(),
      result: result,
      rows: board.rows,
      columns: board.columns,
      mines: board.mines,
      playtime: playtime,
      mode: mode,
      blueprint: blueprint.build(),
    );
  }

  Map<String, dynamic> toJson() => _$RecordMinesweeperToJson(this);

  factory RecordMinesweeper.fromJson(Map<String, dynamic> json) => _$RecordMinesweeperFromJson(json);
}
