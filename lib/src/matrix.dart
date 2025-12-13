import 'exceptions.dart';

/// Represents a mathematical matrix of double values.
///
/// This class provides methods for matrix operations such as addition,
/// subtraction, multiplication, determinant, trace, and inverse.
///
/// Example:
/// ```dart
/// final matrix = Matrix([
///   [1, 2],
///   [3, 4]
/// ]);
/// print(matrix.determinant()); // -2.0
/// ```
class Matrix {
  /// The raw data of the matrix, stored as a list of rows.
  final List<List<double>> data;

  /// Creates a matrix from a list of rows.
  ///
  /// [data] must be a non-empty list of non-empty lists of doubles,
  /// and all rows must have the same length.
  Matrix(this.data);

  /// The number of rows in the matrix.
  int get rows => data.length;

  /// The number of columns in the matrix.
  int get cols => data.isEmpty ? 0 : data[0].length;

  /// Returns the row at the given [index].
  List<double> operator [](int index) => data[index];

  /// Returns the transpose of this matrix.
  ///
  /// The transpose of a matrix is formed by swapping rows and columns.
  Matrix transpose() {
    return Matrix(List.generate(cols, (i) {
      return List.generate(rows, (j) {
        return data[j][i];
      });
    }));
  }

  /// Calculates the determinant of this matrix.
  ///
  /// The matrix must be square (rows == cols).
  /// Throws [EvaluatorException] if the matrix is not square.
  double determinant() {
    if (rows != cols) {
      throw EvaluatorException('Determinant requires a square matrix');
    }
    if (rows == 1) return data[0][0];
    if (rows == 2) {
      return data[0][0] * data[1][1] - data[0][1] * data[1][0];
    }

    // Laplace expansion for larger matrices (not efficient for very large matrices but simple)
    double det = 0;
    for (int j = 0; j < cols; j++) {
      det += data[0][j] * _cofactor(0, j);
    }
    return det;
  }

  /// Calculates the trace of this matrix.
  ///
  /// The trace is the sum of the elements on the main diagonal.
  /// The matrix must be square (rows == cols).
  /// Throws [EvaluatorException] if the matrix is not square.
  double trace() {
    if (rows != cols) {
      throw EvaluatorException('Trace requires a square matrix');
    }
    double sum = 0;
    for (int i = 0; i < rows; i++) {
      sum += data[i][i];
    }
    return sum;
  }

  /// Calculates the inverse of this matrix.
  ///
  /// The matrix must be square and non-singular (determinant != 0).
  /// Throws [EvaluatorException] if the matrix is not square or is singular.
  Matrix inverse() {
    if (rows != cols) {
      throw EvaluatorException('Inverse requires a square matrix');
    }
    final det = determinant();
    if (det == 0) {
      throw EvaluatorException('Matrix is singular (determinant is 0)');
    }

    // Adjugate matrix method
    final adjugate = Matrix(List.generate(rows, (i) {
      return List.generate(cols, (j) {
        return _cofactor(j, i); // Note the swap of indices for transpose
      });
    }));

    return adjugate * (1 / det);
  }

  double _cofactor(int row, int col) {
    return ((row + col) % 2 == 0 ? 1 : -1) * _minor(row, col).determinant();
  }

  Matrix _minor(int row, int col) {
    return Matrix(
      data
          .asMap()
          .entries
          .where((e) => e.key != row)
          .map((e) => e.value
              .asMap()
              .entries
              .where((e) => e.key != col)
              .map((e) => e.value)
              .toList())
          .toList(),
    );
  }

  /// Adds this matrix to [other].
  ///
  /// Both matrices must have the same dimensions.
  /// Throws [EvaluatorException] if dimensions mismatch.
  Matrix operator +(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw EvaluatorException('Matrix dimensions mismatch for addition');
    }
    return Matrix(List.generate(rows, (i) {
      return List.generate(cols, (j) {
        return data[i][j] + other.data[i][j];
      });
    }));
  }

  /// Subtracts [other] from this matrix.
  ///
  /// Both matrices must have the same dimensions.
  /// Throws [EvaluatorException] if dimensions mismatch.
  Matrix operator -(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw EvaluatorException('Matrix dimensions mismatch for subtraction');
    }
    return Matrix(List.generate(rows, (i) {
      return List.generate(cols, (j) {
        return data[i][j] - other.data[i][j];
      });
    }));
  }

  /// Multiplies this matrix by [other].
  ///
  /// [other] can be a [num] (scalar multiplication) or a [Matrix] (matrix multiplication).
  ///
  /// For matrix multiplication, the number of columns in this matrix must equal
  /// the number of rows in [other].
  ///
  /// Throws [EvaluatorException] if dimensions mismatch or operand is invalid.
  Matrix operator *(dynamic other) {
    if (other is num) {
      // Scalar multiplication
      return Matrix(List.generate(rows, (i) {
        return List.generate(cols, (j) {
          return data[i][j] * other;
        });
      }));
    } else if (other is Matrix) {
      // Matrix multiplication
      if (cols != other.rows) {
        throw EvaluatorException(
            'Matrix dimensions mismatch for multiplication');
      }
      return Matrix(List.generate(rows, (i) {
        return List.generate(other.cols, (j) {
          double sum = 0;
          for (int k = 0; k < cols; k++) {
            sum += data[i][k] * other.data[k][j];
          }
          return sum;
        });
      }));
    } else {
      throw EvaluatorException('Invalid operand for matrix multiplication');
    }
  }

  @override
  String toString() {
    return data.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Matrix) return false;
    if (rows != other.rows || cols != other.cols) return false;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (data[i][j] != other.data[i][j]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(data.map((row) => Object.hashAll(row)));
}
