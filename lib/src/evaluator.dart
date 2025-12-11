/// AST evaluator with variable binding support.
library;

import 'dart:math' as math;

import 'ast.dart';
import 'constants/constant_registry.dart';
import 'exceptions.dart';
import 'extensions.dart';
import 'functions/function_registry.dart';
import 'matrix.dart';

/// Evaluates an expression tree with variable bindings.
class Evaluator {
  final ExtensionRegistry? _extensions;

  /// Creates an evaluator with optional extension registry.
  Evaluator({ExtensionRegistry? extensions}) : _extensions = extensions;

  /// Evaluates the given expression using the provided variable bindings.
  ///
  /// [expr] is the expression to evaluate.
  /// [variables] is a map of variable names to their values.
  ///
  /// Returns the computed result as a [double] or [Matrix].
  ///
  /// Throws [EvaluatorException] if:
  /// - A variable is not found in the bindings
  /// - Division by zero occurs
  /// - An unknown expression type is encountered
  dynamic evaluate(Expression expr, [Map<String, double> variables = const {}]) {
    // Try custom evaluators first
    if (_extensions != null) {
      final result = _extensions!.tryEvaluate(
        expr,
        variables,
        (e) => evaluate(e, variables),
      );
      if (result != null) {
        return result;
      }
    }

    // Built-in evaluation
    if (expr is NumberLiteral) {
      return expr.value;
    } else if (expr is Variable) {
      return _lookupVariable(expr.name, variables);
    } else if (expr is MatrixExpr) {
      return _evaluateMatrix(expr, variables);
    } else if (expr is BinaryOp) {
      return _evaluateBinaryOp(expr.left, expr.operator, expr.right, variables);
    } else if (expr is UnaryOp) {
      return _evaluateUnaryOp(expr.operator, expr.operand, variables);
    } else if (expr is AbsoluteValue) {
      final val = evaluate(expr.argument, variables);
      if (val is double) return val.abs();
      throw EvaluatorException('Absolute value not supported for this type');
    } else if (expr is FunctionCall) {
      return _evaluateFunctionCall(expr, variables);
    } else if (expr is LimitExpr) {
      return _evaluateLimit(expr, variables);
    } else if (expr is SumExpr) {
      return _evaluateSum(expr, variables);
    } else if (expr is ProductExpr) {
      return _evaluateProduct(expr, variables);
    } else if (expr is IntegralExpr) {
      return _evaluateIntegral(expr, variables);
    } else if (expr is Comparison) {
      return _evaluateComparison(expr, variables);
    } else if (expr is ChainedComparison) {
      return _evaluateChainedComparison(expr, variables);
    } else if (expr is ConditionalExpr) {
      return _evaluateConditional(expr, variables);
    }

    throw EvaluatorException('Unknown expression type: ${expr.runtimeType}');
  }

  double _lookupVariable(String name, Map<String, double> variables) {
    // First check user-provided variables
    if (variables.containsKey(name)) {
      return variables[name]!;
    }
    
    // Fall back to built-in constants
    final constant = ConstantRegistry.instance.get(name);
    if (constant != null) {
      return constant;
    }
    
    throw EvaluatorException('Undefined variable: $name');
  }

  Matrix _evaluateMatrix(MatrixExpr matrix, Map<String, double> variables) {
    final rows = matrix.rows.map((row) {
      return row.map((cell) {
        final val = evaluate(cell, variables);
        if (val is! double) {
          throw EvaluatorException('Matrix elements must evaluate to numbers');
        }
        return val;
      }).toList();
    }).toList();
    return Matrix(rows);
  }

  dynamic _evaluateBinaryOp(
    Expression left,
    BinaryOperator operator,
    Expression right,
    Map<String, double> variables,
  ) {
    final leftValue = evaluate(left, variables);

    // Special handling for Matrix Transpose: M^T
    if (leftValue is Matrix && operator == BinaryOperator.power && right is Variable && right.name == 'T') {
       return leftValue.transpose();
    }

    final rightValue = evaluate(right, variables);

    if (leftValue is Matrix && rightValue is Matrix) {
      switch (operator) {
        case BinaryOperator.add:
          return leftValue + rightValue;
        case BinaryOperator.subtract:
          return leftValue - rightValue;
        case BinaryOperator.multiply:
          return leftValue * rightValue;
        default:
          throw EvaluatorException('Operator $operator not supported for matrices');
      }
    } else if (leftValue is Matrix && rightValue is num) {
      switch (operator) {
        case BinaryOperator.multiply:
          return leftValue * rightValue;
        case BinaryOperator.power:
          if (rightValue == -1) {
            return leftValue.inverse();
          }
          throw EvaluatorException('Matrix power only supports -1 (inverse) or T (transpose)');
        default:
          throw EvaluatorException('Operator $operator not supported for matrix and scalar');
      }
    } else if (leftValue is num && rightValue is Matrix) {
      switch (operator) {
        case BinaryOperator.multiply:
          return rightValue * leftValue;
        default:
          throw EvaluatorException('Operator $operator not supported for scalar and matrix');
      }
    } else if (leftValue is double && rightValue is double) {
      switch (operator) {
        case BinaryOperator.add:
          return leftValue + rightValue;
        case BinaryOperator.subtract:
          return leftValue - rightValue;
        case BinaryOperator.multiply:
          return leftValue * rightValue;
        case BinaryOperator.divide:
          return _divide(leftValue, rightValue);
        case BinaryOperator.power:
          return math.pow(leftValue, rightValue).toDouble();
      }
    }

    throw EvaluatorException('Type mismatch in binary operation');
  }

  double _divide(double left, double right) {
    if (right == 0) {
      throw EvaluatorException('Division by zero');
    }
    return left / right;
  }

  dynamic _evaluateUnaryOp(
    UnaryOperator operator,
    Expression operand,
    Map<String, double> variables,
  ) {
    final operandValue = evaluate(operand, variables);

    if (operandValue is Matrix) {
      if (operator == UnaryOperator.negate) {
        return operandValue * -1;
      }
      throw EvaluatorException('Operator $operator not supported for matrix');
    }

    if (operandValue is double) {
      switch (operator) {
        case UnaryOperator.negate:
          return -operandValue;
      }
    }

    throw EvaluatorException('Type mismatch in unary operation');
  }

  double _evaluateAsDouble(Expression expr, Map<String, double> variables) {
    final val = evaluate(expr, variables);
    if (val is double) return val;
    throw EvaluatorException('Expression must evaluate to a number');
  }

  dynamic _evaluateFunctionCall(FunctionCall func, Map<String, double> variables) {
    return FunctionRegistry.instance.evaluate(
      func,
      variables,
      (e) => evaluate(e, variables),
    );
  }

  double _evaluateLimit(LimitExpr limit, Map<String, double> variables) {
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

    throw EvaluatorException('Limit does not exist or cannot be computed');
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

    throw EvaluatorException('Limit at infinity cannot be computed');
  }

  double _evaluateSum(SumExpr sum, Map<String, double> variables) {
    final startVal = _evaluateAsDouble(sum.start, variables).toInt();
    final endVal = _evaluateAsDouble(sum.end, variables).toInt();

    double result = 0;
    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[sum.variable] = i.toDouble();
      result += _evaluateAsDouble(sum.body, vars);
    }

    return result;
  }

  double _evaluateProduct(ProductExpr prod, Map<String, double> variables) {
    final startVal = _evaluateAsDouble(prod.start, variables).toInt();
    final endVal = _evaluateAsDouble(prod.end, variables).toInt();

    double result = 1;
    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[prod.variable] = i.toDouble();
      result *= _evaluateAsDouble(prod.body, vars);
    }

    return result;
  }

  double _evaluateIntegral(IntegralExpr expr, Map<String, double> variables) {
    final lower = _evaluateAsDouble(expr.lower, variables);
    final upper = _evaluateAsDouble(expr.upper, variables);

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

  double _evaluateComparison(Comparison comp, Map<String, double> variables) {
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
        // Use epsilon for float comparison?
        result = (left - right).abs() < 1e-9;
        break;
    }

    return result ? 1.0 : double.nan;
  }

  double _evaluateChainedComparison(ChainedComparison chain, Map<String, double> variables) {
    // Evaluate all expressions in the chain
    final values = chain.expressions.map((e) => _evaluateAsDouble(e, variables)).toList();
    
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

  dynamic _evaluateConditional(ConditionalExpr cond, Map<String, double> variables) {
    // Evaluate the condition first
    final conditionResult = _evaluateAsDouble(cond.condition, variables);
    
    // If condition is not satisfied (returns NaN or 0), return NaN
    if (conditionResult.isNaN || conditionResult == 0.0) {
      return double.nan;
    }
    
    // If condition is satisfied, evaluate and return the expression
    return evaluate(cond.expression, variables);
  }
}

