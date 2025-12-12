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
typedef FunctionHandler = dynamic Function(
  FunctionCall func,
  Map<String, double> variables,
  dynamic Function(Expression) evaluate,
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
    // Helper to adapt double-returning handlers
    void reg(String name, double Function(FunctionCall, Map<String, double>, double Function(Expression)) handler) {
      register(name, (f, v, e) => handler(f, v, (x) {
        final val = e(x);
        if (val is double) return val;
        throw EvaluatorException('Expected number argument for $name');
      }));
    }

    // Logarithmic
    reg('ln', log.handleLn);
    reg('log', log.handleLog);

    // Trigonometric
    reg('sin', trig.handleSin);
    reg('cos', trig.handleCos);
    reg('tan', trig.handleTan);
    reg('asin', trig.handleAsin);
    reg('acos', trig.handleAcos);
    reg('atan', trig.handleAtan);

    // Hyperbolic
    reg('sinh', hyper.handleSinh);
    reg('cosh', hyper.handleCosh);
    reg('tanh', hyper.handleTanh);
    reg('asinh', hyper.handleAsinh);
    reg('acosh', hyper.handleAcosh);
    reg('atanh', hyper.handleAtanh);

    // Power / Root
    reg('sqrt', pow.handleSqrt);
    reg('exp', pow.handleExp);

    // Rounding
    reg('ceil', round.handleCeil);
    reg('floor', round.handleFloor);
    reg('round', round.handleRound);

    // Other
    reg('abs', other.handleAbs);
    reg('sgn', other.handleSgn);
    reg('factorial', other.handleFactorial);
    reg('min', other.handleMin);
    reg('max', other.handleMax);

    // Matrix functions (handle dynamic types directly)
    register('det', other.handleDet);
    register('trace', other.handleTrace);
    register('tr', other.handleTrace);
    
    // Combinatorics & Number Theory
    register('gcd', other.handleGcd);
    register('lcm', other.handleLcm);
    register('binom', other.handleBinom);
  }

  /// Registers a function handler.
  void register(String name, FunctionHandler handler) {
    _handlers[name] = handler;
  }

  /// Checks if a function is registered.
  bool hasFunction(String name) => _handlers.containsKey(name);

  /// Evaluates a function call.
  dynamic evaluate(
    FunctionCall func,
    Map<String, double> variables,
    dynamic Function(Expression) evaluator,
  ) {
    final handler = _handlers[func.name];
    if (handler == null) {
      throw EvaluatorException('Unknown function: ${func.name}');
    }
    return handler(func, variables, evaluator);
  }
}
