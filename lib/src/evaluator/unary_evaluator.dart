/// Unary operation evaluation logic.
library;

import '../ast.dart';
import '../exceptions.dart';
import '../matrix.dart';

/// Handles evaluation of unary operations.
class UnaryEvaluator {
  /// Evaluates a unary operation on an expression.
  ///
  /// Supports negation of numbers and matrices.
  dynamic evaluate(
    UnaryOperator operator,
    dynamic operandValue,
  ) {
    if (operandValue is Matrix) {
      if (operator == UnaryOperator.negate) {
        return operandValue * -1;
      }
      throw EvaluatorException(
        'Operator $operator not supported for matrix',
        suggestion: 'Use scalar multiplication with -1 instead: -1 * M',
      );
    }

    if (operandValue is double) {
      switch (operator) {
        case UnaryOperator.negate:
          return -operandValue;
      }
    }

    throw EvaluatorException(
      'Type mismatch in unary operation',
      suggestion: 'Unary operators can only be applied to numbers',
    );
  }
}
