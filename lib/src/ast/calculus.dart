import 'expression.dart';

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
