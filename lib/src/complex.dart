import 'dart:math' as math;

/// Represents a complex number with real and imaginary parts.
class Complex {
  /// The real part of the complex number.
  final double real;

  /// The imaginary part of the complex number.
  final double imaginary;

  /// Creates a complex number.
  const Complex(this.real, [this.imaginary = 0]);

  /// Creates a complex number from a numeric value (real only).
  factory Complex.fromNum(num value) => Complex(value.toDouble());

  /// Returns true if the imaginary part is zero (effectively a real number).
  bool get isReal => imaginary == 0;

  /// Returns true if the real part is zero (purely imaginary).
  bool get isImaginary => real == 0 && imaginary != 0;

  /// Returns the modulus (magnitude) of the complex number.
  double get abs => math.sqrt(real * real + imaginary * imaginary);

  /// Returns the argument (phase) of the complex number.
  double get arg => math.atan2(imaginary, real);

  /// Returns the conjugate of the complex number.
  Complex get conjugate => Complex(real, -imaginary);

  /// Adds this complex number to [other].
  Complex operator +(Object other) {
    if (other is Complex) {
      return Complex(real + other.real, imaginary + other.imaginary);
    } else if (other is num) {
      return Complex(real + other, imaginary);
    }
    throw ArgumentError('Cannot add ${other.runtimeType} to Complex');
  }

  /// Subtracts [other] from this complex number.
  Complex operator -(Object other) {
    if (other is Complex) {
      return Complex(real - other.real, imaginary - other.imaginary);
    } else if (other is num) {
      return Complex(real - other, imaginary);
    }
    throw ArgumentError('Cannot subtract ${other.runtimeType} from Complex');
  }

  /// Multiplies this complex number by [other].
  Complex operator *(Object other) {
    if (other is Complex) {
      return Complex(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );
    } else if (other is num) {
      return Complex(real * other, imaginary * other);
    }
    throw ArgumentError('Cannot multiply Complex by ${other.runtimeType}');
  }

  /// Divides this complex number by [other].
  Complex operator /(Object other) {
    if (other is Complex) {
      final denom = other.real * other.real + other.imaginary * other.imaginary;
      return Complex(
        (real * other.real + imaginary * other.imaginary) / denom,
        (imaginary * other.real - real * other.imaginary) / denom,
      );
    } else if (other is num) {
      return Complex(real / other, imaginary / other);
    }
    throw ArgumentError('Cannot divide Complex by ${other.runtimeType}');
  }

  /// Negates this complex number.
  Complex operator -() => Complex(-real, -imaginary);

  @override
  String toString() {
    if (imaginary == 0) return real.toString();
    if (real == 0) return '${imaginary}i';
    final sign = imaginary < 0 ? '-' : '+';
    return '$real $sign ${imaginary.abs()}i';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is num) return real == other && imaginary == 0;
    return other is Complex &&
        real == other.real &&
        imaginary == other.imaginary;
  }

  @override
  int get hashCode => Object.hash(real, imaginary);
}
