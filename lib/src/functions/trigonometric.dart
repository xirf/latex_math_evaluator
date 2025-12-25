/// Trigonometric function handlers with complex number support.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';

/// Sine: \sin{x} - supports both real and complex arguments
dynamic handleSin(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.sin();
  if (arg is num) return math.sin(arg.toDouble());
  throw EvaluatorException('sin requires a numeric or complex argument');
}

/// Cosine: \cos{x} - supports both real and complex arguments
dynamic handleCos(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.cos();
  if (arg is num) return math.cos(arg.toDouble());
  throw EvaluatorException('cos requires a numeric or complex argument');
}

/// Tangent: \tan{x} - supports both real and complex arguments
dynamic handleTan(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.tan();
  if (arg is num) return math.tan(arg.toDouble());
  throw EvaluatorException('tan requires a numeric or complex argument');
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
