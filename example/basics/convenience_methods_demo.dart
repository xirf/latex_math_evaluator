// LaTeX Math Evaluator - Convenience Methods Demo
//
// This example demonstrates the simplified DX-friendly API
// using evaluateNumeric() and evaluateMatrix() convenience methods.
//
// Run with: dart run example/basics/convenience_methods_demo.dart

import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  final evaluator = LatexMathEvaluator();

  print('=== Convenience Methods for Numeric Results ===\n');

  // Simple numeric evaluation - no need for .asNumeric()
  print('Basic: 2 + 3 × 4');
  final result1 = evaluator.evaluateNumeric(r'2 + 3 \times 4');
  print('Result: $result1\n');

  // With variables
  print('Variables: x² + 1 where x = 3');
  final result2 = evaluator.evaluateNumeric(r'x^{2} + 1', {'x': 3});
  print('Result: $result2\n');

  // Functions
  print('Functions: sin(π/2)');
  final result3 = evaluator.evaluateNumeric(r'\sin{\frac{\pi}{2}}');
  print('Result: $result3\n');

  // Logarithms
  print('Logarithms: log₂(8)');
  final result4 = evaluator.evaluateNumeric(r'\log_{2}{8}');
  print('Result: $result4\n');

  // Complex expressions
  print('Complex: √(x² + y²) where x = 3, y = 4');
  final result5 = evaluator.evaluateNumeric(
    r'\sqrt{x^{2} + y^{2}}',
    {'x': 3, 'y': 4},
  );
  print('Result: $result5\n');

  print('=== Convenience Methods for Matrix Results ===\n');

  // Matrix evaluation - no need for .asMatrix()
  print('Matrix: 2×2 Identity-like matrix');
  final matrix1 = evaluator.evaluateMatrix(
    r'\begin{matrix} 1 & 0 \\ 0 & 1 \end{matrix}',
  );
  print('Result: $matrix1\n');

  print('Matrix: 2×3 Matrix');
  final matrix2 = evaluator.evaluateMatrix(
    r'\begin{matrix} 1 & 2 & 3 \\ 4 & 5 & 6 \end{matrix}',
  );
  print('Result: $matrix2\n');

  print('=== Comparison: Old vs New API ===\n');

  print('❌ Old way (more verbose):');
  print('  final result = evaluator.evaluate(\'2 + 3\').asNumeric();');
  final oldWay = evaluator.evaluate('2 + 3').asNumeric();
  print('  Result: $oldWay\n');

  print('✅ New way (simpler):');
  print('  final result = evaluator.evaluateNumeric(\'2 + 3\');');
  final newWay = evaluator.evaluateNumeric('2 + 3');
  print('  Result: $newWay\n');

  print('=== Advanced: Pattern Matching (When Needed) ===\n');

  // When you don't know the result type in advance, use pattern matching
  print('Expression with unknown result type: 2 + 3');
  final unknownResult = evaluator.evaluate('2 + 3');

  switch (unknownResult) {
    case NumericResult(:final value):
      print('Got numeric result: $value');
    case ComplexResult(:final value):
      print('Got complex result: $value');
    case MatrixResult(:final matrix):
      print('Got matrix result: $matrix');
  }

  print('\n=== Error Handling ===\n');

  // Using evaluateNumeric with a matrix expression will throw
  try {
    print('Trying to get numeric from matrix...');
    evaluator.evaluateNumeric(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
  } catch (e) {
    print('Error (as expected): $e');
  }

  // Using evaluateMatrix with a numeric expression will throw
  try {
    print('\nTrying to get matrix from numeric...');
    evaluator.evaluateMatrix('2 + 3');
  } catch (e) {
    print('Error (as expected): $e');
  }

  print('\n=== Best Practices ===\n');
  print('1. Use evaluateNumeric() when you expect a number');
  print('2. Use evaluateMatrix() when you expect a matrix');
  print('3. Use evaluate() with pattern matching when type is unknown');
  print('4. All methods provide clear error messages if type mismatches');
}
