import 'dart:math' as math;
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  print('=== Parse & Reuse Example ===\n');

  final evaluator = LatexMathEvaluator();

  // The expression we'll reuse. Parsing a LaTeX expression once and
  // reusing the parsed AST is significantly more memory- and CPU-efficient
  // than parsing it each time you evaluate with different variables.
  final latexExpr = r'x^{2} + 5x - 3';
  print('Equation: x² + 5x - 3\n');

  // Parse once
  final parsed = evaluator.parse(latexExpr);

  // Evaluate with different values for x
  final values = [10, 5, 0, -2];
  print('Evaluating parsed expression for multiple x values:');
  for (final x in values) {
    final result = evaluator.evaluateParsed(parsed, {'x': x.toDouble()});
    final output = result.isNumeric ? result.asNumeric() : result;
    print('  x = $x -> $output');
  }

  // Quick comparison vs parsing every time (simple benchmark)
  const iterations = 2000;
  print('\nPerformance comparison ($iterations runs each):');

  final stopwatch1 = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    evaluator.evaluate(latexExpr, {'x': (i % 100).toDouble()});
  }
  stopwatch1.stop();
  print('  Parse+Evaluate each time: ${stopwatch1.elapsedMilliseconds}ms');

  final stopwatch2 = Stopwatch()..start();
  final parsedOnce = evaluator.parse(latexExpr);
  for (var i = 0; i < iterations; i++) {
    evaluator.evaluateParsed(parsedOnce, {'x': (i % 100).toDouble()});
  }
  stopwatch2.stop();
  print('  Parse once, reuse parsed AST: ${stopwatch2.elapsedMilliseconds}ms');

  if (stopwatch2.elapsedMilliseconds > 0) {
    final speedup =
        stopwatch1.elapsedMilliseconds / stopwatch2.elapsedMilliseconds;
    print('  Speedup: ${speedup.toStringAsFixed(2)}x');
  } else {
    print('  Reuse is significantly faster (too quick to accurately measure).');
  }

  // Bonus: parsing once also makes it easy to evaluate other variable combos
  print('\nBonus: same parsed expression, different variable types:');
  final p = evaluator.evaluateParsed(parsed, {'x': math.pi / 4});
  final v = evaluator.evaluateParsed(parsed, {'x': 2.5});
  print('  x = π/4 -> ${p.isNumeric ? p.asNumeric() : p}');
  print('  x = 2.5 -> ${v.isNumeric ? v.asNumeric() : v}');

  print('\nTip: Use `parse()` + `evaluateParsed()` for repeated evaluations.');
}
