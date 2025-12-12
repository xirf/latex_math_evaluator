// LaTeX Math Evaluator - Example Usage
//
// Run with: dart run example/main.dart

import 'package:latex_math_evaluator/latex_math_evaluator.dart';
import 'dart:math' as math;

void main() {
  final evaluator = LatexMathEvaluator();

  print('=== Basic Arithmetic ===');
  print(r'2 + 3 × 4 = ${evaluator.evaluate(r"2 + 3 \times 4")}');
  print(r'10 ÷ 2 = ${evaluator.evaluate(r"10 \div 2")}');
  print(r'2^{10} = ${evaluator.evaluate(r"2^{10}")}');

  print('\n=== Variables ===');
  print('x² + 1 where x=3: ${evaluator.evaluate(r"x^{2} + 1", {"x": 3})}');
  print('a × b where a=5, b=7: ${evaluator.evaluate(r"a \times b", {
        "a": 5,
        "b": 7
      })}');

  print('\n=== Trigonometry ===');
  print('sin(0) = ${evaluator.evaluate(r"\sin{0}")}');
  print('cos(0) = ${evaluator.evaluate(r"\cos{0}")}');
  print('tan(0) = ${evaluator.evaluate(r"\tan{0}")}');

  print('\n=== Logarithms ===');
  print('ln(e) ≈ ${evaluator.evaluate(r"\ln{x}", {"x": math.e})}');
  print('log₁₀(100) = ${evaluator.evaluate(r"\log{100}")}');
  print('log₂(8) = ${evaluator.evaluate(r"\log_{2}{8}")}');

  print('\n=== Other Functions ===');
  print('√16 = ${evaluator.evaluate(r"\sqrt{16}")}');
  print('|−5| = ${evaluator.evaluate(r"\abs{-5}")}');
  print('5! = ${evaluator.evaluate(r"\factorial{5}")}');
  print('⌈1.2⌉ = ${evaluator.evaluate(r"\ceil{1.2}")}');
  print('⌊1.8⌋ = ${evaluator.evaluate(r"\floor{1.8}")}');

  print('\n=== Constants ===');
  print('e = ${evaluator.evaluate("e")}');
  // Note: Multi-char constants need to be bound to single-letter variables

  print('\n=== Summation ===');
  print('∑(i=1 to 5) i = ${evaluator.evaluate(r"\sum_{i=1}^{5} i")}');
  print('∑(i=1 to 3) i² = ${evaluator.evaluate(r"\sum_{i=1}^{3} i^{2}")}');

  print('\n=== Product ===');
  print('∏(i=1 to 5) i = 5! = ${evaluator.evaluate(r"\prod_{i=1}^{5} i")}');
  print('∏(i=1 to 3) 2 = 2³ = ${evaluator.evaluate(r"\prod_{i=1}^{3} 2")}');

  print('\n=== Custom Extensions ===');
  customExtensionExample();
}

void customExtensionExample() {
  // Create extension registry
  final registry = ExtensionRegistry();

  // Register cube root command: \cbrt
  registry.registerCommand(
      'cbrt',
      (cmd, pos) =>
          Token(type: TokenType.function, value: 'cbrt', position: pos));

  // Register cube root evaluator
  registry.registerEvaluator((expr, vars, evaluate) {
    if (expr is FunctionCall && expr.name == 'cbrt') {
      final arg = evaluate(expr.argument);
      return math.pow(arg, 1 / 3).toDouble();
    }
    return null;
  });

  // Use with extensions
  final evaluator = LatexMathEvaluator(extensions: registry);
  print('∛27 = ${evaluator.evaluate(r"\cbrt{27}")}');
  print('∛8 = ${evaluator.evaluate(r"\cbrt{8}")}');
}
