/// Comparison and conditional evaluation logic.
library;

import '../ast.dart';
import '../exceptions.dart';

/// Handles evaluation of comparison and conditional expressions.
class ComparisonEvaluator {
  /// Callback to evaluate arbitrary expressions as doubles.
  final double Function(Expression, Map<String, double>) _evaluateAsDouble;

  /// Callback to evaluate arbitrary expressions (may return Matrix or double).
  final dynamic Function(Expression, Map<String, double>) _evaluate;

  /// Creates a comparison evaluator with callbacks for evaluating expressions.
  ComparisonEvaluator(this._evaluateAsDouble, this._evaluate);

  /// Evaluates a simple comparison expression.
  ///
  /// Returns 1.0 if true, NaN if false.
  double evaluateComparison(Comparison comp, Map<String, double> variables) {
    final left = _evaluateAsDouble(comp.left, variables);
    final right = _evaluateAsDouble(comp.right, variables);

    bool result;
    switch (comp.operator) {
      case ComparisonOperator.less:
        result = left < right;
        break;
      case ComparisonOperator.greater:
        result = left > right;
        break;
      case ComparisonOperator.lessEqual:
        result = left <= right;
        break;
      case ComparisonOperator.greaterEqual:
        result = left >= right;
        break;
      case ComparisonOperator.equal:
        // Use epsilon for float comparison
        result = (left - right).abs() < 1e-9;
        break;
    }

    return result ? 1.0 : double.nan;
  }

  /// Evaluates a chained comparison expression (e.g., a < b < c).
  ///
  /// Returns 1.0 if all comparisons are true, NaN otherwise.
  double evaluateChainedComparison(
      ChainedComparison chain, Map<String, double> variables) {
    // Evaluate all expressions in the chain
    final values =
        chain.expressions.map((e) => _evaluateAsDouble(e, variables)).toList();

    // Check each comparison in sequence
    for (int i = 0; i < chain.operators.length; i++) {
      final left = values[i];
      final right = values[i + 1];
      final op = chain.operators[i];

      bool result;
      switch (op) {
        case ComparisonOperator.less:
          result = left < right;
          break;
        case ComparisonOperator.greater:
          result = left > right;
          break;
        case ComparisonOperator.lessEqual:
          result = left <= right;
          break;
        case ComparisonOperator.greaterEqual:
          result = left >= right;
          break;
        case ComparisonOperator.equal:
          result = (left - right).abs() < 1e-9;
          break;
      }

      // If any comparison fails, return NaN
      if (!result) {
        return double.nan;
      }
    }

    // All comparisons passed
    return 1.0;
  }

  /// Evaluates a conditional expression.
  ///
  /// Returns the expression value if condition is satisfied, NaN otherwise.
  dynamic evaluateConditional(
      ConditionalExpr cond, Map<String, double> variables) {
    // Evaluate the condition first
    final conditionResult = _evaluateAsDouble(cond.condition, variables);

    // If condition is not satisfied (returns NaN or 0), return NaN
    if (conditionResult.isNaN || conditionResult == 0.0) {
      return double.nan;
    }

    // If condition is satisfied, evaluate and return the expression
    return _evaluate(cond.expression, variables);
  }
}
