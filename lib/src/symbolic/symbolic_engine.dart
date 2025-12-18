/// Core symbolic algebra engine for simplification and manipulation.
library;

import '../ast.dart';
import 'simplifier.dart';
import 'polynomial_operations.dart';
import 'trig_identities.dart';
import 'logarithm_laws.dart';
import 'rational_simplifier.dart';

/// Main entry point for symbolic algebra operations.
///
/// The [SymbolicEngine] provides high-level symbolic manipulation capabilities:
/// - Expression simplification
/// - Polynomial expansion and factorization
/// - Trigonometric identity application
/// - Logarithm law application
/// - Rational expression simplification
///
/// Example:
/// ```dart
/// final engine = SymbolicEngine();
/// final expr = Parser(Tokenizer('(x+1)^2').tokenize()).parse();
/// final simplified = engine.simplify(expr);
/// // Result: x^2 + 2*x + 1
/// ```
class SymbolicEngine {
  final Simplifier _simplifier;
  final PolynomialOperations _polynomialOps;
  final TrigIdentities _trigIdentities;
  final LogarithmLaws _logLaws;
  final RationalSimplifier _rationalSimplifier;

  /// Creates a new symbolic engine with default settings.
  SymbolicEngine()
      : _simplifier = Simplifier(),
        _polynomialOps = PolynomialOperations(),
        _trigIdentities = TrigIdentities(),
        _logLaws = LogarithmLaws(),
        _rationalSimplifier = RationalSimplifier();

  /// Simplifies an expression using all available rules.
  ///
  /// Applies simplification rules in the following order:
  /// 1. Basic algebraic simplification (0+x = x, 1*x = x, etc.)
  /// 2. Trigonometric identities
  /// 3. Logarithm laws
  /// 4. Rational expression simplification
  /// 5. Polynomial simplification
  ///
  /// Returns a simplified expression. May return the same expression
  /// if no simplification is possible.
  Expression simplify(Expression expr) {
    var result = expr;
    var previousResult = result;
    var iterations = 0;
    const maxIterations = 100; // Prevent infinite loops

    do {
      previousResult = result;
      result = _simplifier.simplify(result);
      result = _trigIdentities.simplify(result);
      result = _logLaws.simplify(result);
      result = _rationalSimplifier.simplify(result);
      iterations++;
    } while (result != previousResult && iterations < maxIterations);

    return result;
  }

  /// Expands a polynomial expression.
  ///
  /// Examples:
  /// - `(x+1)^2` → `x^2 + 2*x + 1`
  /// - `(a+b)(c+d)` → `a*c + a*d + b*c + b*d`
  Expression expand(Expression expr) {
    return _polynomialOps.expand(expr);
  }

  /// Factors a polynomial expression.
  ///
  /// Examples:
  /// - `x^2 - 4` → `(x-2)(x+2)`
  /// - `x^2 + 5*x + 6` → `(x+2)(x+3)`
  ///
  /// Returns the original expression if factoring is not possible.
  Expression factor(Expression expr) {
    return _polynomialOps.factor(expr);
  }

  /// Tests if two expressions are equivalent.
  ///
  /// This is a structural comparison after simplification.
  /// Returns `true` if the expressions represent the same mathematical value.
  bool areEquivalent(Expression expr1, Expression expr2) {
    final simplified1 = simplify(expr1);
    final simplified2 = simplify(expr2);
    return simplified1 == simplified2;
  }

  /// Solves a linear equation of the form ax + b = 0.
  ///
  /// Returns the solution as an expression, or null if the equation
  /// cannot be solved or has no solution.
  Expression? solveLinear(Expression equation, String variable) {
    return _polynomialOps.solveLinear(equation, variable);
  }

  /// Solves a quadratic equation of the form ax^2 + bx + c = 0.
  ///
  /// Returns a list of solutions (0, 1, or 2 solutions).
  List<Expression> solveQuadratic(Expression equation, String variable) {
    return _polynomialOps.solveQuadratic(equation, variable);
  }
}
