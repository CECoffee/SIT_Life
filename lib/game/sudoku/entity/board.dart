import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:sit/utils/list2d/list2d.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

part "board.g.dart";

const sudokuSides = 9;

@immutable
@JsonSerializable()
@CopyWith(skipFields: true)
class SudokuCell {
  /// A negative value (e.g., -1) indicates a pre-filled cell generated by the puzzle.
  /// The user cannot modify this value.
  /// `0` means the cell is empty and awaits user input.
  final int userInput;

  /// The correct value that the user should fill in the cell (1 to 9).
  final int correctValue;

  const SudokuCell({
    this.userInput = -1,
    this.correctValue = 0,
  }) : assert(correctValue == 0 || (1 <= correctValue && correctValue <= 9),
            "The puzzle should generate correct value in [1,9] but $correctValue");

  bool get isPuzzle => userInput < 0;

  bool get canUserInput => userInput >= 0;

  bool get emptyInput {
    assert(userInput >= 0, "Developer should check `isPuzzle` before access this");
    return userInput == 0;
  }

  bool get isSolved {
    assert(userInput >= 0, "Developer should check `isPuzzle` before access this");
    return userInput == correctValue;
  }

  @override
  bool operator ==(Object other) {
    return other is SudokuCell &&
        runtimeType == other.runtimeType &&
        userInput == other.userInput &&
        correctValue == other.correctValue;
  }

  @override
  int get hashCode => Object.hash(userInput, correctValue);

  factory SudokuCell.fromJson(Map<String, dynamic> json) => _$SudokuCellFromJson(json);

  Map<String, dynamic> toJson() => _$SudokuCellToJson(this);
}

@immutable
extension type const SudokuBoard(List2D<SudokuCell> cells) {
  factory SudokuBoard.generate({required int emptySquares}) {
    final generator = SudokuGenerator(emptySquares: emptySquares);
    final puzzle = generator.newSudoku;
    final solved = generator.newSudokuSolved;
    return SudokuBoard(List2D.generate(
      sudokuSides,
      sudokuSides,
      (row, column) => SudokuCell(
        userInput: puzzle[row][column] == 0 ? 0 : -1,
        correctValue: solved[row][column],
      ),
    ));
  }

  factory SudokuBoard.byDefault() {
    return SudokuBoard(
      List2D.generate(
        sudokuSides,
        sudokuSides,
        (row, column) => const SudokuCell(),
      ),
    );
  }

  bool get isSolved {
    for (final cell in cells) {
      if (cell.isPuzzle) continue;
      if (!cell.isSolved) return false;
    }
    return true;
  }

  factory SudokuBoard.fromJson(dynamic json) {
    return SudokuBoard(
      List2D<SudokuCell>.fromJson(json, (value) => SudokuCell.fromJson(value as Map<String, dynamic>)),
    );
  }

  dynamic toJson() {
    return cells;
  }
}
