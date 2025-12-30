/// Benchmark comparing latex_math_evaluator (LaTeX) vs math_expressions (text).
///
/// Both are Dart libraries - this is the most fair apples-to-apples comparison
/// since it removes language runtime differences.
import 'package:latex_math_evaluator/latex_math_evaluator.dart';
import 'package:math_expressions/math_expressions.dart' as me;

void main() {
  print('================================================================');
  print('DART LIBRARY COMPARISON: LaTeX vs Text Expression Parsing');
  print('================================================================');
  print('');
  print('latex_math_evaluator: Parses full LaTeX (\\sin{x}, \\frac{a}{b})');
  print('math_expressions:     Parses simple text (sin(x), a/b)');
  print('');

  // Expressions in both formats
  final expressions = [
    (
      'Simple Arithmetic',
      r'1 + 2 + 3 + 4 + 5', // LaTeX
      '1 + 2 + 3 + 4 + 5', // text
      <String, double>{},
    ),
    (
      'Multiplication',
      r'x * y * z', // LaTeX
      'x * y * z', // text
      <String, double>{'x': 2, 'y': 3, 'z': 4},
    ),
    (
      'Trigonometry',
      r'\sin(x) + \cos(x)', // LaTeX
      'sin(x) + cos(x)', // text
      <String, double>{'x': 0.5},
    ),
    (
      'Power & Sqrt',
      r'\sqrt{x^2 + y^2}', // LaTeX
      'sqrt(x^2 + y^2)', // text
      <String, double>{'x': 3, 'y': 4},
    ),
    (
      'Polynomial',
      r'x^3 + 2*x^2 - 5*x + 7', // LaTeX
      'x^3 + 2*x^2 - 5*x + 7', // text
      <String, double>{'x': 2},
    ),
    (
      'Nested Functions',
      r'\sin(\cos(x))', // LaTeX
      'sin(cos(x))', // text
      <String, double>{'x': 1},
    ),
  ];

  const iterations = 1000;

  // =========================================================
  // 1. LATEX_MATH_EVALUATOR - No Cache (raw performance)
  // =========================================================
  print('--- latex_math_evaluator (No Cache) ---');
  print('Measures: Full LaTeX parse + evaluate\n');

  final latexEval = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);

  for (final (desc, latex, _, vars) in expressions) {
    // Warmup
    for (var i = 0; i < 100; i++) {
      latexEval.evaluate(latex, vars);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      latexEval.evaluate(latex, vars);
    }
    sw.stop();
    print(
        '  $desc: ${(sw.elapsedMicroseconds / iterations).toStringAsFixed(2)} µs/op');
  }

  // =========================================================
  // 2. MATH_EXPRESSIONS (text parser)
  // =========================================================
  print('\n--- math_expressions (Text Parser) ---');
  print('Measures: Simple text parse + evaluate\n');

  final meParser = me.Parser();

  for (final (desc, _, text, vars) in expressions) {
    // Build context model for math_expressions
    final cm = me.ContextModel();
    for (final entry in vars.entries) {
      cm.bindVariable(me.Variable(entry.key), me.Number(entry.value));
    }

    // Warmup
    for (var i = 0; i < 100; i++) {
      final expr = meParser.parse(text);
      expr.evaluate(me.EvaluationType.REAL, cm);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      final expr = meParser.parse(text);
      expr.evaluate(me.EvaluationType.REAL, cm);
    }
    sw.stop();
    print(
        '  $desc: ${(sw.elapsedMicroseconds / iterations).toStringAsFixed(2)} µs/op');
  }

  // =========================================================
  // 3. BOTH WITH PARSE-ONCE (optimal hot-loop)
  // =========================================================
  print('\n--- Parse Once + Evaluate (Hot Loop Optimal) ---\n');

  print('latex_math_evaluator (evaluateParsed):');
  for (final (desc, latex, _, vars) in expressions) {
    final ast = latexEval.parse(latex);

    // Warmup
    for (var i = 0; i < 100; i++) {
      latexEval.evaluateParsed(ast, vars);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      latexEval.evaluateParsed(ast, vars);
    }
    sw.stop();
    print(
        '  $desc: ${(sw.elapsedMicroseconds / iterations).toStringAsFixed(2)} µs/op');
  }

  print('\nmath_expressions (evaluate pre-parsed):');
  for (final (desc, _, text, vars) in expressions) {
    final cm = me.ContextModel();
    for (final entry in vars.entries) {
      cm.bindVariable(me.Variable(entry.key), me.Number(entry.value));
    }
    final expr = meParser.parse(text);

    // Warmup
    for (var i = 0; i < 100; i++) {
      expr.evaluate(me.EvaluationType.REAL, cm);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      expr.evaluate(me.EvaluationType.REAL, cm);
    }
    sw.stop();
    print(
        '  $desc: ${(sw.elapsedMicroseconds / iterations).toStringAsFixed(2)} µs/op');
  }

  print('\n================================================================');
  print('SUMMARY');
  print('================================================================');
  print('Both libraries are Dart - this removes language runtime differences.');
  print('latex_math_evaluator parses complex LaTeX grammar.');
  print('math_expressions parses simpler text grammar.');
}
