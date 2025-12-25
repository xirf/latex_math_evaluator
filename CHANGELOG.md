# CHANGELOG

## 0.1.5-nightly - 2025-12-23

### Added

- **Advanced Multi-Layer Caching System**:
  - `CacheConfig` for fine-grained cache configuration with presets (`disabled`, `highPerformance`, `withStatistics`)
  - `CacheManager` with 4-layer cache architecture:
    - L1: Parsed expression cache (String → AST)
    - L2: Evaluation result cache (AST + Variables → Result)
    - L3: Differentiation result cache (AST + Variable + Order → Derivative)
    - L4: Sub-expression cache (for hierarchical caching)
  - `CacheStatistics` and `MultiLayerCacheStatistics` for cache performance monitoring
  - `LfuCache` (Least Frequently Used) as alternative to LRU for hot-spot access patterns
  - TTL (Time-to-Live) support for automatic cache entry expiration
  - `warmUpCache()` method to preload frequently-used expressions
  - `clearAllCaches()` method to clear all cache layers at once
- **Piecewise Function Differentiation**: Support for differentiating conditional expressions
  - Can now differentiate functions like `|\sin{x}|, -3 < x < 3`
  - Implementation: `d/dx[f(x), condition] = d/dx[f(x)], condition`
  - 25 comprehensive tests in `test/features/piecewise_differentiation_test.dart`
- **Sign Function**: Added `\sign{x}` as alias for `\sgn{x}`
  - Registered in both tokenizer and function registry
  - Automatically used in derivatives of absolute values: `d/dx[|f(x)|] = f'(x) * sign(f(x))`
- **String-Based API**: Both `differentiate()` and `integrate()` now accept LaTeX strings directly
  - New: `evaluator.differentiate('x^2', 'x')`
  - Old API with `Expression` objects still works (backward compatible)
  - Eliminates need for manual parsing in common cases

### Improved

- **LRU Cache**: Enhanced with TTL support, statistics tracking, and `getOrPut()` atomic operation
- **Cache Hit Rates**: Multi-layer caching provides significant speedup for repeated evaluations with same variables
- **Differentiation Performance**: Repeated derivatives are now cached for better performance
- **Developer Experience**: More intuitive API for calculus operations
- **Documentation**: Updated README with new API examples and piecewise function support

### Changed

- **LatexMathEvaluator**: Now accepts `CacheConfig` for advanced cache configuration (backwards compatible)
- **Evaluator**: Updated to support `CacheManager` for sub-expression caching

## 0.1.4 - 2025-12-22

### Added

- **Symbolic Algebra Engine** with algebraic manipulation:
  - Simplification of algebraic expressions
  - Expansion of expressions (distributive property)
  - Factorization of expressions
  - Symbolic algebra support for mathematical operations
- **Reduced Planck Constant Support**: Added `\hbar` to built-in commands and constants.

### Improved

- **Recursion Safety**: Implemented recursion depth limits in evaluation and rule engines to prevent stack overflows on complex nested expressions.
- **Graph UI**:
  - Fixed label overflow in graph legends
  - Improved error handling for invalid graph equations
- **Improve Delimiter Parsing**: Implemented a delimiter stack in the parser to correctly handle nested `\left/\right` delimiters and absolute value pipes `|`.
- **Improve Implicit Multiplication**: The parser now correctly recognizes when implicit multiplication should stop before a closing delimiter.
- **Improve Calculus Evaluation**: Increased numeric tolerance for limit evaluation to handle edge cases in floating-point approximations.

### Changed

- **Visitor Pattern for AST Traversal**: Implemented visitor pattern for AST node processing
- **Feature Module Organization**: Reorganized codebase into feature-based modules
- **Expression Builder Pattern**: Updated tests to use expression builder pattern
- **Command Registry**: Extracted command registry
- **Code Quality**: Applied dart format to ensure consistent code style
- **Documentation**: Neutralized subjective language across documentation
- **Error Handling**: Updated error handling in complex functions
- **Code Cleanup**: Removed unused imports throughout the codebase

## 0.1.3 - 2025-12-18

- Added **Nth Root Support** with square bracket notation:
  - Support for nth roots: `\sqrt[n]{x}` (cube roots, 4th roots, etc.)
  - Examples: `\sqrt[3]{8}` = 2, `\sqrt[4]{16}` = 2, `\sqrt[5]{32}` = 2
  - Odd roots support negative numbers: `\sqrt[3]{-8}` = -2
  - Even roots properly throw errors for negative arguments
  - Dynamic roots with variables: `\sqrt[n]{x}`
  - Backwards compatible: `\sqrt{16}` continues to work as square root
  - 24 comprehensive tests covering various nth root scenarios
  - Updated documentation in `doc/functions/misc.md`
- Added **Academic LaTeX Support** for copy-paste from papers and notes:
  - Support for delimiter sizing commands: `\left`, `\right`, `\big`, `\Big`, `\bigg`, `\Bigg`
  - These commands are silently ignored (they're purely visual in LaTeX)
  - Support for escaped braces: `\{` and `\}` treated as regular grouping
  - Enables direct copy-paste from academic sources without manual cleanup
  - Documentation in `doc/academic_latex.md`

## 0.1.2 - 2025-12-15

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
