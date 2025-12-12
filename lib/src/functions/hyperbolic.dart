/// Hyperbolic function handlers.
library;

import 'dart:math' as math;
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

/// Hyperbolic sine: \sinh{x}
double handleSinh(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  return (math.exp(x) - math.exp(-x)) / 2;
}

/// Hyperbolic cosine: \cosh{x}
double handleCosh(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  return (math.exp(x) + math.exp(-x)) / 2;
}

/// Hyperbolic tangent: \tanh{x}
double handleTanh(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  final expX = math.exp(x);
  final expNegX = math.exp(-x);
  return (expX - expNegX) / (expX + expNegX);
}

/// Inverse Hyperbolic sine: \asinh{x}
double handleAsinh(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  return math.log(x + math.sqrt(x * x + 1));
}

/// Inverse Hyperbolic cosine: \acosh{x}
double handleAcosh(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  if (x < 1) {
    throw EvaluatorException('acosh argument must be >= 1');
  }
  return math.log(x + math.sqrt(x * x - 1));
}

/// Inverse Hyperbolic tangent: \atanh{x}
double handleAtanh(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  if (x <= -1 || x >= 1) {
    throw EvaluatorException('atanh argument must be between -1 and 1');
  }
  return 0.5 * math.log((1 + x) / (1 - x));
}
