import 'package:test/test.dart';
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  group('LatexMathEvaluator Integration', () {
    final evaluator = LatexMathEvaluator();

    group('basic arithmetic', () {
      test('addition', () {
        expect(evaluator.evaluate('2 + 3'), 5.0);
      });

      test('subtraction', () {
        expect(evaluator.evaluate('5 - 2'), 3.0);
      });

      test('multiplication with times', () {
        expect(evaluator.evaluate(r'2 \times 3'), 6.0);
      });

      test('multiplication with cdot', () {
        expect(evaluator.evaluate(r'2 \cdot 3'), 6.0);
      });

      test('division', () {
        expect(evaluator.evaluate(r'6 \div 2'), 3.0);
      });

      test('power', () {
        expect(evaluator.evaluate('2^{3}'), 8.0);
      });
    });

    group('operator precedence', () {
      test('PEMDAS: add and multiply', () {
        expect(evaluator.evaluate(r'2 + 3 \times 4'), 14.0);
      });

      test('PEMDAS: multiply and power', () {
        expect(evaluator.evaluate(r'2 \times 3^{2}'), 18.0);
      });

      test('parentheses override precedence', () {
        expect(evaluator.evaluate(r'(2 + 3) \times 4'), 20.0);
      });

      test('braces work like parentheses', () {
        expect(evaluator.evaluate(r'{2 + 3} \times 4'), 20.0);
      });
    });

    group('variables', () {
      test('simple variable', () {
        expect(evaluator.evaluate('x', {'x': 5}), 5.0);
      });

      test('expression with variable', () {
        expect(evaluator.evaluate('x + 1', {'x': 2}), 3.0);
      });

      test('multiple variables', () {
        expect(evaluator.evaluate('x + y', {'x': 2, 'y': 3}), 5.0);
      });

      test('variable in power', () {
        expect(evaluator.evaluate('x^{2}', {'x': 3}), 9.0);
      });

      test('variable base and exponent', () {
        expect(evaluator.evaluate('x^{y}', {'x': 2, 'y': 3}), 8.0);
      });
    });

    group('complex expressions', () {
      test('quadratic: x^2 + 2x + 1 at x=3', () {
        expect(
          evaluator.evaluate(r'x^{2} + 2 \times x + 1', {'x': 3}),
          16.0,
        );
      });

      test('nested parentheses', () {
        expect(
          evaluator.evaluate('((1 + 2) + 3)'),
          6.0,
        );
      });

      test('unary minus', () {
        expect(evaluator.evaluate('-x', {'x': 5}), -5.0);
      });

      test('double negative', () {
        expect(evaluator.evaluate('--5'), 5.0);
      });

      test('negative in expression', () {
        expect(evaluator.evaluate('2 + -3'), -1.0);
      });
    });

    group('decimal numbers', () {
      test('decimal addition', () {
        expect(evaluator.evaluate('1.5 + 2.5'), 4.0);
      });

      test('decimal variable', () {
        expect(evaluator.evaluate('x + 0.5', {'x': 1.5}), 2.0);
      });
    });
  });
}
