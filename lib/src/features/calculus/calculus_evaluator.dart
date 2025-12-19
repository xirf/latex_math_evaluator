/// Calculus operations evaluation logic (limits, sums, products, integrals).
library;

import '../../ast.dart';
import '../../exceptions.dart';

/// Handles evaluation of calculus operations.
class CalculusEvaluator {
  /// Callback to evaluate arbitrary expressions.
  final double Function(Expression, Map<String, double>) _evaluateAsDouble;

  /// Creates a calculus evaluator with a callback for evaluating expressions.
  CalculusEvaluator(this._evaluateAsDouble);

  /// Maximum allowed iterations for sums and products.
  static const int maxIterations = 100000;

  void _checkIterations(int start, int end) {
    if (end < start) return; // Loop won't execute
    final count = end - start + 1;
    if (count > maxIterations) {
      throw EvaluatorException(
        'Iteration limit exceeded: $count iterations (max $maxIterations)',
        suggestion:
            'Reduce the range of your sum or product to fewer than $maxIterations iterations',
      );
    }
  }

  /// Evaluates a limit expression.
  double evaluateLimit(LimitExpr limit, Map<String, double> variables) {
    final targetValue = _evaluateAsDouble(limit.target, variables);

    // Handle infinity
    if (targetValue.isInfinite) {
      return _evaluateLimitAtInfinity(limit, variables, targetValue > 0);
    }

    // Numeric approximation: evaluate approaching from both sides
    const epsilon = 1e-10;
    const steps = [1e-1, 1e-3, 1e-5, 1e-7, 1e-9];

    double? leftApproach;
    double? rightApproach;

    // Approach from left
    for (final h in steps) {
      final vars = Map<String, double>.from(variables);
      vars[limit.variable] = targetValue - h;
      try {
        leftApproach = _evaluateAsDouble(limit.body, vars);
      } catch (_) {
        // Continue to next step
      }
    }

    // Approach from right
    for (final h in steps) {
      final vars = Map<String, double>.from(variables);
      vars[limit.variable] = targetValue + h;
      try {
        rightApproach = _evaluateAsDouble(limit.body, vars);
      } catch (_) {
        // Continue to next step
      }
    }

    // If both sides converge to similar values
    if (leftApproach != null && rightApproach != null) {
      if ((leftApproach - rightApproach).abs() < epsilon) {
        return (leftApproach + rightApproach) / 2;
      }
    }

    // If only one side works, use that
    if (leftApproach != null) return leftApproach;
    if (rightApproach != null) return rightApproach;

    throw EvaluatorException(
      'Limit does not exist or cannot be computed',
      suggestion:
          'The limit may not converge or may have different left/right limits',
    );
  }

  double _evaluateLimitAtInfinity(
    LimitExpr limit,
    Map<String, double> variables,
    bool positive,
  ) {
    const steps = [1e2, 1e4, 1e6, 1e8];
    double? lastValue;

    for (final n in steps) {
      final vars = Map<String, double>.from(variables);
      vars[limit.variable] = positive ? n : -n;
      try {
        lastValue = _evaluateAsDouble(limit.body, vars);
      } catch (_) {
        // Continue
      }
    }

    if (lastValue != null) {
      return lastValue;
    }

    throw EvaluatorException(
      'Limit at infinity cannot be computed',
      suggestion: 'The expression may not have a limit at infinity',
    );
  }

  /// Evaluates a summation expression.
  double evaluateSum(SumExpr sum, Map<String, double> variables) {
    final startVal = _evaluateAsDouble(sum.start, variables).toInt();
    final endVal = _evaluateAsDouble(sum.end, variables).toInt();

    _checkIterations(startVal, endVal);

    double result = 0;
    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[sum.variable] = i.toDouble();
      result += _evaluateAsDouble(sum.body, vars);
    }

    return result;
  }

  /// Evaluates a product expression.
  double evaluateProduct(ProductExpr prod, Map<String, double> variables) {
    final startVal = _evaluateAsDouble(prod.start, variables).toInt();
    final endVal = _evaluateAsDouble(prod.end, variables).toInt();

    _checkIterations(startVal, endVal);

    double result = 1;
    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[prod.variable] = i.toDouble();
      result *= _evaluateAsDouble(prod.body, vars);
    }

    return result;
  }

  /// Evaluates an integral expression using Simpson's rule.
  /// Evaluates an integral expression using Simpson's rule.
  double evaluateIntegral(IntegralExpr expr, Map<String, double> variables) {
    if (expr.lower == null || expr.upper == null) {
      throw EvaluatorException(
        'Cannot numerically evaluate indefinite integral',
        suggestion:
            'Provide lower and upper bounds for numerical integration (e.g., \\int_{0}^{1})',
      );
    }

    final lower = _evaluateAsDouble(expr.lower!, variables);
    final upper = _evaluateAsDouble(expr.upper!, variables);

    final n = 1000; // Number of intervals (must be even for Simpson's)
    final h = (upper - lower) / n;

    double sum = 0.0;

    // Helper to evaluate body at x
    double f(double x) {
      final newVars = Map<String, double>.from(variables);
      newVars[expr.variable] = x;
      return _evaluateAsDouble(expr.body, newVars);
    }

    // Simpson's Rule
    sum += f(lower);
    sum += f(upper);

    for (var i = 1; i < n; i++) {
      final x = lower + i * h;
      if (i % 2 == 0) {
        sum += 2 * f(x);
      } else {
        sum += 4 * f(x);
      }
    }

    return (h / 3) * sum;
  }
}
