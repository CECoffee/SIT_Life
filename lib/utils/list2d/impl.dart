import 'dart:collection';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import 'view.dart';

part 'impl.g.dart';

@immutable
@JsonSerializable(genericArgumentFactories: true)
class List2D<T> with Iterable<T> {
  @JsonKey(name: "internal", includeFromJson: true, includeToJson: true)
  final List<T> _internal;
  final int rows;
  final int columns;

  const List2D([
    this.rows = 0,
    this.columns = 0,
    this._internal = const [],
  ]);

  factory List2D.generate(int rows, int columns, T Function(int row, int column, int index) generator) {
    return List2D(
      rows,
      columns,
      List.generate(
        rows * columns,
        (index) => generator(
          _rowOf(index, columns),
          _columnOf(index, columns),
          index,
        ),
        growable: false,
      ),
    );
  }

  factory List2D.of(List2D<T> others) {
    return List2D(
      others.rows,
      others.columns,
      List.of(others._internal, growable: false),
    );
  }

  factory List2D.from1D(int rows, int columns, List<T> list1D) {
    if (list1D.length != rows * columns) {
      throw ArgumentError.value(list1D, "list1D", "The length of list1D must be the product of rows and columns");
    }
    return List2D(
      rows,
      columns,
      List.generate(
        rows * columns,
        (index) => list1D[index],
        growable: false,
      ),
    );
  }

  factory List2D.from2D(List<List<T>> list2d) {
    final rows = list2d.length;
    var columns = list2d.firstOrNull?.length ?? 0;
    for (final row in list2d) {
      assert(columns == row.length, "The length of each row should be the same.");
      columns = min(columns, row.length);
    }
    return List2D(
      rows,
      columns,
      List.generate(
        rows * columns,
        (index) => list2d[_rowOf(index, columns)][_columnOf(index, columns)],
      ),
    );
  }

  T get(int row, int column) {
    return _internal[_indexBy(row, column, columns)];
  }

  void set(int row, int column, T value) {
    _internal[_indexBy(row, column, columns)] = value;
  }

  @override
  Iterator<T> get iterator => _internal.iterator;

  @override
  List2D<E> map<E>(E Function(T e) toElement) {
    return List2D.generate(
      rows,
      columns,
      (row, column, index) => toElement(get(row, column)),
    );
  }

  Map<String, dynamic> toJson(
    Object? Function(T value) toJsonT,
  ) =>
      _$List2DToJson<T>(this, toJsonT);

  factory List2D.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$List2DFromJson<T>(json, fromJsonT);
}

@pragma("vm:prefer-inline")
int _rowOf(int index, int columns) {
  return index ~/ columns;
}

@pragma("vm:prefer-inline")
int _columnOf(int index, int columns) {
  return index % columns;
}

@pragma("vm:prefer-inline")
int _indexBy(int row, int column, int columns) {
  return row * columns + column;
}

extension List2dImplX<T> on List2D<T> {
  List2D<E> mapIndexed<E>(E Function(int row, int column, int index, T e) toElement) {
    return List2D.generate(
      rows,
      columns,
      (row, column, index) => toElement(row, column, index, get(row, column)),
    );
  }

  List2DView<T> subview({
    int rowOffset = 0,
    int columnOffset = 0,
    required int rows,
    required int columns,
  }) {
    return List2DView(
      parent: this,
      rowOffset: rowOffset,
      columnOffset: columnOffset,
      rows: rows,
      columns: columns,
    );
  }

  @pragma("vm:prefer-inline")
  operator []((int, int) index) {
    return get(index.$1, index.$2);
  }

  @pragma("vm:prefer-inline")
  operator []=((int, int) index, T value) {
    return set(index.$1, index.$2, value);
  }

  Iterable<T> rowAt(int row) sync* {
    for (var c = 0; c < columns; c++) {
      yield get(row, c);
    }
  }

  Iterable<T> columnAt(int column) sync* {
    for (var r = 0; r < rows; r++) {
      yield get(r, column);
    }
  }

  List<List<T>> to2DList({bool growable = true}) {
    return List.generate(
      rows,
      (row) => rowAt(row).toList(
        growable: growable,
      ),
      growable: growable,
    );
  }

  @pragma("vm:prefer-inline")
  int getRowFrom(int index1D) => _rowOf(index1D, columns);

  @pragma("vm:prefer-inline")
  int getColumnFrom(int index1D) => _columnOf(index1D, columns);

  @pragma("vm:prefer-inline")
  T getByIndex(int index1D) {
    return get(getRowFrom(index1D), getColumnFrom(index1D));
  }

  @pragma("vm:prefer-inline")
  void setByIndex(int index1D, T value) {
    return set(getRowFrom(index1D), getColumnFrom(index1D), value);
  }

  Iterable<T> iterateRowStartWith(
    int row,
    int column, {
    bool incremental = true,
    bool throughBoundary = true,
  }) sync* {
    if (incremental) {
      for (var c = column; c < columns; c++) {
        yield get(row, c);
      }
      if (throughBoundary) {
        for (var c = 0; c < column; c++) {
          yield get(row, c);
        }
      }
    } else {
      for (var c = column; c >= 0; c--) {
        yield get(row, c);
      }
      if (throughBoundary) {
        for (var c = columns - 1; c > column; c--) {
          yield get(row, c);
        }
      }
    }
  }

  Iterable<T> iterateColumnStartWith(
    int row,
    int column, {
    bool incremental = true,
    bool throughBoundary = true,
  }) sync* {
    if (incremental) {
      for (var r = row; r < rows; r++) {
        yield get(r, column);
      }
      if (throughBoundary) {
        for (var r = 0; r < row; r++) {
          yield get(r, column);
        }
      }
    } else {
      for (var r = row; r >= 0; r--) {
        yield get(r, column);
      }
      if (throughBoundary) {
        for (var r = rows - 1; r > row; r--) {
          yield get(r, column);
        }
      }
    }
  }
}
