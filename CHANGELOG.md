# CHANGELOG

## 0.1.1

- Added option to disable implicit multiplication (`allowImplicitMultiplication` in `LatexMathEvaluator`).
- Added support for **Inverse Hyperbolic Functions**: `\asinh`, `\acosh`, `\atanh`.
- Added support for **Combinatorics**: `\binom{n}{k}`.
- Added support for **Number Theory**: `\gcd(a, b)`, `\lcm(a, b)`.
- Added support for **Matrix Trace**: `\trace{M}`, `\tr{M}`.

## 0.1.0

- **BREAKING CHANGE**: `evaluate` method now returns `dynamic` instead of `double` to support matrix results.

- Added support for **Numerical Integration** using Simpson's Rule (`\int_{a}^{b} f(x) dx`).
- Added support for **Matrix Determinant** (`\det(M)`).
- Added support for **Matrix Inverse** (`M^{-1}`).
- Added support for **Matrix Transpose** (`M^T`).
- Updated `Tokenizer` to support `\int` and `\det`.
- Added support for matrix evaluation and operations (addition, subtraction, multiplication).
- Added `Matrix` class.

## 0.0.2

- Added support for equation with domain constraints

## 0.0.1

- Initial release
- Added support for basic arithmetic operations
- Added support for trigonometric functions
- Added support for logarithmic functions
- Added support for power and root functions
- Added support for factorial function
- Added support for absolute value function
- Added support for rounding functions
- Added support for min and max functions
- Added support for summation and product notation
- Added support for limit notation
- Added support for constants
- Added support for variables
- Added support for functions
- Added support for custom extensions
