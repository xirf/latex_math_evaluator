/// Logarithmic function handlers.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../exceptions.dart';

/// Natural logarithm: \ln{x}
double handleLn(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg <= 0) {
    throw EvaluatorException('Logarithm of non-positive number');
  }
  return math.log(arg);
}

/// Logarithm: \log{x} or \log_{base}{x}
double handleLog(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg <= 0) {
    throw EvaluatorException('Logarithm of non-positive number');
  }
  if (func.base != null) {
    final base = evaluate(func.base!);
    if (base <= 0 || base == 1) {
      throw EvaluatorException('Invalid logarithm base');
    }
    return math.log(arg) / math.log(base);
  }
  return math.log(arg) / math.ln10;
}
