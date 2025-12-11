import 'exceptions.dart';

/// A simple matrix class for evaluation.
class Matrix {
  final List<List<double>> data;

  Matrix(this.data);

  int get rows => data.length;
  int get cols => data.isEmpty ? 0 : data[0].length;

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
