import 'package:latex_math_evaluator/latex_math_evaluator.dart';

import '../complex.dart';
import '../constants/constant_registry.dart';
import '../functions/function_registry.dart';
import '../evaluator/binary_evaluator.dart';
import '../evaluator/unary_evaluator.dart';
import '../features/calculus/calculus_evaluator.dart';
import '../features/logic/comparison_evaluator.dart';
import '../features/linear_algebra/matrix_evaluator.dart';
import '../features/calculus/differentiation_evaluator.dart';
import '../features/calculus/integration_evaluator.dart';

/// A visitor that evaluates expressions to produce results.
///
/// This visitor implements the full evaluation logic using the visitor pattern,
/// replacing the type-checking approach in the original Evaluator class.
/// It supports:
/// - Basic arithmetic operations (+, -, *, /, ^)
/// - Function calls (sin, cos, log, etc.)
/// - Variable bindings
/// - Matrix operations
/// - Complex number operations
/// - Calculus operations (limits, sums, products, integrals, derivatives)
/// - Logical operations and conditionals
/// - Custom extensions
class EvaluationVisitor
    implements ExpressionVisitor<dynamic, Map<String, double>> {
  final ExtensionRegistry? _extensions;
  late final BinaryEvaluator _binaryEvaluator;
  late final UnaryEvaluator _unaryEvaluator;
  late final CalculusEvaluator _calculusEvaluator;
  late final ComparisonEvaluator _comparisonEvaluator;
  late final MatrixEvaluator _matrixEvaluator;
  late final DifferentiationEvaluator _differentiationEvaluator;
  late final IntegrationEvaluator _integrationEvaluator;

  /// Creates an evaluation visitor with optional extension registry.
  EvaluationVisitor({ExtensionRegistry? extensions})
      : _extensions = extensions {
    _binaryEvaluator = BinaryEvaluator();
    _unaryEvaluator = UnaryEvaluator();
    _calculusEvaluator = CalculusEvaluator(_evaluateAsDouble);
    _comparisonEvaluator = ComparisonEvaluator(_evaluateAsDouble, _evaluateRaw);
    _matrixEvaluator = MatrixEvaluator(_evaluateRaw);
    _differentiationEvaluator = DifferentiationEvaluator(_evaluateAsDouble);
    _integrationEvaluator = IntegrationEvaluator();
  }

  /// Gets the differentiation evaluator (for internal use by public API).
  DifferentiationEvaluator get differentiationEvaluator =>
      _differentiationEvaluator;

  /// Gets the integration evaluator (for internal use by public API).
  IntegrationEvaluator get integrationEvaluator => _integrationEvaluator;

  /// Helper to evaluate an expression and get a raw result.
  dynamic _evaluateRaw(Expression expr, Map<String, double> variables) {
    return expr.accept(this, variables);
  }

  /// Helper to evaluate an expression as a double.
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

  @override
  dynamic visitNumberLiteral(NumberLiteral node, Map<String, double>? context) {
    return node.value;
  }

  @override
  dynamic visitVariable(Variable node, Map<String, double>? context) {
    final variables = context ?? const {};

    // First check user-provided variables
    if (variables.containsKey(node.name)) {
      return variables[node.name]!;
    }

    // Fall back to built-in constants
    final constant = ConstantRegistry.instance.get(node.name);
    if (constant != null) {
      return constant;
    }

    // Check for 'i' (imaginary unit)
    if (node.name == 'i') {
      return Complex(0, 1);
    }

    // Try extension registry
    if (_extensions != null) {
      final result = _extensions!.tryEvaluate(
        node,
        variables,
        (e) => _evaluateRaw(e, variables),
      );
      if (result != null) {
        return result;
      }
    }

    throw EvaluatorException(
      'Undefined variable: ${node.name}',
      suggestion: 'Provide a value for "${node.name}" in the variables map',
    );
  }

  @override
  dynamic visitBinaryOp(BinaryOp node, Map<String, double>? context) {
    final variables = context ?? const {};
    final leftValue = _evaluateRaw(node.left, variables);

    // Special handling for Matrix Transpose: M^T
    // Don't evaluate 'T' as a variable
    if (leftValue is Matrix &&
        node.operator == BinaryOperator.power &&
        node.right is Variable &&
        (node.right as Variable).name == 'T') {
      return _binaryEvaluator.evaluate(leftValue, node.operator, null, node);
    }

    final rightValue = _evaluateRaw(node.right, variables);
    return _binaryEvaluator.evaluate(
        leftValue, node.operator, rightValue, node);
  }

  @override
  dynamic visitUnaryOp(UnaryOp node, Map<String, double>? context) {
    final variables = context ?? const {};
    final operandValue = _evaluateRaw(node.operand, variables);
    return _unaryEvaluator.evaluate(node.operator, operandValue);
  }

  @override
  dynamic visitFunctionCall(FunctionCall node, Map<String, double>? context) {
    final variables = context ?? const {};

    // Special handling for abs() with vector argument
    if (node.name == 'abs') {
      final argValue = _evaluateRaw(node.argument, variables);
      if (argValue is Vector) {
        return argValue.magnitude;
      }
    }

    return FunctionRegistry.instance.evaluate(
      node,
      variables,
      (e) => _evaluateRaw(e, variables),
    );
  }

  @override
  dynamic visitLimitExpr(LimitExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _calculusEvaluator.evaluateLimit(node, variables);
  }

  @override
  dynamic visitSumExpr(SumExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _calculusEvaluator.evaluateSum(node, variables);
  }

  @override
  dynamic visitProductExpr(ProductExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _calculusEvaluator.evaluateProduct(node, variables);
  }

  @override
  dynamic visitIntegralExpr(IntegralExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _calculusEvaluator.evaluateIntegral(node, variables);
  }

  @override
  dynamic visitDerivativeExpr(
      DerivativeExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _differentiationEvaluator.evaluateDerivative(node, variables);
  }

  @override
  dynamic visitComparison(Comparison node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _comparisonEvaluator.evaluateComparison(node, variables);
  }

  @override
  dynamic visitChainedComparison(
      ChainedComparison node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _comparisonEvaluator.evaluateChainedComparison(node, variables);
  }

  @override
  dynamic visitConditionalExpr(
      ConditionalExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _comparisonEvaluator.evaluateConditional(node, variables);
  }

  @override
  dynamic visitMatrixExpr(MatrixExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    return _matrixEvaluator.evaluate(node, variables);
  }

  @override
  dynamic visitVectorExpr(VectorExpr node, Map<String, double>? context) {
    final variables = context ?? const {};
    // Evaluate all components
    final evalComponents =
        node.components.map((c) => _evaluateAsDouble(c, variables)).toList();
    final vec = Vector(evalComponents);
    // If it's marked as a unit vector (\hat{}), normalize it
    return node.isUnitVector ? vec.normalize() : vec;
  }
}
