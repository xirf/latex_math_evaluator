# LaTeX Math Evaluator

A Flutter/Dart library for parsing and evaluating mathematical expressions written in LaTeX format.

[![Tests](https://img.shields.io/badge/tests-122%20passed-brightgreen)]()
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)]()

## Features

- **Parse LaTeX math expressions** into an Abstract Syntax Tree
- **Evaluate expressions** with variable bindings
- **30+ built-in functions**: trigonometry, logarithms, rounding, and more
- **Mathematical constants**: π, e, φ, γ, τ, and others
- **Summation & Product notation**: `\sum_{i=1}^{n}`, `\prod_{i=1}^{n}`
- **Limit notation**: `\lim_{x \to a}`
- **Extensible**: Add custom functions and commands

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  latex_math_evaluator:
    path: ../latex_math_evaluator  # or publish to pub.dev
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

// Constants (used when variable not provided)
evaluator.evaluate('e');                    // 2.71828...

// Summation
evaluator.evaluate(r'\sum_{i=1}^{5} i');   // 15.0 (1+2+3+4+5)

// Factorial
evaluator.evaluate(r'\prod_{i=1}^{5} i');  // 120.0 (5!)
```

## Supported Functions

| Category | Functions |
|----------|-----------|
| **Trigonometric** | `\sin`, `\cos`, `\tan`, `\asin`, `\acos`, `\atan` |
| **Hyperbolic** | `\sinh`, `\cosh`, `\tanh` |
| **Logarithmic** | `\ln`, `\log`, `\log_{base}` |
| **Rounding** | `\ceil`, `\floor`, `\round` |
| **Power/Root** | `\sqrt`, `\exp` |
| **Other** | `\abs`, `\sgn`, `\factorial`, `\min_{a}{b}`, `\max_{a}{b}` |

## Built-in Constants

| Name | Symbol | Value |
|------|--------|-------|
| `e` | e | 2.71828... |
| `pi` | π | 3.14159... |
| `tau` | τ | 6.28318... |
| `phi` | φ | 1.61803... |
| `gamma` | γ | 0.57721... |

> User-provided variables override built-in constants.

## Notation Support

```latex
% Summation
\sum_{i=1}^{10} i^{2}

% Product
\prod_{i=1}^{5} i

% Limits (numeric approximation)
\lim_{x \to 0} \sin{x}
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

See the [docs/](docs/) folder for detailed documentation:

- [Getting Started](docs/getting_started.md)
- [Functions](docs/functions/README.md)
- [Notation](docs/notation/README.md)
- [Constants](docs/constants.md)
- [Extensions](docs/extensions.md)

## License

MIT License - see [LICENSE](LICENSE) file.
