/// Type-safe evaluation result classes.
library;

import 'matrix.dart';

/// Base sealed class for evaluation results.
///
/// All evaluation results are either [NumericResult] or [MatrixResult].
/// This provides type safety when working with evaluation results.
///
/// Example:
/// ```dart
/// final evaluator = LatexMathEvaluator();
/// final result = evaluator.evaluate('2 + 3');
///
/// switch (result) {
///   case NumericResult(:final value):
///     print('Numeric result: $value');
///   case MatrixResult(:final matrix):
///     print('Matrix result: $matrix');
/// }
/// ```
sealed class EvaluationResult {
  const EvaluationResult();

  /// Converts the result to a numeric value.
  ///
  /// Throws [StateError] if the result is a [MatrixResult].
  double asNumeric() {
    return switch (this) {
      NumericResult(:final value) => value,
      MatrixResult() => throw StateError('Result is a matrix, not a number'),
    };
  }

  /// Converts the result to a matrix.
  ///
  /// Throws [StateError] if the result is a [NumericResult].
  Matrix asMatrix() {
    return switch (this) {
      NumericResult() => throw StateError('Result is a number, not a matrix'),
      MatrixResult(:final matrix) => matrix,
    };
  }

  /// Returns true if this is a numeric result.
  bool get isNumeric => this is NumericResult;

  /// Returns true if this is a matrix result.
  bool get isMatrix => this is MatrixResult;

  /// Returns true if the result is Not-a-Number (NaN).
  ///
  /// For [NumericResult], this returns true if the value is NaN.
  /// For [MatrixResult], this always returns false.
  bool get isNaN;
}

/// Represents a numeric evaluation result.
final class NumericResult extends EvaluationResult {
  /// The numeric value of the result.
  final double value;

  /// Creates a numeric result with the given [value].
  const NumericResult(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumericResult &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NumericResult($value)';

  @override
  bool get isNaN => value.isNaN;
}

/// Represents a matrix evaluation result.
final class MatrixResult extends EvaluationResult {
  /// The matrix value of the result.
  final Matrix matrix;

  /// Creates a matrix result with the given [matrix].
  const MatrixResult(this.matrix);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatrixResult &&
          runtimeType == other.runtimeType &&
          matrix == other.matrix;

  @override
  int get hashCode => matrix.hashCode;

  @override
  String toString() => 'MatrixResult($matrix)';

  @override
  bool get isNaN => false;
}
