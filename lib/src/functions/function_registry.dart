/// Built-in function registry.
///
/// Functions are organized into separate files by category:
/// - [logarithmic.dart] - ln, log
/// - [trigonometric.dart] - sin, cos, tan, asin, acos, atan
/// - [hyperbolic.dart] - sinh, cosh, tanh
/// - [rounding.dart] - ceil, floor, round
/// - [power.dart] - sqrt, exp
/// - [other.dart] - abs, sgn, factorial, min, max
library;

import '../ast.dart';
import '../exceptions.dart';

import 'logarithmic.dart' as log;
import 'trigonometric.dart' as trig;
import 'hyperbolic.dart' as hyper;
import 'rounding.dart' as round;
import 'power.dart' as pow;
import 'other.dart' as other;

/// Handler function type for evaluating a function call.
typedef FunctionHandler = double Function(
  FunctionCall func,
  Map<String, double> variables,
  double Function(Expression) evaluate,
);

/// Registry of built-in mathematical functions.
class FunctionRegistry {
  static final FunctionRegistry _instance = FunctionRegistry._();

  /// Singleton instance of the function registry.
  static FunctionRegistry get instance => _instance;

  final Map<String, FunctionHandler> _handlers = {};

  FunctionRegistry._() {
    _registerBuiltins();
  }

  /// Creates a new registry (for testing or custom configurations).
  FunctionRegistry.custom();

  void _registerBuiltins() {
    // Logarithmic
    register('ln', log.handleLn);
    register('log', log.handleLog);

    // Trigonometric
    register('sin', trig.handleSin);
    register('cos', trig.handleCos);
    register('tan', trig.handleTan);
    register('asin', trig.handleAsin);
    register('acos', trig.handleAcos);
    register('atan', trig.handleAtan);

    // Hyperbolic
    register('sinh', hyper.handleSinh);
    register('cosh', hyper.handleCosh);
    register('tanh', hyper.handleTanh);

    // Power / Root
    register('sqrt', pow.handleSqrt);
    register('exp', pow.handleExp);

    // Rounding
    register('ceil', round.handleCeil);
    register('floor', round.handleFloor);
    register('round', round.handleRound);

    // Other
    register('abs', other.handleAbs);
    register('sgn', other.handleSgn);
    register('factorial', other.handleFactorial);
    register('min', other.handleMin);
    register('max', other.handleMax);
  }

  /// Registers a function handler.
  void register(String name, FunctionHandler handler) {
    _handlers[name] = handler;
  }

  /// Checks if a function is registered.
  bool hasFunction(String name) => _handlers.containsKey(name);

  /// Evaluates a function call.
  double evaluate(
    FunctionCall func,
    Map<String, double> variables,
    double Function(Expression) evaluator,
  ) {
    final handler = _handlers[func.name];
    if (handler == null) {
      throw EvaluatorException('Unknown function: ${func.name}');
    }
    return handler(func, variables, evaluator);
  }
}
