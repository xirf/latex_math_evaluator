/// Power and root function handlers.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../exceptions.dart';

/// Square root or nth root: \sqrt{x} or \sqrt[n]{x}
double handleSqrt(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final arg = evaluate(func.argument);

  // Check for nth root via optional parameter
  if (func.optionalParam != null) {
    final n = evaluate(func.optionalParam!);
    if (n == 0) {
      throw EvaluatorException('Cannot compute 0th root');
    }
    if (arg < 0 && n % 2 == 0) {
      throw EvaluatorException('Even root of negative number');
    }
    // Compute nth root as arg^(1/n)
    // For negative arg with odd n, handle specially
    if (arg < 0 && n % 2 == 1) {
      // Odd root of negative: -(-x)^(1/n)
      return -math.pow(-arg, 1 / n).toDouble();
    }
    return math.pow(arg, 1 / n).toDouble();
  }

  // Default: square root
  if (arg < 0) {
    throw EvaluatorException('Square root of negative number');
  }
  return math.sqrt(arg);
}

/// Exponential: \exp{x}
double handleExp(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return math.exp(evaluate(func.argument));
}
