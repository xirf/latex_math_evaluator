/// AST evaluator with variable binding support.
library;

import 'dart:math' as math;

import 'ast.dart';
import 'constants/constant_registry.dart';
import 'exceptions.dart';
import 'extensions.dart';
import 'functions/function_registry.dart';

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
  /// Returns the computed result as a double.
  ///
  /// Throws [EvaluatorException] if:
  /// - A variable is not found in the bindings
  /// - Division by zero occurs
  /// - An unknown expression type is encountered
  double evaluate(Expression expr, [Map<String, double> variables = const {}]) {
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
    } else if (expr is BinaryOp) {
      return _evaluateBinaryOp(expr.left, expr.operator, expr.right, variables);
    } else if (expr is UnaryOp) {
      return _evaluateUnaryOp(expr.operator, expr.operand, variables);
    } else if (expr is FunctionCall) {
      return _evaluateFunctionCall(expr, variables);
    } else if (expr is LimitExpr) {
      return _evaluateLimit(expr, variables);
    } else if (expr is SumExpr) {
      return _evaluateSum(expr, variables);
    } else if (expr is ProductExpr) {
      return _evaluateProduct(expr, variables);
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

  double _evaluateBinaryOp(
    Expression left,
    BinaryOperator operator,
    Expression right,
    Map<String, double> variables,
  ) {
    final leftValue = evaluate(left, variables);
    final rightValue = evaluate(right, variables);

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

  double _divide(double left, double right) {
    if (right == 0) {
      throw EvaluatorException('Division by zero');
    }
    return left / right;
  }

  double _evaluateUnaryOp(
    UnaryOperator operator,
    Expression operand,
    Map<String, double> variables,
  ) {
    final operandValue = evaluate(operand, variables);

    switch (operator) {
      case UnaryOperator.negate:
        return -operandValue;
    }
  }

  double _evaluateFunctionCall(FunctionCall func, Map<String, double> variables) {
    return FunctionRegistry.instance.evaluate(
      func,
      variables,
      (e) => evaluate(e, variables),
    );
  }

  double _evaluateLimit(LimitExpr limit, Map<String, double> variables) {
    final targetValue = evaluate(limit.target, variables);

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
        leftApproach = evaluate(limit.body, vars);
      } catch (_) {
        // Continue to next step
      }
    }

    // Approach from right
    for (final h in steps) {
      final vars = Map<String, double>.from(variables);
      vars[limit.variable] = targetValue + h;
      try {
        rightApproach = evaluate(limit.body, vars);
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
        lastValue = evaluate(limit.body, vars);
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
    final startVal = evaluate(sum.start, variables).toInt();
    final endVal = evaluate(sum.end, variables).toInt();

    double result = 0;
    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[sum.variable] = i.toDouble();
      result += evaluate(sum.body, vars);
    }

    return result;
  }

  double _evaluateProduct(ProductExpr prod, Map<String, double> variables) {
    final startVal = evaluate(prod.start, variables).toInt();
    final endVal = evaluate(prod.end, variables).toInt();

    double result = 1;
    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[prod.variable] = i.toDouble();
      result *= evaluate(prod.body, vars);
    }

    return result;
  }
}
