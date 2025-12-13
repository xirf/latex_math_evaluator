/// AST evaluator with variable binding support.
library;

import 'ast.dart';
import 'complex.dart';
import 'constants/constant_registry.dart';
import 'evaluation_result.dart';
import 'evaluator/binary_evaluator.dart';
import 'evaluator/calculus_evaluator.dart';
import 'evaluator/comparison_evaluator.dart';
import 'evaluator/differentiation_evaluator.dart';
import 'evaluator/matrix_evaluator.dart';
import 'evaluator/unary_evaluator.dart';
import 'exceptions.dart';
import 'extensions.dart';
import 'functions/function_registry.dart';
import 'matrix.dart';
import 'vector.dart';

/// Evaluates an expression tree with variable bindings.
///
/// The [Evaluator] class is the core component for calculating the result of
/// parsed mathematical expressions. It supports:
/// - Basic arithmetic operations (+, -, *, /, ^)
/// - Function calls (sin, cos, log, etc.)
/// - Variable bindings
/// - Matrix operations
/// - Complex number operations
/// - Custom extensions via [ExtensionRegistry]
///
/// Example:
/// ```dart
/// final evaluator = Evaluator();
/// final expr = Parser(Tokenizer('2 + x').tokenize()).parse();
/// final result = evaluator.evaluate(expr, {'x': 3});
/// print(result.asNumeric()); // 5.0
/// ```
class Evaluator {
  final ExtensionRegistry? _extensions;
  late final BinaryEvaluator _binaryEvaluator;
  late final UnaryEvaluator _unaryEvaluator;
  late final CalculusEvaluator _calculusEvaluator;
  late final ComparisonEvaluator _comparisonEvaluator;
  late final MatrixEvaluator _matrixEvaluator;
  late final DifferentiationEvaluator _differentiationEvaluator;

  /// Creates an evaluator with optional extension registry.
  ///
  /// [extensions] allows adding custom functions and variables to the evaluator.
  Evaluator({ExtensionRegistry? extensions}) : _extensions = extensions {
    _binaryEvaluator = BinaryEvaluator();
    _unaryEvaluator = UnaryEvaluator();
    _calculusEvaluator = CalculusEvaluator(_evaluateAsDouble);
    _comparisonEvaluator = ComparisonEvaluator(_evaluateAsDouble, _evaluateRaw);
    _matrixEvaluator = MatrixEvaluator(_evaluateRaw);
    _differentiationEvaluator = DifferentiationEvaluator(_evaluateAsDouble);
  }

  /// Gets the differentiation evaluator (for internal use by public API).
  DifferentiationEvaluator get differentiationEvaluator =>
      _differentiationEvaluator;

  /// Evaluates the given expression using the provided variable bindings.
  ///
  /// [expr] is the expression tree to evaluate.
  /// [variables] is a map of variable names to their values.
  ///
  /// Returns the computed result as an [EvaluationResult], which can be
  /// either a [NumericResult], [ComplexResult], or [MatrixResult].
  ///
  /// Throws [EvaluatorException] if:
  /// - A variable is not found in the bindings
  /// - Division by zero occurs
  /// - An unknown expression type is encountered
  /// - Type mismatch (e.g. adding a number to a matrix)
  EvaluationResult evaluate(Expression expr,
      [Map<String, double> variables = const {}]) {
    // Try custom evaluators first
    if (_extensions != null) {
      final result = _extensions!.tryEvaluate(
        expr,
        variables,
        (e) => _evaluateRaw(e, variables),
      );
      if (result != null) {
        return _wrapResult(result);
      }
    }

    final rawResult = _evaluateRaw(expr, variables);
    return _wrapResult(rawResult);
  }

  /// Internal method that evaluates an expression and returns dynamic result.
  ///
  /// This is used internally to maintain backward compatibility with existing
  /// evaluator code that returns double, Complex, or Matrix.
  dynamic _evaluateRaw(Expression expr,
      [Map<String, double> variables = const {}]) {
    // Try custom evaluators first
    if (_extensions != null) {
      final result = _extensions!.tryEvaluate(
        expr,
        variables,
        (e) => _evaluateRaw(e, variables),
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
    } else if (expr is VectorExpr) {
      // Evaluate all components
      final evalComponents =
          expr.components.map((c) => _evaluateAsDouble(c, variables)).toList();
      final vec = Vector(evalComponents);
      // If it's marked as a unit vector (\hat{}), normalize it
      return expr.isUnitVector ? vec.normalize() : vec;
    } else if (expr is BinaryOp) {
      return _evaluateBinaryOp(expr, variables);
    } else if (expr is UnaryOp) {
      final operandValue = _evaluateRaw(expr.operand, variables);
      return _unaryEvaluator.evaluate(expr.operator, operandValue);
    } else if (expr is AbsoluteValue) {
      final val = _evaluateRaw(expr.argument, variables);
      if (val is double) return val.abs();
      if (val is Complex) return val.abs;
      if (val is Vector) return val.magnitude;
      throw EvaluatorException(
        'Absolute value not supported for this type',
        suggestion:
            'Absolute value can be used with numbers, complex numbers, or vectors, but not matrices',
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
    } else if (expr is DerivativeExpr) {
      return _differentiationEvaluator.evaluateDerivative(expr, variables);
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

  /// Wraps a raw dynamic result into an EvaluationResult.
  EvaluationResult _wrapResult(dynamic result) {
    if (result is double) {
      return NumericResult(result);
    } else if (result is Complex) {
      return ComplexResult(result);
    } else if (result is Matrix) {
      return MatrixResult(result);
    } else if (result is Vector) {
      return VectorResult(result);
    } else {
      throw EvaluatorException(
        'Invalid result type: ${result.runtimeType}',
        suggestion:
            'Results must be either a number, complex number, matrix, or vector',
      );
    }
  }

  dynamic _lookupVariable(String name, Map<String, double> variables) {
    // First check user-provided variables
    if (variables.containsKey(name)) {
      return variables[name]!;
    }

    // Fall back to built-in constants
    final constant = ConstantRegistry.instance.get(name);
    if (constant != null) {
      return constant;
    }

    // Check for 'i' (imaginary unit)
    if (name == 'i') {
      return Complex(0, 1);
    }

    throw EvaluatorException(
      'Undefined variable: $name',
      suggestion: 'Provide a value for "$name" in the variables map',
    );
  }

  double _evaluateAsDouble(Expression expr, Map<String, double> variables) {
    final val = _evaluateRaw(expr, variables);
    if (val is double) return val;
    if (val is Complex && val.isReal) return val.real;
    throw EvaluatorException(
      'Expression must evaluate to a real number',
      suggestion:
          'This operation requires a numeric value, not a matrix or complex number',
    );
  }

  dynamic _evaluateBinaryOp(BinaryOp expr, Map<String, double> variables) {
    final leftValue = _evaluateRaw(expr.left, variables);

    // Special handling for Matrix Transpose: M^T
    // Don't evaluate 'T' as a variable
    if (leftValue is Matrix &&
        expr.operator == BinaryOperator.power &&
        expr.right is Variable &&
        (expr.right as Variable).name == 'T') {
      return _binaryEvaluator.evaluate(leftValue, expr.operator, null, expr);
    }

    final rightValue = _evaluateRaw(expr.right, variables);
    return _binaryEvaluator.evaluate(
        leftValue, expr.operator, rightValue, expr);
  }

  dynamic _evaluateFunctionCall(
      FunctionCall func, Map<String, double> variables) {
    return FunctionRegistry.instance.evaluate(
      func,
      variables,
      (e) => _evaluateRaw(e, variables),
    );
  }
}
