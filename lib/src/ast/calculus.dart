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
  String toLatex() =>
      '\\lim_{$variable \\to ${target.toLatex()}}{${body.toLatex()}}';

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
  String toLatex() =>
      '\\sum_{$variable=${start.toLatex()}}^{${end.toLatex()}}{${body.toLatex()}}';

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
  String toLatex() =>
      '\\prod_{$variable=${start.toLatex()}}^{${end.toLatex()}}{${body.toLatex()}}';

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

/// An integral expression: \int_{lower}^{upper} body dx.
class IntegralExpr extends Expression {
  /// The lower bound of the integral.
  final Expression lower;

  /// The upper bound of the integral.
  final Expression upper;

  /// The expression body to integrate.
  final Expression body;

  /// The variable of integration (e.g., 'x' in dx).
  final String variable;

  const IntegralExpr(this.lower, this.upper, this.body, this.variable);

  @override
  String toString() => 'IntegralExpr($lower to $upper, $body d$variable)';

  @override
  String toLatex() =>
      '\\int_{${lower.toLatex()}}^{${upper.toLatex()}}{${body.toLatex()}} d$variable';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntegralExpr &&
          runtimeType == other.runtimeType &&
          lower == other.lower &&
          upper == other.upper &&
          body == other.body &&
          variable == other.variable;

  @override
  int get hashCode =>
      lower.hashCode ^ upper.hashCode ^ body.hashCode ^ variable.hashCode;
}

/// A derivative expression: \frac{d}{dx} body or \frac{d^n}{dx^n} body.
class DerivativeExpr extends Expression {
  /// The expression body to differentiate.
  final Expression body;

  /// The variable to differentiate with respect to (e.g., 'x' in d/dx).
  final String variable;

  /// The order of differentiation (1 for first derivative, 2 for second, etc.).
  final int order;

  const DerivativeExpr(this.body, this.variable, {this.order = 1});

  @override
  String toString() {
    if (order == 1) {
      return 'DerivativeExpr(d/d$variable, $body)';
    }
    return 'DerivativeExpr(d^$order/d$variable^$order, $body)';
  }

  @override
  String toLatex() {
    if (order == 1) {
      return '\\frac{d}{d$variable}{${body.toLatex()}}';
    }
    return '\\frac{d^{$order}}{d$variable^{$order}}{${body.toLatex()}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DerivativeExpr &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          variable == other.variable &&
          order == other.order;

  @override
  int get hashCode => body.hashCode ^ variable.hashCode ^ order.hashCode;
}
