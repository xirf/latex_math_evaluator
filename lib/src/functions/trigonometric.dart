/// Trigonometric function handlers.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../exceptions.dart';

/// Sine: \sin{x}
double handleSin(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return math.sin(evaluate(func.argument));
}

/// Cosine: \cos{x}
double handleCos(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return math.cos(evaluate(func.argument));
}

/// Tangent: \tan{x}
double handleTan(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return math.tan(evaluate(func.argument));
}

/// Arcsine: \asin{x}
double handleAsin(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg < -1 || arg > 1) {
    throw EvaluatorException('asin argument must be between -1 and 1');
  }
  return math.asin(arg);
}

/// Arccosine: \acos{x}
double handleAcos(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg < -1 || arg > 1) {
    throw EvaluatorException('acos argument must be between -1 and 1');
  }
  return math.acos(arg);
}

/// Arctangent: \atan{x}
double handleAtan(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return math.atan(evaluate(func.argument));
}
