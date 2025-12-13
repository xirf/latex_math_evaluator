# LaTeX Math Evaluator

> A powerful Flutter/Dart library for parsing and evaluating mathematical expressions written in LaTeX format.

[![Tests](https://img.shields.io/badge/tests-294%20passed-brightgreen)](https://github.com/xirf/latex_math_evaluator)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)](https://github.com/xirf/latex_math_evaluator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Pub Version](https://img.shields.io/pub/v/latex_math_evaluator)](https://pub.dev/packages/latex_math_evaluator)

## Why LaTeX Math Evaluator?

- **Parse LaTeX expressions** into an Abstract Syntax Tree (AST)
- **Evaluate with variables** and reuse parsed expressions for better performance
- **Validate before execution** with detailed, actionable error messages
- **30+ mathematical functions** including trigonometry, logarithms, and matrix operations
- **Advanced notation** for summation, products, limits, and numerical integration
- **Extensible architecture** to add your own custom functions and commands

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  latex_math_evaluator: ^0.0.2
```

Or use the latest development version:

```yaml
dependencies:
  latex_math_evaluator:
    git:
      url: https://github.com/xirf/latex_math_evaluator.git
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

final evaluator = LatexMathEvaluator();

// Basic arithmetic
print(evaluator.evaluateNumeric(r'2 + 3 \times 4'));  // 14.0

// With variables
print(evaluator.evaluateNumeric(r'x^{2} + 1', {'x': 3}));  // 10.0

// Trigonometric functions
print(evaluator.evaluateNumeric(r'\sin{\pi}'));  // 0.0

// Fractions and roots
print(evaluator.evaluateNumeric(r'\frac{\sqrt{16}}{2}'));  // 2.0

// Summation
print(evaluator.evaluateNumeric(r'\sum_{i=1}^{5} i'));  // 15.0
```

## Core Features

### 1. Variable Binding and Reusability

Parse once, evaluate many times with different variable values:

```dart
final evaluator = LatexMathEvaluator();

// Parse the expression once
final equation = evaluator.parse(r'x^{2} + 2x + 1');

// Evaluate with different values (faster than reparsing)
print(evaluator.evaluateParsed(equation, {'x': 1}));  // 4.0
print(evaluator.evaluateParsed(equation, {'x': 2}));  // 9.0
print(evaluator.evaluateParsed(equation, {'x': 3}));  // 16.0

// Multi-variable expressions
final multiVar = evaluator.parse(r'2x + 3y - z');
print(evaluator.evaluateParsed(multiVar, {
  'x': 1, 'y': 2, 'z': 3
}));  // 5.0
```

### 2. Expression Validation

Catch errors before evaluation with detailed feedback:

```dart
final evaluator = LatexMathEvaluator();

// Quick validation
if (evaluator.isValid(r'\sin{x}')) {
  print('Valid syntax!');
}

// Detailed error information
final result = evaluator.validate(r'\frac{1{2}');
if (!result.isValid) {
  print('Error: ${result.errorMessage}');
  print('Position: ${result.position}');
  print('Suggestion: ${result.suggestion}');
}
```

**Error messages** show exactly where problems occur:

```
ParserException at position 10: Expected '}' after numerator

\frac{1{2}
          ^
Suggestion: Add a closing brace } or check for matching braces
```

[Learn more about validation →](doc/validation.md)

### 3. Type-Safe Results

Handle different result types safely:

```dart
final result = evaluator.evaluate(r'2 + 3');

// Pattern matching (Dart 3.0+)
switch (result) {
  case NumericResult(:final value):
    print('Number: $value');
  case MatrixResult(:final matrix):
    print('Matrix: $matrix');
}

// Type checking
if (result.isNumeric) {
  print(result.asNumeric());
}
```

### 4. Matrix Operations

Full support for matrix notation and operations:

```dart
// Create matrices
final matrixA = evaluator.evaluateMatrix(
  r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}'
);

// Matrix operations
evaluator.evaluateMatrix(r'A + B', {
  'A': [[1, 2], [3, 4]],
  'B': [[5, 6], [7, 8]]
});  // [[6, 8], [10, 12]]

// Determinant
evaluator.evaluateNumeric(r'\det{A}', {
  'A': [[1, 2], [3, 4]]
});  // -2.0

// Transpose
evaluator.evaluateMatrix(r'A^{T}', {
  'A': [[1, 2], [3, 4]]
});  // [[1, 3], [2, 4]]
```

## Supported Operations

### Functions by Category

**Trigonometric**
```dart
\sin, \cos, \tan, \asin, \acos, \atan
```

**Hyperbolic**
```dart
\sinh, \cosh, \tanh, \asinh, \acosh, \atanh
```

**Logarithmic**
```dart
\ln, \log, \log_{2}{8}  // Custom base
```

**Rounding**
```dart
\ceil, \floor, \round
```

**Power and Roots**
```dart
\sqrt, \sqrt[3]{27}, \exp
```

**Matrix Operations**
```dart
\det, \trace, \tr
```

**Combinatorics**
```dart
\binom{n}{k}  // Binomial coefficient
```

**Number Theory**
```dart
\gcd(a, b), \lcm(a, b)
```

**Other**
```dart
\abs, |x|, \sgn, \factorial, \min_{a}{b}, \max_{a}{b}
```

### Mathematical Constants

Constants are available with or without backslash notation:

| Constant | LaTeX    | Symbol | Value      | Usage       |
|----------|----------|--------|------------|-------------|
| Pi       | `\pi`    | π      | 3.14159... | `\pi` or `pi` |
| Euler    | `\e`     | e      | 2.71828... | `\e` or `e`   |
| Tau      | `\tau`   | τ      | 6.28318... | `\tau` or `tau` |
| Phi      | `\phi`   | φ      | 1.61803... | `\phi` or `phi` |
| Gamma    | `\gamma` | γ      | 0.57721... | `\gamma` or `gamma` |

> **Note:** User-provided variables always override built-in constants.

### Advanced Notation

**Fractions**
```latex
\frac{a + b}{c}
```

**Summation**
```latex
\sum_{i=1}^{10} i^{2}
```

**Products**
```latex
\prod_{i=1}^{5} i  // Factorial: 120
```

**Limits** (numeric approximation)
```latex
\lim_{x \to 0} \frac{\sin{x}}{x}
```

**Numerical Integration** (Simpson's Rule)
```latex
\int_{0}^{\pi} \sin{x} dx
```

**Absolute Value**
```latex
|x|, |-5|, |x^2 - 4|
```

**Domain Constraints**
```latex
f(x) = 2x - 3, 3 < x < 5
```

## Configuration Options

### Implicit Multiplication

Control how adjacent variables are interpreted:

```dart
// Enabled (default): xy means x * y
final evaluator1 = LatexMathEvaluator();
print(evaluator1.evaluate('xy', {'x': 2, 'y': 3}));  // 6.0

// Disabled: xy is treated as a single variable
final evaluator2 = LatexMathEvaluator(
  allowImplicitMultiplication: false
);
print(evaluator2.evaluate('xy', {'xy': 10}));  // 10.0
```

## Extending the Library

Add custom functions and commands:

```dart
import 'dart:math' as math;

final registry = ExtensionRegistry();

// Register a custom command
registry.registerCommand('cbrt', (cmd, pos) =>
  Token(type: TokenType.function, value: 'cbrt', position: pos)
);

// Register the evaluator
registry.registerEvaluator((expr, vars, evaluate) {
  if (expr is FunctionCall && expr.name == 'cbrt') {
    final arg = evaluate(expr.argument);
    return math.pow(arg, 1/3).toDouble();
  }
  return null;
});

// Use your custom function
final evaluator = LatexMathEvaluator(extensions: registry);
print(evaluator.evaluate(r'\cbrt{27}'));  // 3.0
```

[Learn more about extensions →](doc/extensions.md)

## Performance Tips

1. **Parse once, evaluate many times** when using the same expression with different variables
2. **Validate expressions** during development to catch errors early
3. **Disable implicit multiplication** if you need to support multi-character variable names
4. **Cache parsed expressions** for repeated evaluations

## Documentation

The guides available in the [doc/](doc/) folder:

- [Getting Started](doc/getting_started.md) - Installation and basic usage
- [Functions](doc/functions/README.md) - Complete function reference
- [Notation](doc/notation/README.md) - Supported LaTeX notation
- [Constants](doc/constants.md) - Built-in mathematical constants
- [Validation](doc/validation.md) - Error handling and validation
- [Extensions](doc/extensions.md) - Creating custom functions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

- **Issues:** [GitHub Issues](https://github.com/xirf/latex_math_evaluator/issues)
- **Discussions:** [GitHub Discussions](https://github.com/xirf/latex_math_evaluator/discussions)
- **Documentation:** [Full Documentation](doc/)
