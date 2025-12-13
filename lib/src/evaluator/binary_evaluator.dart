import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';
import '../matrix.dart';

/// Handles evaluation of binary operations.
class BinaryEvaluator {
  /// Evaluates a binary operation between two expressions.
  ///
  /// Supports operations on numbers, complex numbers, and matrices.
  /// Special handling for matrix transpose (M^T) and inverse (M^{-1}).
  ///
  /// [rightValue] may be null for special cases like M^T where the right
  /// expression is not evaluated.
  dynamic evaluate(
    dynamic leftValue,
    BinaryOperator operator,
    dynamic rightValue,
    Expression right,
  ) {
    // Special handling for Matrix Transpose: M^T
    if (leftValue is Matrix &&
        operator == BinaryOperator.power &&
        right is Variable &&
        right.name == 'T') {
      return leftValue.transpose();
    }

    if (leftValue is Matrix && rightValue is Matrix) {
      return _evaluateMatrixMatrix(leftValue, operator, rightValue);
    } else if (leftValue is Matrix && rightValue is num) {
      return _evaluateMatrixScalar(leftValue, operator, rightValue);
    } else if (leftValue is num && rightValue is Matrix) {
      return _evaluateScalarMatrix(leftValue, operator, rightValue);
    } else if (leftValue is Complex || rightValue is Complex) {
      return _evaluateComplex(leftValue, operator, rightValue);
    } else if (leftValue is double && rightValue is double) {
      return _evaluateNumberNumber(leftValue, operator, rightValue);
    }

    throw EvaluatorException(
      'Type mismatch in binary operation',
      suggestion:
          'Ensure both operands are compatible types (numbers, complex numbers, or matrices)',
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

  Complex _evaluateComplex(
    dynamic left,
    BinaryOperator operator,
    dynamic right,
  ) {
    final l = left is Complex ? left : Complex.fromNum(left as num);
    final r = right is Complex ? right : Complex.fromNum(right as num);

    switch (operator) {
      case BinaryOperator.add:
        return l + r;
      case BinaryOperator.subtract:
        return l - r;
      case BinaryOperator.multiply:
        return l * r;
      case BinaryOperator.divide:
        return l / r;
      case BinaryOperator.power:
        // Complex power is tricky, for now let's support integer powers via multiplication
        if (r.isReal && r.real == r.real.roundToDouble()) {
          final exponent = r.real.toInt();
          if (exponent == 0) return Complex(1);
          if (exponent > 0) {
            var result = l;
            for (var i = 1; i < exponent; i++) {
              result = result * l;
            }
            return result;
          }
        }
        throw EvaluatorException(
          'Complex power not fully supported yet',
          suggestion:
              'Currently only integer exponents are supported for complex numbers',
        );
    }
  }

  double _evaluateNumberNumber(
    double left,
    BinaryOperator operator,
    double right,
  ) {
    switch (operator) {
      case BinaryOperator.add:
        return left + right;
      case BinaryOperator.subtract:
        return left - right;
      case BinaryOperator.multiply:
        return left * right;
      case BinaryOperator.divide:
        return _divide(left, right);
      case BinaryOperator.power:
        return math.pow(left, right).toDouble();
    }
  }

  double _divide(double left, double right) {
    if (right == 0) {
      throw EvaluatorException(
        'Division by zero',
        suggestion: 'Ensure the denominator is not zero',
      );
    }
    return left / right;
  }
}
