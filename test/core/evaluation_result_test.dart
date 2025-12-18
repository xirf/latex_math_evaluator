import 'package:test/test.dart';
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  group('EvaluationResult', () {
    group('NumericResult', () {
      test('isNumeric returns true', () {
        final result = NumericResult(5.0);
        expect(result.isNumeric, isTrue);
        expect(result.isMatrix, isFalse);
      });

      test('asNumeric returns value', () {
        final result = NumericResult(5.0);
        expect(result.asNumeric(), 5.0);
      });

      test('asMatrix throws StateError', () {
        final result = NumericResult(5.0);
        expect(() => result.asMatrix(), throwsStateError);
      });

      test('isNaN returns true for NaN value', () {
        final result = NumericResult(double.nan);
        expect(result.isNaN, isTrue);
      });

      test('isNaN returns false for finite value', () {
        final result = NumericResult(5.0);
        expect(result.isNaN, isFalse);
      });

      test('isNaN returns false for infinity', () {
        final result = NumericResult(double.infinity);
        expect(result.isNaN, isFalse);
      });
    });

    group('MatrixResult', () {
      final matrix = Matrix([
        [1, 2],
        [3, 4]
      ]);

      test('isMatrix returns true', () {
        final result = MatrixResult(matrix);
        expect(result.isMatrix, isTrue);
        expect(result.isNumeric, isFalse);
      });

      test('asMatrix returns matrix', () {
        final result = MatrixResult(matrix);
        expect(result.asMatrix(), matrix);
      });

      test('asNumeric throws StateError', () {
        final result = MatrixResult(matrix);
        expect(() => result.asNumeric(), throwsStateError);
      });

      test('isNaN always returns false', () {
        final result = MatrixResult(matrix);
        expect(result.isNaN, isFalse);
      });
    });
  });
}
