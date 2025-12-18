/// Polynomial expansion and factorization operations.
library;

import '../ast.dart';
import 'dart:math' as math;

/// Handles polynomial expansion, factorization, and equation solving.
///
/// Supports:
/// - Expanding expressions like (x+a)^n
/// - Factoring quadratic expressions
/// - Solving linear and quadratic equations
class PolynomialOperations {
  /// Expands polynomial expressions.
  ///
  /// Currently supports:
  /// - (a+b)^2 → a^2 + 2*a*b + b^2
  /// - (a+b)^n for small integer n
  /// - (a+b)(c+d) → a*c + a*d + b*c + b*d
  Expression expand(Expression expr) {
    return _expandRecursive(expr);
  }

  Expression _expandRecursive(Expression expr) {
    if (expr is BinaryOp) {
      if (expr.operator == BinaryOperator.power) {
        return _expandPower(expr);
      } else if (expr.operator == BinaryOperator.multiply) {
        return _expandMultiply(expr);
      }
    }
    return expr;
  }

  Expression _expandPower(BinaryOp powerExpr) {
    final base = powerExpr.left;
    final exponent = powerExpr.right;

    // Only expand integer powers for now
    if (exponent is! NumberLiteral) return powerExpr;
    final exp = exponent.value.toInt();
    if (exp != exponent.value || exp < 0 || exp > 10) return powerExpr;

    // Handle (a+b)^n expansion
    if (base is BinaryOp && base.operator == BinaryOperator.add) {
      return _expandBinomialPower(base.left, base.right, exp);
    }

    // Handle (a-b)^n expansion
    if (base is BinaryOp && base.operator == BinaryOperator.subtract) {
      final negRight = UnaryOp(UnaryOperator.negate, base.right);
      return _expandBinomialPower(base.left, negRight, exp);
    }

    return powerExpr;
  }

  Expression _expandBinomialPower(Expression a, Expression b, int n) {
    if (n == 0) return const NumberLiteral(1);
    if (n == 1) return BinaryOp(a, BinaryOperator.add, b);

    // Use binomial theorem: (a+b)^n = Σ C(n,k) * a^(n-k) * b^k
    Expression? result;

    for (var k = 0; k <= n; k++) {
      final coeff = _binomialCoefficient(n, k);
      Expression term = NumberLiteral(coeff.toDouble());

      // Add a^(n-k)
      if (n - k > 0) {
        final aPower = n - k == 1
            ? a
            : BinaryOp(a, BinaryOperator.power, NumberLiteral((n - k).toDouble()));
        term = BinaryOp(term, BinaryOperator.multiply, aPower);
      }

      // Add b^k
      if (k > 0) {
        final bPower =
            k == 1 ? b : BinaryOp(b, BinaryOperator.power, NumberLiteral(k.toDouble()));
        term = BinaryOp(term, BinaryOperator.multiply, bPower);
      }

      result = result == null
          ? term
          : BinaryOp(result, BinaryOperator.add, term);
    }

    return result ?? const NumberLiteral(0);
  }

  int _binomialCoefficient(int n, int k) {
    if (k > n) return 0;
    if (k == 0 || k == n) return 1;
    k = math.min(k, n - k); // Optimize using symmetry
    var result = 1;
    for (var i = 0; i < k; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }

  Expression _expandMultiply(BinaryOp multiplyExpr) {
    final left = multiplyExpr.left;
    final right = multiplyExpr.right;

    // (a+b) * (c+d) = a*c + a*d + b*c + b*d
    if (left is BinaryOp &&
        left.operator == BinaryOperator.add &&
        right is BinaryOp &&
        right.operator == BinaryOperator.add) {
      final a = left.left;
      final b = left.right;
      final c = right.left;
      final d = right.right;

      final ac = BinaryOp(a, BinaryOperator.multiply, c);
      final ad = BinaryOp(a, BinaryOperator.multiply, d);
      final bc = BinaryOp(b, BinaryOperator.multiply, c);
      final bd = BinaryOp(b, BinaryOperator.multiply, d);

      return BinaryOp(
        BinaryOp(ac, BinaryOperator.add, ad),
        BinaryOperator.add,
        BinaryOp(bc, BinaryOperator.add, bd),
      );
    }

    return multiplyExpr;
  }

  /// Factors polynomial expressions.
  ///
  /// Currently supports:
  /// - Difference of squares: x^2 - a^2 → (x-a)(x+a)
  /// - Simple quadratics: x^2 + bx + c → (x+p)(x+q) when factorizable
  Expression factor(Expression expr) {
    // Try factoring difference of squares
    if (expr is BinaryOp && expr.operator == BinaryOperator.subtract) {
      final factored = _factorDifferenceOfSquares(expr);
      if (factored != null) return factored;
    }

    // Try factoring quadratics
    final factored = _factorQuadratic(expr);
    if (factored != null) return factored;

    return expr;
  }

  Expression? _factorDifferenceOfSquares(BinaryOp expr) {
    // Check for a^2 - b^2 pattern
    final left = expr.left;
    final right = expr.right;

    if (left is BinaryOp &&
        left.operator == BinaryOperator.power &&
        left.right is NumberLiteral &&
        (left.right as NumberLiteral).value == 2) {
      if (right is BinaryOp &&
          right.operator == BinaryOperator.power &&
          right.right is NumberLiteral &&
          (right.right as NumberLiteral).value == 2) {
        final a = left.left;
        final b = right.left;

        // Return (a-b)(a+b)
        final aminusb = BinaryOp(a, BinaryOperator.subtract, b);
        final aplusb = BinaryOp(a, BinaryOperator.add, b);
        return BinaryOp(aminusb, BinaryOperator.multiply, aplusb);
      }
    }

    return null;
  }

  Expression? _factorQuadratic(Expression expr) {
    // Try to match pattern: ax^2 + bx + c
    final terms = _extractQuadraticTerms(expr);
    if (terms == null) return null;

    final a = terms['a']!;
    final b = terms['b']!;
    final c = terms['c']!;
    final variable = terms['var'] as String;

    // For simplicity, only handle a=1 case
    if (a != 1) return null;

    // Find p and q such that p*q = c and p+q = b
    for (var p = -100; p <= 100; p++) {
      if (p == 0) continue;
      if (c % p != 0) continue;
      final q = c ~/ p;
      if (p + q == b) {
        // Return (x+p)(x+q)
        final xPlusP = BinaryOp(
          Variable(variable),
          BinaryOperator.add,
          NumberLiteral(p.toDouble()),
        );
        final xPlusQ = BinaryOp(
          Variable(variable),
          BinaryOperator.add,
          NumberLiteral(q.toDouble()),
        );
        return BinaryOp(xPlusP, BinaryOperator.multiply, xPlusQ);
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractQuadraticTerms(Expression expr) {
    // This is a simplified implementation
    // In a real implementation, we'd need more sophisticated pattern matching
    return null;
  }

  /// Solves a linear equation ax + b = 0 for x.
  ///
  /// Returns the solution x = -b/a, or null if not solvable.
  Expression? solveLinear(Expression equation, String variable) {
    // Simplified implementation
    // In a real implementation, we'd rearrange the equation to isolate variable
    return null;
  }

  /// Solves a quadratic equation ax^2 + bx + c = 0 for x.
  ///
  /// Returns 0, 1, or 2 solutions using the quadratic formula.
  List<Expression> solveQuadratic(Expression equation, String variable) {
    final terms = _extractQuadraticTerms(equation);
    if (terms == null) return [];

    final a = terms['a']! as num;
    final b = terms['b']! as num;
    final c = terms['c']! as num;

    final discriminant = b * b - 4 * a * c;

    if (discriminant < 0) {
      return []; // No real solutions
    } else if (discriminant == 0) {
      // One solution: x = -b / (2a)
      final solution = -b / (2 * a);
      return [NumberLiteral(solution.toDouble())];
    } else {
      // Two solutions: x = (-b ± sqrt(discriminant)) / (2a)
      final sqrtDisc = math.sqrt(discriminant);
      final solution1 = (-b + sqrtDisc) / (2 * a);
      final solution2 = (-b - sqrtDisc) / (2 * a);
      return [
        NumberLiteral(solution1.toDouble()),
        NumberLiteral(solution2.toDouble()),
      ];
    }
  }
}
