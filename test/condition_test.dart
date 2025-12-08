import 'package:latex_math_evaluator/latex_math_evaluator.dart';
import 'package:test/test.dart';

void main() {
  group('Equations with Constraints', () {
    late LatexMathEvaluator evaluator;

    setUp(() {
      evaluator = LatexMathEvaluator();
    });

    test('f(x)=x^{2}-2{-1<x<2} with x=0 (valid)', () {
      final result = evaluator.evaluate("f(x)=x^{2}-2{-1<x<2}", {'x': 0});
      expect(result, -2.0);
    });

    test('f(x)=x^{2}-2{-1<x<2} with x=3 (invalid)', () {
      final result = evaluator.evaluate("f(x)=x^{2}-2{-1<x<2}", {'x': 3});
      expect(result.isNaN, isTrue);
    });

    test('x^2-2, -1 < x < 2 with x=0 (valid)', () {
      final result = evaluator.evaluate("x^2-2, -1 < x < 2", {'x': 0});
      expect(result, -2.0);
    });

    test('x^2-2, -1 < x < 2 with x=3 (invalid)', () {
      final result = evaluator.evaluate("x^2-2, -1 < x < 2", {'x': 3});
      expect(result.isNaN, isTrue);
    });
  });
}
