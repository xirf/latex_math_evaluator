# LaTeX Math Evaluator

A Flutter/Dart library for parsing and evaluating mathematical expressions written in LaTeX format.

[![Tests](https://img.shields.io/badge/tests-173%20passed-brightgreen)]()
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)]()

## Features

- **Parse LaTeX math expressions** into an Abstract Syntax Tree
- **Evaluate expressions** with variable bindings
- **30+ built-in functions**: trigonometry, logarithms, rounding, and more
- **Mathematical constants**: π, e, φ, γ, τ, and others
- **Summation & Product notation**: `\sum_{i=1}^{n}`, `\prod_{i=1}^{n}`
- **Limit notation**: `\lim_{x \to a}`
- **Numerical Integration**: `\int_{a}^{b} f(x) dx` (Simpson's Rule)
- **Matrix support**: `\begin{matrix} ... \end{matrix}` with operations (+, -, *, ^T, ^-1) and `\det`
- **Extensible**: Add custom functions and commands

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
evaluator.evaluate(r'2 + 3 \times 4');  // 14.0

// Variables
evaluator.evaluate(r'x^{2} + 1', {'x': 3});  // 10.0

// Functions
evaluator.evaluate(r'\sin{0}');            // 0.0
evaluator.evaluate(r'\sqrt{16}');          // 4.0
evaluator.evaluate(r'\log_{2}{8}');        // 3.0

// Matrices
final matrix = evaluator.evaluate(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
// Returns a Matrix object

evaluator.evaluate(r'|-5|');               // 5.0 (absolute value)
evaluator.evaluate(r'\frac{1}{2}');        // 0.5 (fraction)

// Constants (used when variable not provided)
evaluator.evaluate('e');                    // 2.71828...
evaluator.evaluate(r'\pi');                 // 3.14159...

// Summation
evaluator.evaluate(r'\sum_{i=1}^{5} i');   // 15.0 (1+2+3+4+5)

// Factorial
evaluator.evaluate(r'\prod_{i=1}^{5} i');  // 120.0 (5!)
```

## Supported Functions

| Category          | Functions                                                  |
| ----------------- | ---------------------------------------------------------- |
| **Trigonometric** | `\sin`, `\cos`, `\tan`, `\asin`, `\acos`, `\atan`          |
| **Hyperbolic**    | `\sinh`, `\cosh`, `\tanh`                                  |
| **Logarithmic**   | `\ln`, `\log`, `\log_{base}`                               |
| **Rounding**      | `\ceil`, `\floor`, `\round`                                |
| **Power/Root**    | `\sqrt`, `\exp`                                            |
| **Other**         | `\abs`, `|x|`, `\sgn`, `\factorial`, `\min_{a}{b}`, `\max_{a}{b}` |

Also support equation with domain constraints: `f(x) = 2x - 3, 3 < x < 5`

## Built-in Constants

LaTeX constants can be used with backslash notation:

| Name      | LaTeX    | Symbol | Value      |
| --------- | -------- | ------ | ---------- |
| `e`       | `\e`     | e      | 2.71828... |
| `pi`      | `\pi`    | π      | 3.14159... |
| `tau`     | `\tau`   | τ      | 6.28318... |
| `phi`     | `\phi`   | φ      | 1.61803... |
| `gamma`   | `\gamma` | γ      | 0.57721... |
| `Omega`   | `\Omega` | Ω      | 0.56714... |
| `delta`   | `\delta` | δ      | 2.41421... |

> User-provided variables override built-in constants.

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
