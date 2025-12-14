# LaTeX Math Evaluator

> A Flutter/Dart library for parsing and evaluating mathematical expressions written in LaTeX format.

[![Tests](https://img.shields.io/badge/tests-393%20passed-brightgreen)](https://github.com/xirf/latex_math_evaluator)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)](https://github.com/xirf/latex_math_evaluator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Pub Version](https://img.shields.io/pub/v/latex_math_evaluator)](https://pub.dev/packages/latex_math_evaluator)

> [!NOTE]
> This library is in early development and may have breaking changes in future releases.
>
> Kindly check our [Roadmap 🚚](ROADMAP.md) for planned features and progress.

## Why This Library Exists

### The Problem with Existing Solutions

If you're familiar with Dart's ecosystem, you might know about the [`math_expressions`](https://pub.dev/packages/math_expressions) package. So why create another math evaluation library?

**LaTeX Math Evaluator** was built to solve problems that `math_expressions` and similar libraries don't address:

#### 1. **Native LaTeX Support**

- **math_expressions:** Uses custom syntax (`sin(x)`, `x^2`, `sqrt(x)`)
- **latex_math_evaluator:** Native LaTeX notation (`\sin{x}`, `x^{2}`, `\sqrt{x}`)

**Why this matters:** Academic papers, textbooks, and educational platforms use LaTeX. Copy-paste expressions directly without translation. This also mean your current educational content and LaTeX-heavy ecosystems integrate seamlessly if you want to extend them with computation.

#### 2. **Symbolic Differentiation**

- **math_expressions:** Numerical differentiation only (approximations)
- **latex_math_evaluator:** Full symbolic differentiation with calculus rules

```dart
// Get exact derivatives, not approximations
final expr = evaluator.parse(r'x^{2} + 3x + 1');
final derivative = evaluator.differentiate(expr, 'x');  // Returns: 2x + 3
print(evaluator.evaluateParsed(derivative, {'x': 2}).asNumeric());  // 7.0
```

Supports power rule, product rule, quotient rule, chain rule, and derivatives of all trig/log/exp functions.

#### 3. **Advanced Mathematical Notation**

- **Summation:** `\sum_{i=1}^{n} i^{2}`
- **Products:** `\prod_{i=1}^{n} i`
- **Limits:** `\lim_{x \to 0} \frac{\sin{x}}{x}`
- **Integration:** `\int_{0}^{\pi} \sin{x}\, dx`
- **Matrices:** `\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}`
- **Higher-order derivatives:** `\frac{d^{2}}{dx^{2}}(x^{3})`

**math_expressions** has limited support for these advanced constructs.

#### 4. **Matrix and Vector Operations**

Full matrix algebra built-in:

```dart
// Determinant, inverse, transpose, multiplication - all native
evaluator.evaluateNumeric(r'\det{\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}}');  // -2.0
```

#### 5. **Complex Number Support**

```dart
// Complex arithmetic with i notation
evaluator.evaluate('(1 + 2*i) * (3 + 4*i)');  // Complex(-5, 10)
evaluator.evaluate(r'\Re(2 + 3i)');  // 2.0
evaluator.evaluate(r'\Im(2 + 3i)');  // 3.0
```

#### 6. **Parse Once, Evaluate Many**

Optimized for performance with LRU caching:

```dart
final equation = evaluator.parse(r'x^{2} + 2x + 1');  // Parse once
// Evaluate thousands of times - blazing fast
for (var x = 0; x < 10000; x++) {
  evaluator.evaluateParsed(equation, {'x': x.toDouble()});
}
```

#### 7. **Validation with Detailed Error Messages**

```dart
final result = evaluator.validate(r'\frac{1{2}');
// Shows exactly where the error is with suggestions
// ParserException at position 10: Expected '}' after numerator
// \frac{1{2}
//           ^
```

### When to Use Each Library

| Use Case                                            | Recommended Library                 |
| --------------------------------------------------- | ----------------------------------- |
| **LaTeX expressions from papers/textbooks**         | ✅ latex_math_evaluator             |
| **Symbolic calculus (derivatives, simplification)** | ✅ latex_math_evaluator             |
| **Matrix/vector operations**                        | ✅ latex_math_evaluator             |
| **Complex numbers**                                 | ✅ latex_math_evaluator             |
| **Simple calculator with custom syntax**            | math_expressions                    |
| **Expression simplification only**                  | math_expressions (has some support) |
| **Lightweight numeric evaluation**                  | math_expressions (smaller package)  |

### Bottom Line

**LaTeX Math Evaluator** is purpose-built for applications that need:

- Academic/scientific accuracy with LaTeX notation
- Symbolic mathematics (calculus, algebra)
- Advanced mathematical constructs
- Educational platforms, homework checkers, graphing calculators
- Integration with LaTeX-heavy ecosystems

If you just need basic arithmetic with a simple syntax, `math_expressions` is perfectly fine. If you're building serious mathematical software or educational tools, **LaTeX Math Evaluator** is the better choice.

---

## Quick Feature Overview

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

```plain
ParserException at position 10: Expected '}' after numerator

\frac{1{2}
          ^
Suggestion: Add a closing brace } or check for matching braces
```

[Learn more about validation ->](doc/validation.md)

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

| Category          | Functions / Examples                                                |
| ----------------- | ------------------------------------------------------------------- |
| Trigonometric     | `\sin`, `\cos`, `\tan`, `\asin`, `\acos`, `\atan`                   |
| Hyperbolic        | `\sinh`, `\cosh`, `\tanh`, `\asinh`, `\acosh`, `\atanh`             |
| Logarithmic       | `\ln`, `\log`, `\log_{b}{x}` (e.g. `\log_{2}{8}`)                   |
| Rounding          | `\ceil`, `\floor`, `\round`                                         |
| Power & Roots     | `\sqrt`, `\sqrt[3]{27}`, `\exp`                                     |
| Matrix Operations | `\det`, `\trace`, `\tr`                                             |
| Combinatorics     | `\binom{n}{k}`                                                      |
| Number Theory     | `\gcd(a, b)`, `\lcm(a, b)`                                          |
| Other             | `\abs`, `\|x\|`, `\sgn`, `\factorial`, `\min_{a}{b}`, `\max_{a}{b}` |

### Mathematical Constants

Constants are available with or without backslash notation:

| Constant | LaTeX    | Symbol | Value      | Usage               |
| -------- | -------- | ------ | ---------- | ------------------- |
| Pi       | `\pi`    | π      | 3.14159... | `\pi` or `pi`       |
| Euler    | `\e`     | e      | 2.71828... | `\e` or `e`         |
| Tau      | `\tau`   | τ      | 6.28318... | `\tau` or `tau`     |
| Phi      | `\phi`   | φ      | 1.61803... | `\phi` or `phi`     |
| Gamma    | `\gamma` | γ      | 0.57721... | `\gamma` or `gamma` |

> **Note:** User-provided variables always override built-in constants.

### Advanced Notation

| Feature                                |              Equation              | LaTeX                                |
| -------------------------------------- | :--------------------------------: | ------------------------------------ |
| Fractions                              |          $\frac{a+b}{c}$           | `\frac{a + b}{c}`                    |
| Summation                              |      $\sum_{i=1}^{10} i^{2}$       | `\sum_{i=1}^{10} i^{2}`              |
| Products                               |        $\prod_{i=1}^{5} i$         | `\prod_{i=1}^{5} i` (Factorial: 120) |
| Limits (numeric approximation)         | $\lim_{x \to 0} \frac{\sin{x}}{x}$ | `\lim_{x \to 0} \frac{\sin{x}}{x}`   |
| Numerical Integration (Simpson's Rule) |   $\int_{0}^{\pi} \sin{x}\, dx$    | `\int_{0}^{\pi} \sin{x}\, dx`        |
| Symbolic Differentiation               |       $\frac{d}{dx}(x^{2})$        | `\frac{d}{dx}(x^{2})`                |
| Higher Order Derivatives               |   $\frac{d^{2}}{dx^{2}}(x^{3})$    | `\frac{d^{2}}{dx^{2}}(x^{3})`        |
| Absolute Value                         |  $\|x\|$, $\|-5\|$, $\|x^2 - 4\|$  | `\|x\|`, `\|-5\|`, `\|x^2 - 4\|`     |
| Domain Constraints                     |     $f(x) = 2x - 3, 3 < x < 5$     | `f(x) = 2x - 3, 3 < x < 5`           |

### Symbolic Differentiation

Compute derivatives symbolically with full support for all standard calculus rules:

```dart
final evaluator = LatexMathEvaluator();

// Basic derivative: d/dx(x^2) = 2x
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{2})', {'x': 3}));  // 6.0

// Product rule: d/dx(x * sin(x))
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(x \cdot \sin{x})', {'x': 0}));  // 1.0

// Chain rule: d/dx(sin(x^2))
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\sin{x^{2}})', {'x': 0}));  // 0.0

// Higher order derivatives: d²/dx²(x^3) = 6x
print(evaluator.evaluateNumeric(r'\frac{d^{2}}{dx^{2}}(x^{3})', {'x': 2}));  // 12.0

// Get symbolic derivative for reuse
final expr = evaluator.parse(r'x^{2} + 3x + 1');
final derivative = evaluator.differentiate(expr, 'x');
print(evaluator.evaluateParsed(derivative, {'x': 2}).asNumeric());  // 7.0
```

Supported rules:

- **Power, sum, difference, product, quotient, chain rules**
- **Trigonometric**: sin, cos, tan, cot, sec, csc
- **Inverse trig**: arcsin, arccos, arctan
- **Exponential & logarithmic**: e^x, a^x, ln(x), log(x)
- **Hyperbolic**: sinh, cosh, tanh
- **Special cases**: √x, |x|, x^x

[See full differentiation documentation →](doc/notation/differentiation.md)

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

[Learn more about extensions ->](doc/extensions.md)

## Performance Tips

1. **Parse once, evaluate many times** when using the same expression with different variables
2. **Validate expressions** during development to catch errors early
3. **Disable implicit multiplication** if you need to support multi-character variable names
4. **Cache parsed expressions** for repeated evaluations

How to enable and use caching:

```dart
// Configure LRU cache size for parsed expressions.
final evaluator = LatexMathEvaluator(parsedExpressionCacheSize: 512);

// Reuse parsed expression manually to avoid re-parsing.
final parsed = evaluator.parse(r'x^{2} + 2x + 1');
print(evaluator.evaluateParsed(parsed, {'x': 1}));

// Clear cache when extensions or runtime tokens change.
evaluator.clearParsedExpressionCache();
```

New functions: `\fibonacci{n}` is available with memoized implementations.
Quick benchmark: Run `dart run benchmark/expression_cache_benchmark.dart` to measure parsed-expression caching benefits and fibonacci memoization.

## Documentation

The guides available in the [doc/](doc/) folder:

- [Getting Started](doc/getting_started.md) - Installation and basic usage
- [Functions](doc/functions/README.md) - Complete function reference
- [Notation](doc/notation/README.md) - Supported LaTeX notation
- [Constants](doc/constants.md) - Built-in mathematical constants
- [Validation](doc/validation.md) - Error handling and validation
- [Extensions](doc/extensions.md) - Creating custom functions
- [Caching](doc/performance/caching.md) - Parsed expression cache and memoization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

- **Issues:** [GitHub Issues](https://github.com/xirf/latex_math_evaluator/issues)
- **Discussions:** [GitHub Discussions](https://github.com/xirf/latex_math_evaluator/discussions)
- **Documentation:** [Full Documentation](doc/)
