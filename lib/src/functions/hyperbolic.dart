/// Hyperbolic function handlers with complex number support.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';

/// Hyperbolic sine: \sinh{x} - supports complex arguments
dynamic handleSinh(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.sinh();
  if (arg is num) {
    final x = arg.toDouble();
    return (math.exp(x) - math.exp(-x)) / 2;
  }
  throw EvaluatorException('sinh requires a numeric or complex argument');
}

/// Hyperbolic cosine: \cosh{x} - supports complex arguments
dynamic handleCosh(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.cosh();
  if (arg is num) {
    final x = arg.toDouble();
    return (math.exp(x) + math.exp(-x)) / 2;
  }
  throw EvaluatorException('cosh requires a numeric or complex argument');
}

/// Hyperbolic tangent: \tanh{x} - supports complex arguments
dynamic handleTanh(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.tanh();
  if (arg is num) {
    final x = arg.toDouble();
    final expX = math.exp(x);
    final expNegX = math.exp(-x);
    return (expX - expNegX) / (expX + expNegX);
  }
  throw EvaluatorException('tanh requires a numeric or complex argument');
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
