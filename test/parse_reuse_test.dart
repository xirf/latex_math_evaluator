import 'package:test/test.dart';
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  group('Parse and Reuse', () {
    final evaluator = LatexMathEvaluator();

    test('parse returns an Expression', () {
      final ast = evaluator.parse('2 + 3');
      expect(ast, isA<Expression>());
    });

    test('evaluateParsed works with pre-parsed expression', () {
      final ast = evaluator.parse('x + 1');
      expect(evaluator.evaluateParsed(ast, {'x': 2}), 3.0);
      expect(evaluator.evaluateParsed(ast, {'x': 5}), 6.0);
      expect(evaluator.evaluateParsed(ast, {'x': 10}), 11.0);
    });

    test('reuse quadratic expression multiple times', () {
      final ast = evaluator.parse(r'x^{2} + 2x + 1');

      expect(evaluator.evaluateParsed(ast, {'x': 0}), 1.0);
      expect(evaluator.evaluateParsed(ast, {'x': 1}), 4.0);
      expect(evaluator.evaluateParsed(ast, {'x': 2}), 9.0);
      expect(evaluator.evaluateParsed(ast, {'x': -1}), 0.0);
    });

    test('reuse multi-variable expression', () {
      final ast = evaluator.parse('a + b * c');

      expect(evaluator.evaluateParsed(ast, {'a': 1, 'b': 2, 'c': 3}), 7.0);
      expect(evaluator.evaluateParsed(ast, {'a': 10, 'b': 5, 'c': 2}), 20.0);
      expect(evaluator.evaluateParsed(ast, {'a': 0, 'b': 0, 'c': 0}), 0.0);
    });

    test('reuse trigonometric expression', () {
      final ast = evaluator.parse(r'\sin{x}');

      expect(evaluator.evaluateParsed(ast, {'x': 0}), 0.0);
      expect(evaluator.evaluateParsed(ast, {'x': 1.5708}), closeTo(1.0, 0.001));
    });

    test('reuse with different variable sets', () {
      final ast = evaluator.parse('x + y');

      expect(evaluator.evaluateParsed(ast, {'x': 1, 'y': 2}), 3.0);
      expect(evaluator.evaluateParsed(ast, {'x': 10, 'y': 20}), 30.0);
      expect(evaluator.evaluateParsed(ast, {'x': -5, 'y': 5}), 0.0);
    });

    test('parse once is equivalent to parse+evaluate each time', () {
      const expr = r'x^{3} - 2x^{2} + x - 5';
      final ast = evaluator.parse(expr);

      for (int i = 0; i < 10; i++) {
        final direct = evaluator.evaluate(expr, {'x': i.toDouble()});
        final reused = evaluator.evaluateParsed(ast, {'x': i.toDouble()});
        expect(reused, direct);
      }
    });

    test('reuse with fractions', () {
      final ast = evaluator.parse(r'\frac{a}{b}');

      expect(evaluator.evaluateParsed(ast, {'a': 1, 'b': 2}), 0.5);
      expect(evaluator.evaluateParsed(ast, {'a': 3, 'b': 4}), 0.75);
      expect(evaluator.evaluateParsed(ast, {'a': 10, 'b': 5}), 2.0);
    });

    test('reuse with complex expression', () {
      final ast = evaluator.parse(r'2x^{2} + 3y - \sqrt{z}');

      expect(evaluator.evaluateParsed(ast, {'x': 2, 'y': 3, 'z': 4}),
          closeTo(15.0, 0.001));
      expect(evaluator.evaluateParsed(ast, {'x': 1, 'y': 1, 'z': 9}),
          closeTo(2.0, 0.001));
    });

    test('parse with implicit multiplication', () {
      final ast = evaluator.parse('2x');

      expect(evaluator.evaluateParsed(ast, {'x': 3}), 6.0);
      expect(evaluator.evaluateParsed(ast, {'x': 10}), 20.0);
    });

    test('evaluateParsed without variables uses constants', () {
      final ast = evaluator.parse(r'\pi');
      final result = evaluator.evaluateParsed(ast);

      expect(result, closeTo(3.14159, 0.00001));
    });
  });
}
