/// Complex number binary operation strategy.
library;

import '../../ast/operations.dart';
import '../../complex.dart';
import '../../exceptions.dart';
import 'binary_operation_strategy.dart';

/// Strategy for evaluating binary operations involving complex numbers.
class ComplexStrategy implements BinaryOperationStrategy {
  @override
  bool canHandle(dynamic left, dynamic right) {
    return left is Complex || right is Complex;
  }

  @override
  Complex evaluate(dynamic left, BinaryOperator operator, dynamic right) {
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
          if (exponent == 0) return Complex(1, 0);
          if (exponent < 0) {
            return Complex(1, 0) / _intPower(l, -exponent);
          }
          return _intPower(l, exponent);
        }
        throw EvaluatorException(
          'Complex power only supports integer exponents',
          suggestion: 'Use an integer exponent for complex number powers',
        );
    }
  }

  Complex _intPower(Complex base, int exponent) {
    Complex result = Complex(1, 0);
    for (int i = 0; i < exponent; i++) {
      result = result * base;
    }
    return result;
  }
}
