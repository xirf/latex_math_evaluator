/// Power and root function handlers.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../exceptions.dart';

/// Square root: \sqrt{x}
double handleSqrt(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg < 0) {
    throw EvaluatorException('Square root of negative number');
  }
  return math.sqrt(arg);
}

/// Exponential: \exp{x}
double handleExp(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  return math.exp(evaluate(func.argument));
}
