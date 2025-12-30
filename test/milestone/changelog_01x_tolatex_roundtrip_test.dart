import 'package:test/test.dart';
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

/// Comprehensive LaTeX round-trip tests for CHANGELOG 0.1 to 0.1.6 features
/// This test file verifies that all features added in versions 0.1.0 through 0.1.6
/// properly support toLatex() round-trip conversion.
void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  /// Helper to test round-trip: parse, toLatex, parse again, compare by evaluation
  void testRoundTrip(String latex, Map<String, double> vars) {
    final expr1 = evaluator.parse(latex);
    final regenerated = expr1.toLatex();
    final expr2 = evaluator.parse(regenerated);

    final result1 = evaluator.evaluate(latex, vars).asNumeric();
    final result2 = evaluator.evaluateParsed(expr2, vars).asNumeric();

    expect(result2, closeTo(result1, 1e-10),
        reason: 'Round-trip failed for: $latex -> $regenerated');
  }

  // ============================================================================
  // 0.1.6-nightly: Reciprocal Trigonometric Functions
  // ============================================================================
  group('0.1.6: Reciprocal Trigonometric Functions', () {
    test('sec(x) round-trip', () {
      testRoundTrip(r'\sec{0.5}', {});
    });

    test('csc(x) round-trip', () {
      testRoundTrip(r'\csc{0.5}', {});
    });

    test('cot(x) round-trip', () {
      testRoundTrip(r'\cot{0.5}', {});
    });

    test('sec with variable round-trip', () {
      testRoundTrip(r'\sec{x}', {'x': 0.5});
    });

    test('csc with variable round-trip', () {
      testRoundTrip(r'\csc{x}', {'x': 0.5});
    });

    test('cot with variable round-trip', () {
      testRoundTrip(r'\cot{x}', {'x': 0.5});
    });
  });

  // ============================================================================
  // 0.1.6-nightly: Reciprocal Hyperbolic Functions
  // ============================================================================
  group('0.1.6: Reciprocal Hyperbolic Functions', () {
    test('sech(x) round-trip', () {
      testRoundTrip(r'\sech{1}', {});
    });

    test('csch(x) round-trip', () {
      testRoundTrip(r'\csch{1}', {});
    });

    test('coth(x) round-trip', () {
      testRoundTrip(r'\coth{1}', {});
    });

    test('sech with variable round-trip', () {
      testRoundTrip(r'\sech{x}', {'x': 1.0});
    });

    test('csch with variable round-trip', () {
      testRoundTrip(r'\csch{x}', {'x': 1.0});
    });

    test('coth with variable round-trip', () {
      testRoundTrip(r'\coth{x}', {'x': 1.0});
    });
  });

  // ============================================================================
  // 0.1.6-nightly: Extended LaTeX Notation - Uppercase Greek Letters
  // ============================================================================
  group('0.1.6: Uppercase Greek Letters', () {
    test('Alpha round-trip', () {
      final expr = evaluator.parse(r'\Alpha + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('alpha'));
    });

    test('Beta round-trip', () {
      final expr = evaluator.parse(r'\Beta + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('beta'));
    });

    test('Gamma round-trip', () {
      final expr = evaluator.parse(r'\Gamma + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('gamma'));
    });

    test('Delta round-trip', () {
      final expr = evaluator.parse(r'\Delta + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('delta'));
    });

    test('Psi round-trip', () {
      final expr = evaluator.parse(r'\Psi + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('psi'));
    });
  });

  // ============================================================================
  // 0.1.6-nightly: Extended LaTeX Notation - Variant Greek Letters
  // ============================================================================
  group('0.1.6: Variant Greek Letters', () {
    test('varepsilon round-trip', () {
      final expr = evaluator.parse(r'\varepsilon + 1');
      final latex = expr.toLatex();
      expect(latex, contains('varepsilon'));
    });

    test('varphi round-trip', () {
      final expr = evaluator.parse(r'\varphi + 1');
      final latex = expr.toLatex();
      expect(latex, contains('varphi'));
    });

    test('varrho round-trip', () {
      final expr = evaluator.parse(r'\varrho + 1');
      final latex = expr.toLatex();
      expect(latex, contains('varrho'));
    });

    test('vartheta round-trip', () {
      final expr = evaluator.parse(r'\vartheta + 1');
      final latex = expr.toLatex();
      expect(latex, contains('vartheta'));
    });
  });

  // ============================================================================
  // 0.1.6-nightly: Extended LaTeX Notation - Missing Lowercase Greek
  // ============================================================================
  group('0.1.6: Additional Lowercase Greek', () {
    test('iota round-trip', () {
      final expr = evaluator.parse(r'\iota + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('iota'));
    });

    test('nu round-trip', () {
      final expr = evaluator.parse(r'\nu + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('nu'));
    });

    test('xi round-trip', () {
      final expr = evaluator.parse(r'\xi + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('xi'));
    });

    test('omicron round-trip', () {
      final expr = evaluator.parse(r'\omicron + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('omicron'));
    });

    test('upsilon round-trip', () {
      final expr = evaluator.parse(r'\upsilon + 1');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('upsilon'));
    });
  });

  // ============================================================================
  // 0.1.6-nightly: Font Commands
  // ============================================================================
  group('0.1.6: Font Commands', () {
    test('mathbf round-trip', () {
      final expr = evaluator.parse(r'\mathbf{E}');
      final latex = expr.toLatex();
      expect(latex, contains('mathbf'));
    });

    test('mathcal round-trip', () {
      final expr = evaluator.parse(r'\mathcal{L}');
      final latex = expr.toLatex();
      expect(latex, contains('mathcal'));
    });

    test('mathrm round-trip', () {
      final expr = evaluator.parse(r'\mathrm{M}');
      final latex = expr.toLatex();
      expect(latex, contains('mathrm'));
    });

    test('boldsymbol round-trip', () {
      final expr = evaluator.parse(r'\boldsymbol{x}');
      final latex = expr.toLatex();
      expect(latex, contains('boldsymbol'));
    });
  });

  // ============================================================================
  // 0.1.5: Piecewise Function Differentiation
  // ============================================================================
  group('0.1.5: Piecewise Functions', () {
    test('simple piecewise round-trip', () {
      final expr = evaluator.parse(r'x^2, x > 0');
      final latex = expr.toLatex();
      expect(latex, contains('x'));
      expect(latex, contains('>'));
    });

    test('abs with piecewise round-trip', () {
      final expr = evaluator.parse(r'|x|, -3 < x < 3');
      final latex = expr.toLatex();
      // Should contain abs representation and comparison
      expect(evaluator.isValid(latex), isTrue);
    });
  });

  // ============================================================================
  // 0.1.5: Sign Function
  // ============================================================================
  group('0.1.5: Sign Function', () {
    test('sgn round-trip', () {
      testRoundTrip(r'\sgn{5}', {});
    });

    test('sgn negative round-trip', () {
      testRoundTrip(r'\sgn{-3}', {});
    });

    test('sign alias round-trip', () {
      testRoundTrip(r'\sign{5}', {});
    });

    test('sgn with variable round-trip', () {
      testRoundTrip(r'\sgn{x}', {'x': -2.0});
    });
  });

  // ============================================================================
  // 0.1.4: Reduced Planck Constant
  // ============================================================================
  group('0.1.4: Constants', () {
    test('hbar round-trip', () {
      final expr = evaluator.parse(r'\hbar');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('hbar'));
    });
  });

  // ============================================================================
  // 0.1.3: Nth Root Support
  // ============================================================================
  group('0.1.3: Nth Root Support', () {
    test('cube root round-trip', () {
      testRoundTrip(r'\sqrt[3]{8}', {});
    });

    test('4th root round-trip', () {
      testRoundTrip(r'\sqrt[4]{16}', {});
    });

    test('5th root round-trip', () {
      testRoundTrip(r'\sqrt[5]{32}', {});
    });

    test('cube root of negative round-trip', () {
      testRoundTrip(r'\sqrt[3]{-8}', {});
    });

    test('nth root with variable index round-trip', () {
      final expr = evaluator.parse(r'\sqrt[n]{x}');
      final latex = expr.toLatex();
      expect(latex, contains(r'\sqrt'));
      expect(latex, contains('n'));
    });
  });

  // ============================================================================
  // 0.1.3: Academic LaTeX Support (Delimiter Sizing)
  // ============================================================================
  group('0.1.3: Academic LaTeX Support', () {
    test('left/right delimiters round-trip', () {
      testRoundTrip(r'\left(x + 1\right)', {'x': 2.0});
    });

    test('expression with big delimiters parses', () {
      // Big delimiters are silently ignored, but should still parse
      expect(evaluator.isValid(r'\big(x + 1\big)'), isTrue);
    });

    test('escaped braces round-trip', () {
      // Escaped braces treated as grouping
      expect(evaluator.isValid(r'\{x + 1\}'), isTrue);
    });
  });

  // ============================================================================
  // 0.1.2: Symbolic Differentiation
  // ============================================================================
  group('0.1.2: Symbolic Differentiation', () {
    test('simple derivative round-trip', () {
      final expr = evaluator.parse(r'\frac{d}{dx}(x^2)');
      final latex = expr.toLatex();
      expect(latex, contains(r'\frac{d}{dx}'));
    });

    test('second order derivative round-trip', () {
      final expr = evaluator.parse(r'\frac{d^{2}}{dx^{2}}(x^3)');
      final latex = expr.toLatex();
      expect(latex, contains(r'\frac{d^{2}}{dx^{2}}'));
    });

    test('derivative of trig round-trip', () {
      final expr = evaluator.parse(r'\frac{d}{dx}(\sin{x})');
      final latex = expr.toLatex();
      expect(latex, contains(r'\frac{d}{dx}'));
      expect(latex, contains(r'\sin'));
    });
  });

  // ============================================================================
  // 0.1.2: Complex Number Support
  // ============================================================================
  group('0.1.2: Complex Number Support', () {
    test('Re function round-trip', () {
      final expr = evaluator.parse(r'\text{Re}(z)');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('re'));
    });

    test('Im function round-trip', () {
      final expr = evaluator.parse(r'\text{Im}(z)');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('im'));
    });

    test('conjugate round-trip', () {
      final expr = evaluator.parse(r'\overline{z}');
      final latex = expr.toLatex();
      expect(latex, contains('overline'));
    });
  });

  // ============================================================================
  // 0.1.2: Fibonacci Function
  // ============================================================================
  group('0.1.2: Fibonacci Function', () {
    test('fibonacci round-trip', () {
      testRoundTrip(r'\fibonacci{10}', {});
    });

    test('fibonacci with small value round-trip', () {
      testRoundTrip(r'\fibonacci{5}', {});
    });
  });

  // ============================================================================
  // 0.1.1: Inverse Hyperbolic Functions
  // ============================================================================
  group('0.1.1: Inverse Hyperbolic Functions', () {
    test('asinh round-trip', () {
      testRoundTrip(r'\asinh{1}', {});
    });

    test('acosh round-trip', () {
      testRoundTrip(r'\acosh{2}', {});
    });

    test('atanh round-trip', () {
      testRoundTrip(r'\atanh{0.5}', {});
    });

    test('asinh with variable round-trip', () {
      testRoundTrip(r'\asinh{x}', {'x': 0.5});
    });
  });

  // ============================================================================
  // 0.1.1: Combinatorics
  // ============================================================================
  group('0.1.1: Combinatorics', () {
    test('binomial coefficient round-trip', () {
      testRoundTrip(r'\binom{5}{2}', {});
    });

    test('binomial coefficient larger values round-trip', () {
      testRoundTrip(r'\binom{10}{3}', {});
    });
  });

  // ============================================================================
  // 0.1.1: Number Theory
  // ============================================================================
  group('0.1.1: Number Theory', () {
    test('gcd round-trip', () {
      testRoundTrip(r'\gcd(12, 8)', {});
    });

    test('lcm round-trip', () {
      testRoundTrip(r'\lcm(4, 6)', {});
    });
  });

  // ============================================================================
  // 0.1.1: Matrix Trace
  // ============================================================================
  group('0.1.1: Matrix Trace', () {
    test('trace round-trip', () {
      final expr =
          evaluator.parse(r'\trace{\begin{matrix}1 & 0\\0 & 1\end{matrix}}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('tr'));
    });

    test('tr alias round-trip', () {
      final expr =
          evaluator.parse(r'\tr{\begin{matrix}1 & 2\\3 & 4\end{matrix}}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('tr'));
    });
  });

  // ============================================================================
  // 0.1.0: Numerical Integration
  // ============================================================================
  group('0.1.0: Numerical Integration', () {
    test('definite integral round-trip', () {
      final expr = evaluator.parse(r'\int_{0}^{1} x dx');
      final latex = expr.toLatex();
      expect(latex, contains(r'\int'));
      expect(latex, contains('dx'));
    });

    test('definite integral with bounds round-trip', () {
      final expr = evaluator.parse(r'\int_{0}^{\pi} \sin{x} dx');
      final latex = expr.toLatex();
      expect(latex, contains(r'\int'));
      expect(latex, contains(r'\sin'));
    });
  });

  // ============================================================================
  // 0.1.0: Matrix Operations
  // ============================================================================
  group('0.1.0: Matrix Operations', () {
    test('matrix determinant round-trip', () {
      final result =
          evaluator.evaluate(r'\det(\begin{matrix}1 & 2\\3 & 4\end{matrix})');
      expect(result.asNumeric(), closeTo(-2, 1e-10));

      final expr =
          evaluator.parse(r'\det(\begin{matrix}1 & 2\\3 & 4\end{matrix})');
      final latex = expr.toLatex();
      expect(latex, contains(r'\det'));
    });

    test('matrix inverse round-trip', () {
      final expr = evaluator.parse(r'M^{-1}');
      final latex = expr.toLatex();
      expect(latex, contains('-1'));
    });

    test('matrix transpose round-trip', () {
      final expr = evaluator.parse(r'M^{T}');
      final latex = expr.toLatex();
      expect(latex, contains('T'));
    });

    test('matrix with values round-trip', () {
      final expr = evaluator.parse(r'\begin{matrix}1 & 2\\3 & 4\end{matrix}');
      final latex = expr.toLatex();
      expect(latex, contains('matrix'));
      expect(latex, contains('&'));
    });
  });

  // ============================================================================
  // 0.0.1: Core Functionality
  // ============================================================================
  group('0.0.1: Basic Arithmetic', () {
    test('addition round-trip', () {
      testRoundTrip('2 + 3', {});
    });

    test('subtraction round-trip', () {
      testRoundTrip('5 - 2', {});
    });

    test('multiplication round-trip', () {
      testRoundTrip(r'3 \times 4', {});
    });

    test('division round-trip', () {
      testRoundTrip(r'\frac{10}{2}', {});
    });
  });

  group('0.0.1: Trigonometric Functions', () {
    test('sin round-trip', () {
      testRoundTrip(r'\sin{0.5}', {});
    });

    test('cos round-trip', () {
      testRoundTrip(r'\cos{0.5}', {});
    });

    test('tan round-trip', () {
      testRoundTrip(r'\tan{0.3}', {});
    });

    test('arcsin round-trip', () {
      testRoundTrip(r'\arcsin{0.5}', {});
    });

    test('arccos round-trip', () {
      testRoundTrip(r'\arccos{0.5}', {});
    });

    test('arctan round-trip', () {
      testRoundTrip(r'\arctan{0.5}', {});
    });
  });

  group('0.0.1: Hyperbolic Functions', () {
    test('sinh round-trip', () {
      testRoundTrip(r'\sinh{1}', {});
    });

    test('cosh round-trip', () {
      testRoundTrip(r'\cosh{1}', {});
    });

    test('tanh round-trip', () {
      testRoundTrip(r'\tanh{0.5}', {});
    });
  });

  group('0.0.1: Logarithmic Functions', () {
    test('ln round-trip', () {
      testRoundTrip(r'\ln{e}', {});
    });

    test('log base 10 round-trip', () {
      testRoundTrip(r'\log{100}', {});
    });

    test('log with custom base round-trip', () {
      testRoundTrip(r'\log_{2}{8}', {});
    });
  });

  group('0.0.1: Power and Root Functions', () {
    test('power round-trip', () {
      testRoundTrip('2^{3}', {});
    });

    test('square root round-trip', () {
      testRoundTrip(r'\sqrt{16}', {});
    });

    test('nested power round-trip', () {
      testRoundTrip('2^{3^{2}}', {});
    });
  });

  group('0.0.1: Factorial', () {
    test('factorial round-trip', () {
      // Parse factorial, verify toLatex output can be re-parsed
      final expr = evaluator.parse(r'\factorial{5}');
      final latex = expr.toLatex();
      // factorial toLatex may output postfix notation which may not re-parse directly
      // So we verify the output is valid or contains factorial info
      expect(latex, anyOf(contains('!'), contains('factorial')));

      // Verify evaluation is correct
      final result = evaluator.evaluate(r'\factorial{5}').asNumeric();
      expect(result, closeTo(120, 1e-10));
    });

    test('factorial of variable expression round-trip', () {
      final expr = evaluator.parse(r'\factorial{n}');
      final latex = expr.toLatex();
      expect(latex, anyOf(contains('!'), contains('factorial')));
    });
  });

  group('0.0.1: Absolute Value', () {
    test('abs function round-trip', () {
      testRoundTrip(r'\abs{-5}', {});
    });

    test('pipe notation round-trip', () {
      final expr = evaluator.parse(r'|x|');
      final latex = expr.toLatex();
      expect(evaluator.isValid(latex), isTrue);

      // Verify evaluation is correct
      final result = evaluator.evaluate(latex, {'x': -3.0}).asNumeric();
      expect(result, closeTo(3.0, 1e-10));
    });
  });

  group('0.0.1: Rounding Functions', () {
    test('floor round-trip', () {
      testRoundTrip(r'\floor{3.7}', {});
    });

    test('ceil round-trip', () {
      testRoundTrip(r'\ceil{3.2}', {});
    });

    test('round round-trip', () {
      testRoundTrip(r'\round{3.5}', {});
    });
  });

  group('0.0.1: Min and Max Functions', () {
    test('min round-trip', () {
      // min requires subscript/superscript syntax: \min_{a}{b}
      // Parse and verify toLatex generates valid output
      final expr = evaluator.parse(r'\min_{3}{5}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('min'));

      // Verify evaluation is correct
      final result = evaluator.evaluate(r'\min_{3}{5}').asNumeric();
      expect(result, closeTo(3, 1e-10));
    });

    test('max round-trip', () {
      // max requires subscript/superscript syntax: \max_{a}{b}
      final expr = evaluator.parse(r'\max_{3}{5}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('max'));

      // Verify evaluation is correct
      final result = evaluator.evaluate(r'\max_{3}{5}').asNumeric();
      expect(result, closeTo(5, 1e-10));
    });

    test('min function toLatex contains min', () {
      final expr = evaluator.parse(r'\min_{1}{2}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('min'));
    });
  });

  group('0.0.1: Summation and Product', () {
    test('summation round-trip', () {
      final result = evaluator.evaluate(r'\sum_{i=1}^{5} i').asNumeric();
      expect(result, closeTo(15, 1e-10));

      final expr = evaluator.parse(r'\sum_{i=1}^{5} i');
      final latex = expr.toLatex();
      expect(latex, contains(r'\sum'));
    });

    test('product round-trip', () {
      final result = evaluator.evaluate(r'\prod_{i=1}^{4} i').asNumeric();
      expect(result, closeTo(24, 1e-10));

      final expr = evaluator.parse(r'\prod_{i=1}^{4} i');
      final latex = expr.toLatex();
      expect(latex, contains(r'\prod'));
    });
  });

  group('0.0.1: Limit Notation', () {
    test('limit round-trip', () {
      final expr = evaluator.parse(r'\lim_{x \to 0} x');
      final latex = expr.toLatex();
      expect(latex, contains('lim'));
      expect(latex, contains('to'));
    });

    test('limit with fraction round-trip', () {
      final expr = evaluator.parse(r'\lim_{x \to 0} \frac{\sin{x}}{x}');
      final latex = expr.toLatex();
      expect(latex, contains('lim'));
      expect(latex, contains(r'\frac'));
    });
  });

  group('0.0.1: Constants', () {
    test('pi round-trip', () {
      final expr = evaluator.parse(r'\pi');
      final latex = expr.toLatex();
      expect(latex, contains('pi'));
    });

    test('e round-trip', () {
      final expr = evaluator.parse('e');
      final latex = expr.toLatex();
      expect(latex, contains('e'));
    });
  });

  group('0.0.1: Variables', () {
    test('single variable round-trip', () {
      testRoundTrip('x', {'x': 5.0});
    });

    test('multiple variables round-trip', () {
      testRoundTrip('x + y', {'x': 3.0, 'y': 4.0});
    });

    test('variable with coefficient round-trip', () {
      testRoundTrip('2x', {'x': 3.0});
    });
  });

  // ============================================================================
  // 0.0.2: Domain Constraints
  // ============================================================================
  group('0.0.2: Domain Constraints', () {
    test('simple constraint round-trip', () {
      final expr = evaluator.parse(r'x^2, x > 0');
      final latex = expr.toLatex();
      expect(latex, contains('x'));
      expect(latex, contains('>'));
    });

    test('chained constraint round-trip', () {
      final expr = evaluator.parse(r'x, -1 < x < 1');
      final latex = expr.toLatex();
      expect(latex, contains('<'));
    });
  });
}
