/// Matrix binary operation strategy.
library;

import '../../ast/operations.dart';
import '../../exceptions.dart';
import '../../matrix.dart';
import 'binary_operation_strategy.dart';

/// Strategy for evaluating binary operations involving matrices.
class MatrixStrategy implements BinaryOperationStrategy {
  @override
  bool canHandle(dynamic left, dynamic right) {
    return left is Matrix || right is Matrix;
  }

  @override
  dynamic evaluate(dynamic left, BinaryOperator operator, dynamic right) {
    if (left is Matrix && right is Matrix) {
      return _evaluateMatrixMatrix(left, operator, right);
    } else if (left is Matrix && right is num) {
      return _evaluateMatrixScalar(left, operator, right);
    } else if (left is num && right is Matrix) {
      return _evaluateScalarMatrix(left, operator, right as Matrix);
    }

    throw EvaluatorException(
      'Invalid matrix operation',
      suggestion: 'Matrices can be combined with other matrices or scalars',
    );
  }

  Matrix _evaluateMatrixMatrix(
    Matrix left,
    BinaryOperator operator,
    Matrix right,
  ) {
    switch (operator) {
      case BinaryOperator.add:
        return left + right;
      case BinaryOperator.subtract:
        return left - right;
      case BinaryOperator.multiply:
        return left * right;
      default:
        throw EvaluatorException(
          'Operator $operator not supported for matrices',
          suggestion:
              'Matrices support +, -, * operations and ^{-1} for inverse or ^T for transpose',
        );
    }
  }

  dynamic _evaluateMatrixScalar(
    Matrix left,
    BinaryOperator operator,
    num right,
  ) {
    switch (operator) {
      case BinaryOperator.multiply:
        return left * right;
      case BinaryOperator.power:
        if (right == -1) {
          return left.inverse();
        }
        throw EvaluatorException(
          'Matrix power only supports -1 (inverse) or T (transpose)',
          suggestion: 'Use M^{-1} for inverse or M^T for transpose',
        );
      default:
        throw EvaluatorException(
          'Operator $operator not supported for matrix and scalar',
          suggestion:
              'You can multiply a matrix by a scalar, but other operations are not supported',
        );
    }
  }

  Matrix _evaluateScalarMatrix(
    num left,
    BinaryOperator operator,
    Matrix right,
  ) {
    switch (operator) {
      case BinaryOperator.multiply:
        return right * left;
      default:
        throw EvaluatorException(
          'Operator $operator not supported for scalar and matrix',
          suggestion:
              'You can multiply a scalar by a matrix, but other operations are not supported',
        );
    }
  }
}
