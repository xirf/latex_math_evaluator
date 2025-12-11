import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  final evaluator = LatexMathEvaluator();

  print('--- Advanced Matrix Operations ---');

  // 1. Matrix Transpose
  // [[1, 2], [3, 4]]^T -> [[1, 3], [2, 4]]
  final transposeExpr = r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}^T';
  final transposeResult = evaluator.evaluate(transposeExpr);
  print('Transpose of [[1, 2], [3, 4]]:');
  printMatrix(transposeResult);

  // 2. Matrix Determinant
  // det([[1, 2], [3, 4]]) = 1*4 - 2*3 = -2
  final detExpr = r'\det(\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix})';
  final detResult = evaluator.evaluate(detExpr);
  print('Determinant of [[1, 2], [3, 4]]: $detResult');

  // 3. Matrix Inverse
  // [[4, 7], [2, 6]]^-1
  final invExpr = r'\begin{pmatrix} 4 & 7 \\ 2 & 6 \end{pmatrix}^{-1}';
  final invResult = evaluator.evaluate(invExpr);
  print('Inverse of [[4, 7], [2, 6]]:');
  printMatrix(invResult);

  print('\n--- Numerical Integration ---');

  // 1. Polynomial Integration
  // \int_0^1 x^2 dx = [x^3/3]_0^1 = 1/3
  final polyInt = r'\int_{0}^{1} x^2 dx';
  final polyResult = evaluator.evaluate(polyInt);
  print('Integral of x^2 from 0 to 1: $polyResult (Expected: ~0.333)');

  // 2. Trigonometric Integration
  // \int_0^\pi \sin(x) dx = 2
  final trigInt = r'\int_{0}^{\pi} \sin(x) dx';
  final trigResult = evaluator.evaluate(trigInt);
  print('Integral of sin(x) from 0 to pi: $trigResult (Expected: ~2.0)');

  // 3. Exponential Integration
  // \int_0^1 e^x dx = e - 1 ~= 1.718
  final expInt = r'\int_{0}^{1} e^x dx';
  final expResult = evaluator.evaluate(expInt);
  print('Integral of e^x from 0 to 1: $expResult (Expected: ~1.718)');
}

void printMatrix(dynamic result) {
  if (result is Matrix) {
    for (int i = 0; i < result.rows; i++) {
      print(result[i]);
    }
  } else {
    print(result);
  }
}
