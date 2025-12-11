import 'expression.dart';

/// A matrix expression.
class MatrixExpr extends Expression {
  final List<List<Expression>> rows;

  const MatrixExpr(this.rows);

  @override
  String toString() => 'MatrixExpr($rows)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatrixExpr &&
          runtimeType == other.runtimeType &&
          _rowsEquals(rows, other.rows);

  @override
  int get hashCode => Object.hashAll(rows.expand((row) => row));

  static bool _rowsEquals(List<List<Expression>> a, List<List<Expression>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_listEquals(a[i], b[i])) return false;
    }
    return true;
  }

  static bool _listEquals(List<Expression> a, List<Expression> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
