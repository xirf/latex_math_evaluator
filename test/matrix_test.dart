import 'package:latex_math_evaluator/latex_math_evaluator.dart';
import 'package:test/test.dart';

void main() {
  test('Matrix evaluation', () {
    final evaluator = LatexMathEvaluator();
    // Simple 2x2 matrix
    // \begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}
    final matrix = '\\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix}';

    final result = evaluator.evaluate(matrix);
    expect(result, isA<Matrix>());
    final m = result as Matrix;
    expect(m.rows, 2);
    expect(m.cols, 2);
    expect(m.data[0][0], 1.0);
    expect(m.data[0][1], 2.0);
    expect(m.data[1][0], 3.0);
    expect(m.data[1][1], 4.0);
  });

  test('Matrix addition', () {
    final evaluator = LatexMathEvaluator();
    final expr =
        '\\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix} + \\begin{matrix} 5 & 6 \\\\ 7 & 8 \\end{matrix}';
    final result = evaluator.evaluate(expr);
    expect(result, isA<Matrix>());
    final m = result as Matrix;
    expect(m.data[0][0], 6.0);
    expect(m.data[0][1], 8.0);
    expect(m.data[1][0], 10.0);
    expect(m.data[1][1], 12.0);
  });

  test('Matrix multiplication', () {
    final evaluator = LatexMathEvaluator();
    // [1 2] * [5 6] = [1*5+2*7 1*6+2*8] = [19 22]
    // [3 4]   [7 8]   [3*5+4*7 3*6+4*8]   [43 50]
    final expr =
        '\\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix} * \\begin{matrix} 5 & 6 \\\\ 7 & 8 \\end{matrix}';
    final result = evaluator.evaluate(expr);
    expect(result, isA<Matrix>());
    final m = result as Matrix;
    expect(m.data[0][0], 19.0);
    expect(m.data[0][1], 22.0);
    expect(m.data[1][0], 43.0);
    expect(m.data[1][1], 50.0);
  });

  test('Matrix scalar multiplication', () {
    final evaluator = LatexMathEvaluator();
    final expr = '2 * \\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix}';
    final result = evaluator.evaluate(expr);
    expect(result, isA<Matrix>());
    final m = result as Matrix;
    expect(m.data[0][0], 2.0);
    expect(m.data[0][1], 4.0);
    expect(m.data[1][0], 6.0);
    expect(m.data[1][1], 8.0);
  });
}
