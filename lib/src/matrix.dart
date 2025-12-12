import 'exceptions.dart';

/// A simple matrix class for evaluation.
class Matrix {
  final List<List<double>> data;

  Matrix(this.data);

  int get rows => data.length;
  int get cols => data.isEmpty ? 0 : data[0].length;

  List<double> operator [](int index) => data[index];

  Matrix transpose() {
    return Matrix(List.generate(cols, (i) {
      return List.generate(rows, (j) {
        return data[j][i];
      });
    }));
  }

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
        throw EvaluatorException('Matrix dimensions mismatch for multiplication');
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
