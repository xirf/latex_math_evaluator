## 0.1.2 — 2025-12-15

### Added

- Added **Symbolic Differentiation** with full calculus support:
  - Parse derivatives using standard LaTeX notation: `\frac{d}{dx}(expression)`
  - Higher order derivatives: `\frac{d^{2}}{dx^{2}}(expression)`, `\frac{d^{n}}{dx^{n}}(expression)`
  - Implemented all standard differentiation rules:
    - Power rule, sum rule, difference rule, product rule, quotient rule
    - Chain rule with full composite function support
    - Trigonometric functions (sin, cos, tan, cot, sec, csc)
    - Inverse trigonometric functions (arcsin, arccos, arctan)
    - Hyperbolic functions (sinh, cosh, tanh)
    - Exponential and logarithmic functions (e^x, a^x, ln, log)
    - Special cases (√x, |x|, x^x)
  - Basic algebraic simplification of derivative results
  - `differentiate(expression, variable, {order})` API method for symbolic derivatives
  - 45+ comprehensive tests covering all differentiation rules
  - Full documentation in `doc/notation/differentiation.md`
  - Example file: `example/features/differentiation_demo.dart`
- Added support for variable binding
- Added **Convenience Methods** for simplified developer experience:
  - `evaluateNumeric(expression, variables)` - Direct numeric evaluation without type conversion
  - `evaluateMatrix(expression, variables)` - Direct matrix evaluation without type conversion
  - These methods provide a cleaner API when you know the expected result type
- Added **Validation API**: `isValid()` and `validate()` methods for syntax validation
  - `isValid(expression)` - Quick boolean check for valid syntax
  - `validate(expression)` - Detailed validation with error messages, positions, and suggestions
  - `ValidationResult` class with helpful error information and fix suggestions
- Added **Type-Safe Result API**: `EvaluationResult` sealed class for better type safety
  - `NumericResult` for numeric results with `.asNumeric()` accessor
  - `MatrixResult` for matrix results with `.asMatrix()` accessor
  - Pattern matching support for result types
  - Helper methods: `.isNumeric`, `.isMatrix`
  - Migrated `evaluate()` and `evaluateParsed()` to return `EvaluationResult` instead of `dynamic`
- Added support for complex numbers `\text{Re}`, `\text{Im}`, `\overline{z}` (conjugate)
- Added `evaluator.evaluateNumeric()` and `evaluator.evaluateMatrix()` methods for direct evaluation to specific types
- Added parsed-expression LRU caching via `LatexMathEvaluator(parsedExpressionCacheSize: ...)` (enabled by default)
- Added `\fibonacci{n}` function (0-indexed: 0, 1, 1, 2, ...)
- Added micro-benchmark demonstrating parsed-expression caching and fibonacci memoization (`benchmark/expression_cache_benchmark.dart`)

### Improved

- **Enhanced Error Messages** with better debugging information:
  - Added `suggestion` field to all exceptions with context-specific fix recommendations
  - Added expression snippets showing exactly where errors occurred
  - Added visual position markers (^) pointing to the error location
  - All exceptions now include the original expression for better context
  - Improved error messages in tokenizer, parser, and evaluator with actionable suggestions
  - Examples: "Add a closing brace }", "Provide a value for 'x' in the variables map", etc.

---

Full changelog: https://github.com/xirf/latex_math_evaluator/blob/main/CHANGELOG.md
