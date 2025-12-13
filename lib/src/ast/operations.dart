import 'expression.dart';

/// Binary operation types.
enum BinaryOperator {
  add,
  subtract,
  multiply,
  divide,
  power,
}

/// A binary operation (left op right).
class BinaryOp extends Expression {
  final Expression left;
  final BinaryOperator operator;
  final Expression right;
  /// The source token value (e.g., '\times', '\cdot', '*') for disambiguation.
  final String? sourceToken;

  const BinaryOp(this.left, this.operator, this.right, {this.sourceToken});

  @override
  String toString() => 'BinaryOp($left, $operator, $right)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinaryOp &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          operator == other.operator &&
          right == other.right &&
          sourceToken == other.sourceToken;

  @override
  int get hashCode => left.hashCode ^ operator.hashCode ^ right.hashCode ^ (sourceToken?.hashCode ?? 0);
}

/// Unary operation types.
enum UnaryOperator {
  negate,
}

/// A unary operation (op operand).
class UnaryOp extends Expression {
  final UnaryOperator operator;
  final Expression operand;

  const UnaryOp(this.operator, this.operand);

  @override
  String toString() => 'UnaryOp($operator, $operand)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnaryOp &&
          runtimeType == other.runtimeType &&
          operator == other.operator &&
          operand == other.operand;

  @override
  int get hashCode => operator.hashCode ^ operand.hashCode;
}
