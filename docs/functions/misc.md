# Miscellaneous Functions

## `\sqrt{x}` - Square Root

Returns the square root of x.

**Domain**: x ≥ 0

```latex
\sqrt{4}         → 2
\sqrt{2}         → 1.41421...
\sqrt{0}         → 0
```

## `\exp{x}` - Exponential

Returns e^x (e raised to the power x).

```latex
\exp{0}          → 1
\exp{1}          → 2.71828... (e)
\exp{2}          → 7.38905...
```

## `\abs{x}` - Absolute Value

Returns the absolute value of x.

```latex
\abs{5}          → 5
\abs{-5}         → 5
\abs{0}          → 0
```

## `\sgn{x}` - Sign Function

Returns the sign of x: -1, 0, or 1.

```latex
\sgn{5}          → 1
\sgn{-3}         → -1
\sgn{0}          → 0
```

## `\factorial{n}` - Factorial

Returns n! (n factorial). Limited to n ≤ 170 to prevent overflow.

**Domain**: n ≥ 0, integer

```latex
\factorial{0}    → 1
\factorial{5}    → 120  (5! = 5×4×3×2×1)
\factorial{10}   → 3628800
```

## `\min_{a}{b}` / `\max_{a}{b}` - Min/Max

Returns the minimum or maximum of two values.

```latex
\min_{3}{5}      → 3
\max_{3}{5}      → 5
\min_{-2}{-5}    → -5
```

## Examples

```dart
final e = LatexMathEvaluator();

e.evaluate(r'\sqrt{16}');        // 4.0
e.evaluate(r'\abs{-42}');        // 42.0
e.evaluate(r'\factorial{6}');    // 720.0
e.evaluate(r'\min_{x}{y}', {'x': 3, 'y': 7});  // 3.0
```
