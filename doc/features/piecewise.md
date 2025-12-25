# Piecewise Functions

Piecewise functions allow you to define expressions that are only valid within specific domains or conditions. This is essential for modeling real-world scenarios where different rules apply in different ranges.

## Overview

The library supports piecewise functions through **conditional expressions** using the `ConditionalExpr` class. These expressions consist of two parts:

- **Expression**: The mathematical expression to evaluate
- **Condition**: The domain constraint that must be satisfied

## Syntax

Piecewise functions use the comma operator followed by a condition:

```latex
expression, condition
```

### Supported Conditions

The library supports these comparison operators for defining domains:

| Syntax        | Meaning          | Example                  |
| ------------- | ---------------- | ------------------------ |
| `a < x < b`   | Open interval    | `x^2, -5 < x < 5`        |
| `a <= x <= b` | Closed interval  | `\sin(x), 0 <= x <= \pi` |
| `x > a`       | Greater than     | `\ln(x), x > 0`          |
| `x >= a`      | Greater or equal | `\sqrt{x}, x >= 0`       |
| `x < a`       | Less than        | `e^x, x < 0`             |
| `x <= a`      | Less or equal    | `x^2, x <= 10`           |

You can also chain comparisons:

- `0 < x < 5` (x is between 0 and 5, exclusive)
- `-3 <= x <= 3` (x is between -3 and 3, inclusive)

## Basic Usage

### Evaluation

```dart
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

final evaluator = LatexMathEvaluator();

// Define a piecewise function: x^2 for -5 < x < 5
final result1 = evaluator.evaluateNumeric(r'x^{2}, -5 < x < 5', {'x': 3.0});
print(result1); // 9.0 (3^2, within domain)

final result2 = evaluator.evaluateNumeric(r'x^{2}, -5 < x < 5', {'x': 10.0});
print(result2.isNaN); // true (outside domain)
```

### Outside Domain Behavior

When you evaluate a piecewise function outside its domain, the result is `NaN` (Not a Number):

```dart
// x must be between -3 and 3 (exclusive)
final result = evaluator.evaluateNumeric(r'\sin(x), -3 < x < 3', {'x': 5.0});
print(result.isNaN); // true
```

### Boundary Behavior

Boundaries are handled based on the comparison operator:

- **Exclusive** (`<`, `>`): Boundaries return `NaN`
- **Inclusive** (`<=`, `>=`): Boundaries return valid results

```dart
// Open interval: -5 < x < 5
final result1 = evaluator.evaluateNumeric(r'x^{2}, -5 < x < 5', {'x': -5.0});
print(result1.isNaN); // true (boundary excluded)

// Closed interval: -5 <= x <= 5
final result2 = evaluator.evaluateNumeric(r'x^{2}, -5 <= x <= 5', {'x': -5.0});
print(result2); // 25.0 (boundary included)
```

## Differentiation

One of the most powerful features is **automatic differentiation of piecewise functions**. The derivative maintains the same domain constraint.

### Basic Differentiation

```dart
// Differentiate x^2 with domain constraint
final derivative = evaluator.differentiate(r'x^{2}, -5 < x < 5', 'x');

// Evaluate the derivative at x=3: d/dx(x^2) = 2x = 6
final result = evaluator.evaluateParsed(derivative, {'x': 3.0});
print(result.asNumeric()); // 6.0

// Outside domain: NaN
final resultOut = evaluator.evaluateParsed(derivative, {'x': 10.0});
print(resultOut.asNumeric().isNaN); // true
```

### Differentiating Absolute Values

The library automatically handles absolute value differentiation using the sign function:

```dart
// d/dx(|sin(x)|) = cos(x) * sign(sin(x))
final derivative = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');

// At x = 1: sin(1) > 0, so sign = 1, derivative = cos(1)
final result1 = evaluator.evaluateParsed(derivative, {'x': 1.0});
print(result1.asNumeric()); // ≈ 0.5403 (cos(1))

// At x = 4: Outside domain
final result2 = evaluator.evaluateParsed(derivative, {'x': 4.0});
print(result2.asNumeric().isNaN); // true
```

### Higher-Order Derivatives

You can compute higher-order derivatives by specifying the `order` parameter:

```dart
// Second derivative of x^3
final secondDerivative = evaluator.differentiate(
  r'x^{3}, -5 < x < 5',
  'x',
  order: 2,
);

// d²/dx²(x^3) = 6x
final result = evaluator.evaluateParsed(secondDerivative, {'x': 2.0});
print(result.asNumeric()); // 12.0 (6 * 2)
```

## Common Use Cases

### 1. Domain-Restricted Functions

Mathematical functions often have natural domain restrictions:

```dart
// Natural logarithm: only defined for positive values
final ln = evaluator.evaluate(r'\ln(x), x > 0', {'x': 2.0});

// Square root: only defined for non-negative values
final sqrt = evaluator.evaluate(r'\sqrt{x}, x >= 0', {'x': 4.0});
```

### 2. Modeling Physical Constraints

```dart
// Velocity with maximum speed limit
final velocity = evaluator.evaluateNumeric(
  r'v \cdot t, 0 <= t <= 10',
  {'v': 5.0, 't': 3.0},
);
print(velocity); // 15.0

// Outside time range
final invalid = evaluator.evaluateNumeric(
  r'v \cdot t, 0 <= t <= 10',
  {'v': 5.0, 't': 15.0},
);
print(invalid.isNaN); // true
```

### 3. Analyzing Function Behavior in Intervals

```dart
// Study behavior of x^3 + 2x in specific interval
final expr = r'x^{3} + 2x, -10 < x < 10';
final derivative = evaluator.differentiate(expr, 'x');

// d/dx(x^3 + 2x) = 3x^2 + 2
final result = evaluator.evaluateParsed(derivative, {'x': 2.0});
print(result.asNumeric()); // 14.0
```

## Working with the AST

When you parse a piecewise expression, it creates a `ConditionalExpr` node in the Abstract Syntax Tree:

```dart
final expr = evaluator.parse(r'x^{2}, -5 < x < 5');
print(expr is ConditionalExpr); // true

// Convert back to LaTeX
print(expr.toLatex()); // "x^{2} \\text{ where } -5 < x < 5"
```

## Limitations

### 1. No `\begin{cases}` Syntax Yet

The traditional LaTeX piecewise notation is **not yet supported**:

```latex
❌ Not supported yet:
f(x) = \begin{cases}
  x^2 & x < 0 \\
  2x & x >= 0
\end{cases}
```

Use the comma syntax instead:

```latex
✅ Supported:
x^{2}, x < 0
2x, x >= 0
```

### 2. Single Condition Per Expression

Each expression can only have one condition. For true piecewise functions with multiple branches, you need separate expressions.

### 3. No Integration Support Yet

While differentiation is fully supported, **integration of piecewise functions is not yet implemented**:

```dart
// ❌ Not supported yet
final integral = evaluator.integrate(r'x^{2}, -5 < x < 5', 'x');
```

### 4. Condition Must Use Same Variable

The condition must reference the same variable being differentiated or evaluated:

```dart
// ✅ Valid: condition uses 'x'
evaluator.differentiate(r'x^{2}, -5 < x < 5', 'x');

// ❌ Invalid: condition uses 'y' but differentiating with respect to 'x'
// evaluator.differentiate(r'x^{2}, -5 < y < 5', 'x');
```

## Sign Function

The library provides the `\sign{}` (or `\sgn{}`) function for working with absolute values and piecewise logic:

```dart
// Sign function
final pos = evaluator.evaluateNumeric(r'\sign{5}');   // 1.0
final neg = evaluator.evaluateNumeric(r'\sign{-5}');  // -1.0
final zero = evaluator.evaluateNumeric(r'\sign{0}');  // 0.0

// Used in absolute value derivatives
final deriv = evaluator.differentiate(r'|x|', 'x');
// Returns: sign(x) * 1 = sign(x)
```

## Examples

### Example 1: Piecewise Derivative

```dart
final evaluator = LatexMathEvaluator();

// Define and differentiate
final derivative = evaluator.differentiate(r'x^{3} + 2x, -10 < x < 10', 'x');

// Test at different points
print(evaluator.evaluateParsed(derivative, {'x': 2.0}).asNumeric());
// Output: 14.0 (3*4 + 2)

print(evaluator.evaluateParsed(derivative, {'x': 15.0}).asNumeric().isNaN);
// Output: true (outside domain)
```

### Example 2: Absolute Value with Domain

```dart
final evaluator = LatexMathEvaluator();

// Differentiate |sin(x)| in the domain -3 < x < 3
final derivative = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');

// At x = 1 (where sin(1) > 0)
final result = evaluator.evaluateParsed(derivative, {'x': 1.0});
print(result.asNumeric()); // cos(1) ≈ 0.5403
```

### Example 3: Higher-Order Derivatives

```dart
final evaluator = LatexMathEvaluator();

// Second derivative
final d2 = evaluator.differentiate(r'x^{4}, -5 < x < 5', 'x', order: 2);

// d²/dx²(x^4) = 12x^2
print(evaluator.evaluateParsed(d2, {'x': 2.0}).asNumeric());
// Output: 48.0
```

## See Also

- [Differentiation](calculus/differentiation.md) - General differentiation features
- [Function Reference](functions/README.md) - All supported mathematical functions
- [LaTeX Commands](latex_commands.md) - Complete list of supported LaTeX notation
