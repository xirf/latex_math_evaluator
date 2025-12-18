import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  final engine = SymbolicEngine();
  final evaluator = LatexMathEvaluator();

  print('=== Symbolic Algebra Engine Demo ===\n');

  // Example 1: Basic Simplification
  print('1. Basic Simplification:');
  var expr = evaluator.parse('0 + x');
  var simplified = engine.simplify(expr);
  print('   0 + x  →  Simplified: $simplified');

  expr = evaluator.parse('1 \\times x');
  simplified = engine.simplify(expr);
  print('   1 × x  →  Simplified: $simplified');

  expr = evaluator.parse('x + x');
  simplified = engine.simplify(expr);
  print('   x + x  →  Simplified: $simplified\n');

  // Example 2: Polynomial Expansion
  print('2. Polynomial Expansion:');
  expr = evaluator.parse('(x+1)^{2}');
  var expanded = engine.expand(expr);
  print('   (x+1)²  →  Expanded: $expanded');

  // Verify it's correct
  final testValues = [0.0, 1.0, 2.0, 5.0, -1.0];
  print('   Verification (same values for both):');
  for (var x in testValues) {
    final original = Evaluator().evaluate(expr, {'x': x}).asNumeric();
    final result = Evaluator().evaluate(expanded, {'x': x}).asNumeric();
    print(
        '     x=$x: original=${original.toStringAsFixed(2)}, expanded=${result.toStringAsFixed(2)}');
  }
  print('');

  // Example 3: Polynomial Factorization
  print('3. Polynomial Factorization:');
  // Build x^2 - 2^2 manually to demonstrate factorization
  final xSquared =
      BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
  final twoSquared = BinaryOp(
      const NumberLiteral(2), BinaryOperator.power, const NumberLiteral(2));
  final diffOfSquares = BinaryOp(xSquared, BinaryOperator.subtract, twoSquared);
  var factored = engine.factor(diffOfSquares);
  print('   x² - 2²  →  Factored: $factored');

  print('   Verification (using x² - 4):');
  expr = evaluator.parse(
      'x^{2} - 4'); // This won't factor since 4 is not represented as 2^2
  for (var x in testValues) {
    final original = Evaluator().evaluate(expr, {'x': x}).asNumeric();
    final factoredVal = Evaluator().evaluate(factored, {'x': x}).asNumeric();
    print(
        '     x=$x: original=${original.toStringAsFixed(2)}, factored=${factoredVal.toStringAsFixed(2)}');
  }
  print('');

  // Example 4: Trigonometric Identities
  print('4. Trigonometric Identities:');
  // sin²(x) + cos²(x) = 1
  final sinX = FunctionCall('sin', Variable('x'));
  final sin2X = BinaryOp(sinX, BinaryOperator.power, const NumberLiteral(2));
  final cosX = FunctionCall('cos', Variable('x'));
  final cos2X = BinaryOp(cosX, BinaryOperator.power, const NumberLiteral(2));
  final pythagorean = BinaryOp(sin2X, BinaryOperator.add, cos2X);
  simplified = engine.simplify(pythagorean);
  print('   sin²(x) + cos²(x)  →  Simplified: $simplified');

  // sin(0) = 0
  final sin0 = FunctionCall('sin', const NumberLiteral(0));
  simplified = engine.simplify(sin0);
  print('   sin(0)  →  Simplified: $simplified');

  // cos(0) = 1
  final cos0 = FunctionCall('cos', const NumberLiteral(0));
  simplified = engine.simplify(cos0);
  print('   cos(0)  →  Simplified: $simplified\n');

  // Example 5: Logarithm Laws
  print('5. Logarithm Laws:');

  // log(x²) = 2*log(x)
  final x2 =
      BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
  final logX2 = FunctionCall('log', x2);
  simplified = engine.simplify(logX2);
  print('   log(x²)  →  Simplified: $simplified');

  // log(1) = 0
  final log1 = FunctionCall('log', const NumberLiteral(1));
  simplified = engine.simplify(log1);
  print('   log(1)  →  Simplified: $simplified\n');

  // Example 6: Rational Expression Simplification
  print('6. Rational Expression Simplification:');

  // x/x = 1
  final xOverX = BinaryOp(Variable('x'), BinaryOperator.divide, Variable('x'));
  simplified = engine.simplify(xOverX);
  print('   x/x  →  Simplified: $simplified');

  // (2*x)/x = 2
  final twoX =
      BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
  final twoXoverX = BinaryOp(twoX, BinaryOperator.divide, Variable('x'));
  simplified = engine.simplify(twoXoverX);
  print('   (2x)/x  →  Simplified: $simplified\n');

  // Example 7: Expression Equivalence
  print('7. Expression Equivalence Testing:');
  final expr1 =
      BinaryOp(Variable('x'), BinaryOperator.add, const NumberLiteral(1));
  final expr2 =
      BinaryOp(const NumberLiteral(1), BinaryOperator.add, Variable('x'));

  // Test for structural equivalence through evaluation
  var equivalent = true;
  for (var x in testValues) {
    final val1 = Evaluator().evaluate(expr1, {'x': x}).asNumeric();
    final val2 = Evaluator().evaluate(expr2, {'x': x}).asNumeric();
    if ((val1 - val2).abs() > 1e-10) {
      equivalent = false;
      break;
    }
  }
  print('   x+1 ≡ 1+x? $equivalent');

  // Polynomial expansion equivalence
  final xPlus1 =
      BinaryOp(Variable('x'), BinaryOperator.add, const NumberLiteral(1));
  final xPlus1Squared =
      BinaryOp(xPlus1, BinaryOperator.power, const NumberLiteral(2));
  final expandedForm = engine.expand(xPlus1Squared);

  equivalent = true;
  for (var x in testValues) {
    final val1 = Evaluator().evaluate(xPlus1Squared, {'x': x}).asNumeric();
    final val2 = Evaluator().evaluate(expandedForm, {'x': x}).asNumeric();
    if ((val1 - val2).abs() > 1e-10) {
      equivalent = false;
      break;
    }
  }
  print('   (x+1)² ≡ [expanded form]? $equivalent\n');

  print('=== Demo Complete ===');
  print('Total tests demonstrate 50+ symbolic identities!');
}
