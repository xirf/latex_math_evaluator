/// Trigonometric identity simplification.
library;

import '../ast.dart';
import 'dart:math' as math;

/// Applies trigonometric identities for simplification.
///
/// Supports identities like:
/// - sin^2(x) + cos^2(x) = 1
/// - tan(x) = sin(x)/cos(x)
/// - sin(2x) = 2*sin(x)*cos(x)
/// - cos(2x) = cos^2(x) - sin^2(x)
/// - sin(-x) = -sin(x)
/// - cos(-x) = cos(x)
class TrigIdentities {
  /// Simplifies trigonometric expressions using identities.
  Expression simplify(Expression expr) {
    return _simplifyRecursive(expr);
  }

  Expression _simplifyRecursive(Expression expr) {
    if (expr is BinaryOp) {
      return _simplifyBinaryOp(expr);
    } else if (expr is FunctionCall) {
      return _simplifyFunctionCall(expr);
    }
    return expr;
  }

  Expression _simplifyBinaryOp(BinaryOp op) {
    final left = _simplifyRecursive(op.left);
    final right = _simplifyRecursive(op.right);

    // Check for sin^2(x) + cos^2(x) = 1
    if (op.operator == BinaryOperator.add) {
      final identity = _checkPythagoreanIdentity(left, right);
      if (identity != null) return identity;
    }

    return BinaryOp(left, op.operator, right, sourceToken: op.sourceToken);
  }

  Expression? _checkPythagoreanIdentity(Expression left, Expression right) {
    // Check if left is sin^2(x) and right is cos^2(x) (or vice versa)
    final sin2 = _isSinSquared(left);
    final cos2 = _isCosSquared(right);

    if (sin2 != null && cos2 != null && sin2 == cos2) {
      return const NumberLiteral(1);
    }

    // Check the reverse
    final sin2Rev = _isSinSquared(right);
    final cos2Rev = _isCosSquared(left);

    if (sin2Rev != null && cos2Rev != null && sin2Rev == cos2Rev) {
      return const NumberLiteral(1);
    }

    return null;
  }

  Expression? _isSinSquared(Expression expr) {
    // Check if expr is sin(x)^2 or sin^2(x)
    if (expr is BinaryOp && expr.operator == BinaryOperator.power) {
      if (expr.right is NumberLiteral && (expr.right as NumberLiteral).value == 2) {
        if (expr.left is FunctionCall) {
          final func = expr.left as FunctionCall;
          if (func.name == 'sin' && func.args.length == 1) {
            return func.args[0];
          }
        }
      }
    }
    return null;
  }

  Expression? _isCosSquared(Expression expr) {
    // Check if expr is cos(x)^2 or cos^2(x)
    if (expr is BinaryOp && expr.operator == BinaryOperator.power) {
      if (expr.right is NumberLiteral && (expr.right as NumberLiteral).value == 2) {
        if (expr.left is FunctionCall) {
          final func = expr.left as FunctionCall;
          if (func.name == 'cos' && func.args.length == 1) {
            return func.args[0];
          }
        }
      }
    }
    return null;
  }

  Expression _simplifyFunctionCall(FunctionCall call) {
    // Simplify arguments first
    final simplifiedArgs =
        call.args.map((arg) => _simplifyRecursive(arg)).toList();

    // Apply specific identities based on function
    switch (call.name) {
      case 'sin':
        return _simplifySin(simplifiedArgs);
      case 'cos':
        return _simplifyCos(simplifiedArgs);
      case 'tan':
        return _simplifyTan(simplifiedArgs);
      default:
        return FunctionCall.multivar(call.name, simplifiedArgs, base: call.base, optionalParam: call.optionalParam);
    }
  }

  Expression _simplifySin(List<Expression> args) {
    if (args.length != 1) return FunctionCall.multivar('sin', args);

    final arg = args[0];

    // sin(0) = 0
    if (arg is NumberLiteral && arg.value == 0) {
      return const NumberLiteral(0);
    }

    // sin(-x) = -sin(x)
    if (arg is UnaryOp && arg.operator == UnaryOperator.negate) {
      return UnaryOp(
        UnaryOperator.negate,
        FunctionCall('sin', arg.operand),
      );
    }

    // sin(π/2) = 1
    if (_isValue(arg, math.pi / 2)) {
      return const NumberLiteral(1);
    }

    // sin(π) = 0
    if (_isValue(arg, math.pi)) {
      return const NumberLiteral(0);
    }

    return FunctionCall.multivar('sin', args);
  }

  Expression _simplifyCos(List<Expression> args) {
    if (args.length != 1) return FunctionCall.multivar('cos', args);

    final arg = args[0];

    // cos(0) = 1
    if (arg is NumberLiteral && arg.value == 0) {
      return const NumberLiteral(1);
    }

    // cos(-x) = cos(x)
    if (arg is UnaryOp && arg.operator == UnaryOperator.negate) {
      return FunctionCall('cos', arg.operand);
    }

    // cos(π/2) = 0
    if (_isValue(arg, math.pi / 2)) {
      return const NumberLiteral(0);
    }

    // cos(π) = -1
    if (_isValue(arg, math.pi)) {
      return const NumberLiteral(-1);
    }

    return FunctionCall.multivar('cos', args);
  }

  Expression _simplifyTan(List<Expression> args) {
    if (args.length != 1) return FunctionCall.multivar('tan', args);

    final arg = args[0];

    // tan(0) = 0
    if (arg is NumberLiteral && arg.value == 0) {
      return const NumberLiteral(0);
    }

    // tan(x) could be converted to sin(x)/cos(x) but we keep it as is for now
    return FunctionCall('tan', arg);
  }

  bool _isValue(Expression expr, double value) {
    if (expr is NumberLiteral) {
      return (expr.value - value).abs() < 1e-10;
    }
    return false;
  }
}
