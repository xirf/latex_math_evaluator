import 'expression.dart';

/// Comparison operation types.
enum ComparisonOperator {
  less,
  greater,
  lessEqual,
  greaterEqual,
  equal,
}

/// A comparison operation (left op right).
class Comparison extends Expression {
  final Expression left;
  final ComparisonOperator operator;
  final Expression right;

  const Comparison(this.left, this.operator, this.right);

  @override
  String toString() => 'Comparison($left, $operator, $right)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comparison &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          operator == other.operator &&
          right == other.right;

  @override
  int get hashCode => left.hashCode ^ operator.hashCode ^ right.hashCode;
}

/// A conditional expression with a condition constraint.
/// Example: x^2 - 2 where -1 < x < 2
class ConditionalExpr extends Expression {
  /// The main expression to evaluate
  final Expression expression;

  /// The condition that must be satisfied
  final Expression condition;

  const ConditionalExpr(this.expression, this.condition);

  @override
  String toString() => 'ConditionalExpr($expression, condition: $condition)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConditionalExpr &&
          runtimeType == other.runtimeType &&
          expression == other.expression &&
          condition == other.condition;

  @override
  int get hashCode => expression.hashCode ^ condition.hashCode;
}

/// A chained comparison expression.
/// Example: -1 < x < 2 (evaluates as -1 < x AND x < 2)
class ChainedComparison extends Expression {
  /// The list of expressions in the chain
  final List<Expression> expressions;

  /// The list of operators between expressions
  final List<ComparisonOperator> operators;

  const ChainedComparison(this.expressions, this.operators);

  @override
  String toString() => 'ChainedComparison($expressions, $operators)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainedComparison &&
          runtimeType == other.runtimeType &&
          _listEquals(expressions, other.expressions) &&
          _listEquals(operators, other.operators);

  @override
  int get hashCode => expressions.hashCode ^ operators.hashCode;

  static bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
