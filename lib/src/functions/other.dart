/// Other miscellaneous function handlers.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../exceptions.dart';

/// Absolute value: \abs{x}
double handleAbs(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  return evaluate(func.argument).abs();
}

/// Sign function: \sgn{x}
double handleSgn(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  if (x > 0) return 1.0;
  if (x < 0) return -1.0;
  return 0.0;
}

/// Factorial: \factorial{n}
double handleFactorial(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  final n = evaluate(func.argument).toInt();
  if (n < 0) {
    throw EvaluatorException('Factorial of negative number');
  }
  if (n > 170) {
    throw EvaluatorException('Factorial overflow');
  }
  double result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

/// Minimum: \min_{a}{b}
double handleMin(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  if (func.base == null) {
    throw EvaluatorException('min requires two arguments: \\min_{a}{b}');
  }
  return math.min(evaluate(func.base!), evaluate(func.argument));
}

/// Maximum: \max_{a}{b}
double handleMax(FunctionCall func, Map<String, double> vars, double Function(Expression) evaluate) {
  if (func.base == null) {
    throw EvaluatorException('max requires two arguments: \\max_{a}{b}');
  }
  return math.max(evaluate(func.base!), evaluate(func.argument));
}
