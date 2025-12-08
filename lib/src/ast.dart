/// Abstract Syntax Tree node definitions for math expressions.
library;

/// Base class for all expression nodes.
///
/// This is an abstract class rather than sealed to allow users to create
/// custom expression types for extension purposes.
abstract class Expression {
  const Expression();
}

/// A numeric literal value.
class NumberLiteral extends Expression {
  final double value;

  const NumberLiteral(this.value);

  @override
  String toString() => 'NumberLiteral($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberLiteral && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// A variable reference.
class Variable extends Expression {
  final String name;

  const Variable(this.name);

  @override
  String toString() => 'Variable($name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Variable && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

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

  const BinaryOp(this.left, this.operator, this.right);

  @override
  String toString() => 'BinaryOp($left, $operator, $right)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinaryOp &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          operator == other.operator &&
          right == other.right;

  @override
  int get hashCode => left.hashCode ^ operator.hashCode ^ right.hashCode;
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

/// A function call expression (e.g., \log{x}, \ln{x}, \sin{x}).
///
/// For functions with a subscript base like \log_{2}{x}, use [base].
class FunctionCall extends Expression {
  /// The function name (e.g., 'log', 'ln', 'sin').
  final String name;

  /// The function argument.
  final Expression argument;

  /// Optional base for functions like \log_{base}{arg}.
  final Expression? base;

  const FunctionCall(this.name, this.argument, {this.base});

  @override
  String toString() => base != null
      ? 'FunctionCall($name, base: $base, arg: $argument)'
      : 'FunctionCall($name, $argument)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCall &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          argument == other.argument &&
          base == other.base;

  @override
  int get hashCode => name.hashCode ^ argument.hashCode ^ (base?.hashCode ?? 0);
}

/// A limit expression: \lim_{variable \to target} body.
class LimitExpr extends Expression {
  /// The limit variable (e.g., 'x' in \lim_{x \to 0}).
  final String variable;

  /// The target value (e.g., 0 in \lim_{x \to 0}).
  final Expression target;

  /// The expression body to evaluate at the limit.
  final Expression body;

  const LimitExpr(this.variable, this.target, this.body);

  @override
  String toString() => 'LimitExpr($variable -> $target, $body)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitExpr &&
          runtimeType == other.runtimeType &&
          variable == other.variable &&
          target == other.target &&
          body == other.body;

  @override
  int get hashCode => variable.hashCode ^ target.hashCode ^ body.hashCode;
}

/// A summation expression: \sum_{variable=start}^{end} body.
class SumExpr extends Expression {
  /// The index variable (e.g., 'i' in \sum_{i=1}^{10}).
  final String variable;

  /// The starting value.
  final Expression start;

  /// The ending value.
  final Expression end;

  /// The expression body to sum.
  final Expression body;

  const SumExpr(this.variable, this.start, this.end, this.body);

  @override
  String toString() => 'SumExpr($variable=$start to $end, $body)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SumExpr &&
          runtimeType == other.runtimeType &&
          variable == other.variable &&
          start == other.start &&
          end == other.end &&
          body == other.body;

  @override
  int get hashCode =>
      variable.hashCode ^ start.hashCode ^ end.hashCode ^ body.hashCode;
}

/// A product expression: \prod_{variable=start}^{end} body.
class ProductExpr extends Expression {
  /// The index variable (e.g., 'i' in \prod_{i=1}^{5}).
  final String variable;

  /// The starting value.
  final Expression start;

  /// The ending value.
  final Expression end;

  /// The expression body to multiply.
  final Expression body;

  const ProductExpr(this.variable, this.start, this.end, this.body);

  @override
  String toString() => 'ProductExpr($variable=$start to $end, $body)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductExpr &&
          runtimeType == other.runtimeType &&
          variable == other.variable &&
          start == other.start &&
          end == other.end &&
          body == other.body;

  @override
  int get hashCode =>
      variable.hashCode ^ start.hashCode ^ end.hashCode ^ body.hashCode;
}

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
