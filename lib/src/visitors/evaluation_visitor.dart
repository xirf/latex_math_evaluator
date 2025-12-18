import '../ast/visitor.dart';
import '../ast/basic.dart';
import '../ast/operations.dart';
import '../ast/functions.dart';
import '../ast/calculus.dart';
import '../ast/logic.dart';
import '../ast/matrix.dart';
import '../evaluation_result.dart';
import 'dart:math' as math;

/// A visitor that evaluates expressions to produce numeric results.
///
/// This is a proof-of-concept visitor that demonstrates the visitor pattern.
/// It provides a foundation for refactoring the existing evaluator logic
/// into a more maintainable visitor-based architecture.
///
/// Note: This is an initial implementation and doesn't yet handle all edge
/// cases or advanced features from the original evaluator.
class EvaluationVisitor implements ExpressionVisitor<EvaluationResult, Map<String, num>?> {
  @override
  EvaluationResult visitNumberLiteral(NumberLiteral node, Map<String, num>? context) {
    return NumericResult(node.value);
  }

  @override
  EvaluationResult visitVariable(Variable node, Map<String, num>? context) {
    if (context != null && context.containsKey(node.name)) {
      return NumericResult(context[node.name]!.toDouble());
    }
    // Handle constants
    if (node.name == 'pi' || node.name == r'\pi') {
      return NumericResult(math.pi);
    }
    if (node.name == 'e') {
      return NumericResult(math.e);
    }
    throw Exception('Undefined variable: ${node.name}');
  }

  @override
  EvaluationResult visitBinaryOp(BinaryOp node, Map<String, num>? context) {
    final left = node.left.accept(this, context).asNumeric();
    final right = node.right.accept(this, context).asNumeric();

    switch (node.operator) {
      case BinaryOperator.add:
        return NumericResult(left + right);
      case BinaryOperator.subtract:
        return NumericResult(left - right);
      case BinaryOperator.multiply:
        return NumericResult(left * right);
      case BinaryOperator.divide:
        if (right == 0) {
          throw Exception('Division by zero');
        }
        return NumericResult(left / right);
      case BinaryOperator.power:
        return NumericResult(math.pow(left, right).toDouble());
    }
  }

  @override
  EvaluationResult visitUnaryOp(UnaryOp node, Map<String, num>? context) {
    final operand = node.operand.accept(this, context).asNumeric();
    
    switch (node.operator) {
      case UnaryOperator.negate:
        return NumericResult(-operand);
    }
  }

  @override
  EvaluationResult visitFunctionCall(FunctionCall node, Map<String, num>? context) {
    // For now, just throw - this will be implemented next
    throw UnimplementedError('Function calls not yet implemented in visitor');
  }

  @override
  EvaluationResult visitLimitExpr(LimitExpr node, Map<String, num>? context) {
    throw UnimplementedError('Limits not yet implemented in visitor');
  }

  @override
  EvaluationResult visitSumExpr(SumExpr node, Map<String, num>? context) {
    throw UnimplementedError('Summation not yet implemented in visitor');
  }

  @override
  EvaluationResult visitProductExpr(ProductExpr node, Map<String, num>? context) {
    throw UnimplementedError('Products not yet implemented in visitor');
  }

  @override
  EvaluationResult visitIntegralExpr(IntegralExpr node, Map<String, num>? context) {
    throw UnimplementedError('Integrals not yet implemented in visitor');
  }

  @override
  EvaluationResult visitDerivativeExpr(DerivativeExpr node, Map<String, num>? context) {
    throw UnimplementedError('Derivatives not yet implemented in visitor');
  }

  @override
  EvaluationResult visitComparison(Comparison node, Map<String, num>? context) {
    throw UnimplementedError('Comparisons not yet implemented in visitor');
  }

  @override
  EvaluationResult visitChainedComparison(ChainedComparison node, Map<String, num>? context) {
    throw UnimplementedError('Chained comparisons not yet implemented in visitor');
  }

  @override
  EvaluationResult visitConditionalExpr(ConditionalExpr node, Map<String, num>? context) {
    throw UnimplementedError('Conditional expressions not yet implemented in visitor');
  }

  @override
  EvaluationResult visitMatrixExpr(MatrixExpr node, Map<String, num>? context) {
    throw UnimplementedError('Matrix expressions not yet implemented in visitor');
  }

  @override
  EvaluationResult visitVectorExpr(VectorExpr node, Map<String, num>? context) {
    throw UnimplementedError('Vector expressions not yet implemented in visitor');
  }
}
