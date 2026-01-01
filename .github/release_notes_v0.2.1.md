
### Added

- **JSON AST Export**
  New `toJson()` method on all Expression types for debugging and tooling:

  ```dart
  final expr = evaluator.parse(r'\frac{x^2 + 1}{2}');
  final json = expr.toJson();
  print(jsonEncode(json));
  ```

  - `JsonAstVisitor` class for custom JSON conversion
  - Full support for all 18 AST node types
  - JSON output is fully serializable with `dart:convert`
  - 32 new tests for JSON export

- **MathML Export**
  New `toMathML()` method for displaying math in web browsers:

  ```dart
  final expr = evaluator.parse(r'\sin{x}');
  final mathml = expr.toMathML();
  // <math xmlns="..."><mrow><mi>sin</mi>...</mrow></math>
  ```

  - MathML presentation markup support
  - Unicode symbols for operators (∫, ∑, π, etc.)
  - 27 new tests for MathML export

* **SymPy Export**
  New `toSymPy()` method for Python interoperability:

  ```dart
  final expr = evaluator.parse(r'\int x^2 dx');
  print(expr.toSymPy());
  // integrate(x**2, x)

  print(expr.toSymPyScript());
  // from sympy import *
  // x = symbols('x')
  // expr = integrate(x**2, x)
  ```

  - SymPy function mapping (sin, cos, integrate, diff, etc.)
  - `toSymPyScript()` generates runnable Python code
  - Automatic variable collection
  - 39 new tests for SymPy export

### Metrics

- **Total Test Count**: 1823 tests (up from 1725)

---

