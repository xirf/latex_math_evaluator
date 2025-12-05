/// Hyperbolic function handlers.
library;

import 'dart:math' as math;

import '../ast.dart';

/// Hyperbolic sine: \sinh{x}
double handleSinh(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  return (math.exp(x) - math.exp(-x)) / 2;
}

/// Hyperbolic cosine: \cosh{x}
double handleCosh(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  return (math.exp(x) + math.exp(-x)) / 2;
}

/// Hyperbolic tangent: \tanh{x}
double handleTanh(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  final expX = math.exp(x);
  final expNegX = math.exp(-x);
  return (expX - expNegX) / (expX + expNegX);
}
