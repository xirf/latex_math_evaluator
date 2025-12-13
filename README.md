# LaTeX Math Evaluator

A Flutter/Dart library for parsing and evaluating mathematical expressions written in LaTeX format.

[![Tests](https://img.shields.io/badge/tests-294%20passed-brightgreen)](https://github.com/xirf/latex_math_evaluator)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)](https://github.com/xirf/latex_math_evaluator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Pub Version](https://img.shields.io/pub/v/latex_math_evaluator)](https://pub.dev/packages/latex_math_evaluator)

## Features

- **Parse LaTeX math expressions** into an Abstract Syntax Tree
- **Evaluate expressions** with variable bindings
- **Validation API**: Check syntax before evaluation with detailed error messages
- **Enhanced error messages**: Position markers, expression snippets, and helpful suggestions
- **30+ built-in functions**: trigonometry, logarithms, rounding, and more
- **Mathematical constants**: π, e, φ, γ, τ, and others
- **Summation & Product notation**: `\sum_{i=1}^{n}`, `\prod_{i=1}^{n}`
- **Limit notation**: `\lim_{x \to a}`
- **Numerical Integration**: `\int_{a}^{b} f(x) dx` (Simpson's Rule)
- **Matrix support**: `\begin{matrix} ... \end{matrix}` with operations (+, -, \*, ^T, ^-1) and `\det`
- **Extensible**: Add custom functions and commands

## Table of Contents

- [Features](#features)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Variable Binding](#variable-binding)
- [Validation](#validation)
- [Supported Functions](#supported-functions)
- [Built-in Constants](#built-in-constants)
- [Implicit Multiplication](#implicit-multiplication)
- [Notation Support](#notation-support)
- [Custom Extensions](#custom-extensions)
- [Documentation](#documentation)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  latex_math_evaluator: 0.0.2

# or for the latest version

dependencies:
  latex_math_evaluator:
    git:
      url: https://github.com/xirf/latex_math_evaluator.git
```

## Quick Start

```dart
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

final evaluator = LatexMathEvaluator();

// Basic arithmetic
evaluator.evaluateNumeric(r'2 + 3 \times 4');  // 14.0

// Variables
evaluator.evaluateNumeric(r'x^{2} + 1', {'x': 3});  // 10.0

// Functions
evaluator.evaluateNumeric(r'\sin{0}');            // 0.0
evaluator.evaluateNumeric(r'\sqrt{16}');          // 4.0
evaluator.evaluateNumeric(r'\log_{2}{8}');        // 3.0

// Matrices
final matrix = evaluator.evaluateMatrix(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
print(matrix); // [[1.0, 2.0], [3.0, 4.0]]

evaluator.evaluateNumeric(r'|-5|');               // 5.0 (absolute value)
evaluator.evaluateNumeric(r'\frac{1}{2}');        // 0.5 (fraction)

// Constants (used when variable not provided)
evaluator.evaluateNumeric('e');                    // 2.71828...
evaluator.evaluateNumeric(r'\pi');                 // 3.14159...

// Summation
evaluator.evaluateNumeric(r'\sum_{i=1}^{5} i');   // 15.0 (1+2+3+4+5)

// Factorial
evaluator.evaluateNumeric(r'\prod_{i=1}^{5} i');  // 120.0 (5!)
```

### Type-Safe Results

When you need to handle different result types dynamically:

```dart
final result = evaluator.evaluate('2 + 3');

// Pattern matching
switch (result) {
  case NumericResult(:final value):
    print('Numeric: $value');
  case MatrixResult(:final matrix):
    print('Matrix: $matrix');
}

// Or use type checking
if (result.isNumeric) {
  print(result.asNumeric());
}
```

## Variable Binding

Parse once and reuse with different variable values:

```dart
final evaluator = LatexMathEvaluator();

// Parse the expression once
final equation = evaluator.parse(r'x^{2} + 2x + 1');

// Reuse the parsed equation with different values
final result1 = evaluator.evaluateParsed(equation, {'x': 1});  // 4.0
final result2 = evaluator.evaluateParsed(equation, {'x': 2});  // 9.0
final result3 = evaluator.evaluateParsed(equation, {'x': 3});  // 16.0

// Works with multi-variable expressions
final multiVar = evaluator.parse('2x + 3y - z');
evaluator.evaluateParsed(multiVar, {'x': 1, 'y': 2, 'z': 3});   // 5.0
evaluator.evaluateParsed(multiVar, {'x': 5, 'y': 10, 'z': 15}); // 25.0
```

## Validation

Validate expressions before evaluation with detailed error messages:

```dart
final evaluator = LatexMathEvaluator();

// Quick validation
if (evaluator.isValid(r'\sin{x}')) {
  print('Valid syntax!');
}

// Detailed validation with error info
final result = evaluator.validate(r'\sin{');
if (!result.isValid) {
  print('Error: ${result.errorMessage}');     // "Expected expression, got: "
  print('Position: ${result.position}');      // Character position
  print('Suggestion: ${result.suggestion}');  // "Check syntax near this position"
}
```

**Enhanced Error Messages** help you debug expressions quickly:

- **Position markers** show exactly where the error occurred
- **Expression snippets** provide context around the error
- **Helpful suggestions** offer actionable fixes

Example error output:

```plain
ParserException at position 10: Expected '}' after numerator

\frac{1{2}
          ^
Suggestion: Add a closing brace } or check for matching braces
```

[Learn more about validation →](doc/validation.md)

## Supported Functions

| Category          | Functions                                                           |
| ----------------- | ------------------------------------------------------------------- |
| **Trigonometric** | `\sin`, `\cos`, `\tan`, `\asin`, `\acos`, `\atan`                   |
| **Hyperbolic**    | `\sinh`, `\cosh`, `\tanh`, `\asinh`, `\acosh`, `\atanh`             |
| **Logarithmic**   | `\ln`, `\log`, `\log_{base}`                                        |
| **Rounding**      | `\ceil`, `\floor`, `\round`                                         |
| **Power/Root**    | `\sqrt`, `\exp`                                                     |
| **Matrix**        | `\det`, `\trace`, `\tr`                                             |
| **Combinatorics** | `\binom{n}{k}`                                                      |
| **Number Theory** | `\gcd(a,b)`, `\lcm(a,b)`                                            |
| **Other**         | `\abs`, `\|x\|`, `\sgn`, `\factorial`, `\min_{a}{b}`, `\max_{a}{b}` |

Also support equation with domain constraints: `f(x) = 2x - 3, 3 < x < 5`

## Built-in Constants

LaTeX constants can be used with backslash notation:

| Name    | LaTeX    | Symbol | Value      |
| ------- | -------- | ------ | ---------- |
| `e`     | `\e`     | e      | 2.71828... |
| `pi`    | `\pi`    | π      | 3.14159... |
| `tau`   | `\tau`   | τ      | 6.28318... |
| `phi`   | `\phi`   | φ      | 1.61803... |
| `gamma` | `\gamma` | γ      | 0.57721... |
| `Omega` | `\Omega` | Ω      | 0.56714... |
| `delta` | `\delta` | δ      | 2.41421... |

> [!NOTE]
> User-provided variables override built-in constants.

## Implicit Multiplication

By default, implicit multiplication is enabled. This means `2x` is treated as `2 * x` and `xy` is treated as `x * y`.

You can disable this behavior to treat multi-letter sequences as single variables:

```dart
// Default: implicit multiplication enabled
final evaluator = LatexMathEvaluator();
evaluator.evaluate('xy', {'x': 2, 'y': 3}); // 6.0

// Disabled: implicit multiplication disabled
final evaluator2 = LatexMathEvaluator(allowImplicitMultiplication: false);
evaluator2.evaluate('xy', {'xy': 10}); // 10.0
```

## Notation Support

```latex
% Fractions
\frac{numerator}{denominator}
\frac{a + b}{c}

% Summation
\sum_{i=1}^{10} i^{2}

% Product
\prod_{i=1}^{5} i

% Limits (numeric approximation)
\lim_{x \to 0} \sin{x}

% Absolute value
|x|
|x^2 - 4|

% Constants
\pi, \tau, \phi, \gamma
```

## Custom Extensions

```dart
import 'dart:math' as math;

final registry = ExtensionRegistry();

// Register custom command
registry.registerCommand('cbrt', (cmd, pos) =>
  Token(type: TokenType.function, value: 'cbrt', position: pos));

// Register custom evaluator
registry.registerEvaluator((expr, vars, evaluate) {
  if (expr is FunctionCall && expr.name == 'cbrt') {
    return math.pow(evaluate(expr.argument), 1/3).toDouble();
  }
  return null;
});

final evaluator = LatexMathEvaluator(extensions: registry);
evaluator.evaluate(r'\cbrt{27}');  // 3.0
```

## Documentation

See the [doc/](doc/) folder for detailed documentation:

- [Getting Started](doc/getting_started.md)
- [Functions](doc/functions/README.md)
- [Notation](doc/notation/README.md)
- [Constants](doc/constants.md)
- [Extensions](doc/extensions.md)

## License

MIT License - see [LICENSE](LICENSE) file.
