# LaTeX Math Evaluator 🧮

[![Tests](https://img.shields.io/badge/tests-781%20passed-brightgreen)](https://github.com/xirf/latex_math_evaluator)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)](https://github.com/xirf/latex_math_evaluator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Pub Version](https://img.shields.io/pub/v/latex_math_evaluator)](https://pub.dev/packages/latex_math_evaluator)

A Flutter/Dart library designed for parsing and evaluating complex mathematical expressions in native LaTeX format. Built for researchers, engineers, and educators who need symbolic accuracy and broad notation support.

> [!NOTE]
> This library is under active development. Check our [Roadmap 🚚](ROADMAP.md) for upcoming features.

## ✨ Key Capabilities

- 🎯 **Native LaTeX Parsing** – Evaluate expressions directly from academic papers without manual translation.
- 🧮 **Symbolic Calculus** – Compute exact derivatives and simplify expressions using algebraic rules.
- 🔢 **Advanced Mathematics** – Support for summations, products, limits, integrals, and special functions.
- 🏗️ **Linear Algebra** – Full suite of matrix and vector operations, including determinants and powers.
- 🛡️ **Type-Safe Results** – Robust handling of Real, Complex, Matrix, and Vector types via Dart 3 sealed classes.
- 🚩 **Domain Awareness** – Uses an Assumptions System (e.g., $x > 0$) to ensure mathematically sound transformations.
- 🔧 **Extensible Architecture** – Easily add custom LaTeX commands and evaluation logic.
- 🧩 **Implicit/Explicit Logic** – Natural parsing of $2\pi r$ or $\sin 2x$—no need to type every \*. easy to switch between implicit and explicit logic.

---

## 🚀 Quick Start

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  latex_math_evaluator: ^0.1.3
```

### Basic Evaluation

```dart
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

final evaluator = LatexMathEvaluator();

// 1. Simple numeric result
final result = evaluator.evaluateNumeric(r'\frac{\sqrt{16}}{2} + \sin{\pi}');
print(result); // 2.0

// 2. Evaluation with variables
final vars = {'x': 3.0, 'y': 4.0};
final hypotenuse = evaluator.evaluateNumeric(r'\sqrt{x^2 + y^2}', vars);
print(hypotenuse); // 5.0
```

---

## 🛠️ Core Features

### 1. Symbolic Calculus & Differentiation 📐

Unlike libraries that use numeric approximations, `latex_math_evaluator` can compute exact symbolic derivatives.

```dart
// Differentiate an expression
final derivative = evaluator.differentiate(r'x^3 + \sin{x}', 'x');

// Evaluate at x = 0
print(evaluator.evaluateParsed(derivative, {'x': 0})); // 1.0 (cos(0))

// Works with piecewise functions too!
final piecewise = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');
print(evaluator.evaluateParsed(piecewise, {'x': 1})); // cos(1)
```

### 2. Complex & Multi-Dimensional Math 🏗️

Handle matrices, vectors, and complex numbers as first-class citizens.

```dart
// Matrix multiplication and power
final matrixResult = evaluator.evaluate(r'''
  \begin{pmatrix} 0.8 & 0.1 \\ 0.2 & 0.7 \end{pmatrix} ^ 2
''');

// Complex numbers (i or j notation)
final complexResult = evaluator.evaluate(r'(1 + 2i) \cdot (3 - 4i)');
```

### 3. High-Fidelity Diagnostics 🔍

Get precise feedback when parsing fails, including the exact position and helpful suggestions.

```dart
final validation = evaluator.validate(r'\frac{1{2}');
if (!validation.isValid) {
  print('Error at ${validation.position}: ${validation.errorMessage}');
  // Output: Error at 10: Expected '}' after numerator
}
```

### 4. Performance & Caching ⚡

For applications requiring frequent evaluations (like graphing or simulations), use the built-in LRU cache.

```dart
// Configure a 512-entry cache for parsed ASTs with LFU eviction policy
final fastEvaluator = LatexMathEvaluator(
  cacheConfig: CacheConfig(
    parsedExpressionCacheSize: 512,
    evictionPolicy: EvictionPolicy.lfu,
  ),
);

// Subsequent calls with the same string are near-instant
fastEvaluator.evaluate(r'\sum_{i=1}^{100} i');
```

---

## 📚 Real-World Examples

| Domain          | LaTeX Expression                                                        | Capability                        |
| :-------------- | :---------------------------------------------------------------------- | :-------------------------------- |
| **Physics**     | `\frac{1}{\sqrt{1 - \frac{v^2}{c^2}}}`                                  | Lorentz Factor (Variable Binding) |
| **Engineering** | `\frac{P L^3}{48 E I} ( 3 \frac{x}{L} - 4 ( \frac{x}{L} )^3 )`          | Beam Deflection (Algebraic)       |
| **Quantum**     | `\int_{0}^{L} \psi^*(x) \hat{H} \psi(x) dx`                             | Expectation Values (Integration)  |
| **Statistics**  | `\frac{1}{\sigma \sqrt{2\pi}} e^{-\frac{1}{2}(\frac{x-\mu}{\sigma})^2}` | Normal Distribution (Constants)   |

---

## 📖 Documentation & Resources

- [**Getting Started**](doc/getting_started.md)
- [**Symbolic Algebra**](doc/symbolic_algebra.md) – Simplification and expansion rules.
- [**Function Reference**](doc/functions/README.md) – List of all supported LaTeX commands.
- [**Extending the Library**](doc/extensions.md) – How to add custom functions.
- [**Performance Guide**](doc/performance/caching.md) – Tuning the cache and memoization.

## 🤝 Contributing

We welcome contributions of all kinds! Whether it's reporting a bug, improving documentation, or adding a new mathematical feature.

1. Fork the repository.
2. Create your feature branch.
3. Commit your changes.
4. Push to the branch and open a Pull Request.

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
