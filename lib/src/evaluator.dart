/// AST evaluator with variable binding support.
library;

import 'ast.dart';
import 'constants/constant_registry.dart';
import 'evaluator/binary_evaluator.dart';
import 'evaluator/calculus_evaluator.dart';
import 'evaluator/comparison_evaluator.dart';
import 'evaluator/matrix_evaluator.dart';
import 'evaluator/unary_evaluator.dart';
import 'exceptions.dart';
import 'extensions.dart';
import 'functions/function_registry.dart';
import 'matrix.dart';

/// Evaluates an expression tree with variable bindings.
class Evaluator {
  final ExtensionRegistry? _extensions;
  late final BinaryEvaluator _binaryEvaluator;
  late final UnaryEvaluator _unaryEvaluator;
  late final CalculusEvaluator _calculusEvaluator;
  late final ComparisonEvaluator _comparisonEvaluator;
  late final MatrixEvaluator _matrixEvaluator;

  /// Creates an evaluator with optional extension registry.
  Evaluator({ExtensionRegistry? extensions}) : _extensions = extensions {
    _binaryEvaluator = BinaryEvaluator();
    _unaryEvaluator = UnaryEvaluator();
    _calculusEvaluator = CalculusEvaluator(_evaluateAsDouble);
    _comparisonEvaluator = ComparisonEvaluator(_evaluateAsDouble, evaluate);
    _matrixEvaluator = MatrixEvaluator(evaluate);
  }

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
  dynamic evaluate(Expression expr,
      [Map<String, double> variables = const {}]) {
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
      return _matrixEvaluator.evaluate(expr, variables);
    } else if (expr is BinaryOp) {
      return _evaluateBinaryOp(expr, variables);
    } else if (expr is UnaryOp) {
      final operandValue = evaluate(expr.operand, variables);
      return _unaryEvaluator.evaluate(expr.operator, operandValue);
    } else if (expr is AbsoluteValue) {
      final val = evaluate(expr.argument, variables);
      if (val is double) return val.abs();
      throw EvaluatorException(
        'Absolute value not supported for this type',
        suggestion:
            'Absolute value can only be used with numbers, not matrices',
      );
    } else if (expr is FunctionCall) {
      return _evaluateFunctionCall(expr, variables);
    } else if (expr is LimitExpr) {
      return _calculusEvaluator.evaluateLimit(expr, variables);
    } else if (expr is SumExpr) {
      return _calculusEvaluator.evaluateSum(expr, variables);
    } else if (expr is ProductExpr) {
      return _calculusEvaluator.evaluateProduct(expr, variables);
    } else if (expr is IntegralExpr) {
      return _calculusEvaluator.evaluateIntegral(expr, variables);
    } else if (expr is Comparison) {
      return _comparisonEvaluator.evaluateComparison(expr, variables);
    } else if (expr is ChainedComparison) {
      return _comparisonEvaluator.evaluateChainedComparison(expr, variables);
    } else if (expr is ConditionalExpr) {
      return _comparisonEvaluator.evaluateConditional(expr, variables);
    }

    throw EvaluatorException(
      'Unknown expression type: ${expr.runtimeType}',
      suggestion: 'This is likely a bug in the parser or evaluator',
    );
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

    throw EvaluatorException(
      'Undefined variable: $name',
      suggestion: 'Provide a value for "$name" in the variables map',
    );
  }

  double _evaluateAsDouble(Expression expr, Map<String, double> variables) {
    final val = evaluate(expr, variables);
    if (val is double) return val;
    throw EvaluatorException(
      'Expression must evaluate to a number',
      suggestion: 'This operation requires a numeric value, not a matrix',
    );
  }

  dynamic _evaluateBinaryOp(BinaryOp expr, Map<String, double> variables) {
    final leftValue = evaluate(expr.left, variables);

    // Special handling for Matrix Transpose: M^T
    // Don't evaluate 'T' as a variable
    if (leftValue is Matrix &&
        expr.operator == BinaryOperator.power &&
        expr.right is Variable &&
        (expr.right as Variable).name == 'T') {
      return _binaryEvaluator.evaluate(
          leftValue, expr.operator, null, expr.right);
    }

    final rightValue = evaluate(expr.right, variables);
    return _binaryEvaluator.evaluate(
        leftValue, expr.operator, rightValue, expr.right);
  }

  dynamic _evaluateFunctionCall(
      FunctionCall func, Map<String, double> variables) {
    return FunctionRegistry.instance.evaluate(
      func,
      variables,
      (e) => evaluate(e, variables),
    );
  }
}
