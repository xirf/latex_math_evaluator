# Trigonometric Functions

## Standard Trigonometric

### `\sin{x}` - Sine

Returns the sine of x (in radians).

```latex
\sin{0}          → 0
\sin{1.5707963}  → 1  (π/2)
```

### `\cos{x}` - Cosine

Returns the cosine of x (in radians).

```latex
\cos{0}          → 1
\cos{3.1415926}  → -1 (π)
```

### `\tan{x}` - Tangent

Returns the tangent of x (in radians).

```latex
\tan{0}          → 0
```

## Inverse Trigonometric

### `\asin{x}` / `\arcsin{x}` - Arcsine

Returns the arcsine of x. Domain: [-1, 1]

```latex
\asin{0}         → 0
\asin{1}         → 1.5707963 (π/2)
```

### `\acos{x}` / `\arccos{x}` - Arccosine

Returns the arccosine of x. Domain: [-1, 1]

```latex
\acos{1}         → 0
\acos{0}         → 1.5707963 (π/2)
```

### `\atan{x}` / `\arctan{x}` - Arctangent

Returns the arctangent of x.

```latex
\atan{0}         → 0
\atan{1}         → 0.7853981 (π/4)
```

## Hyperbolic Functions

### `\sinh{x}` - Hyperbolic Sine

```latex
\sinh{0}         → 0
```

### `\cosh{x}` - Hyperbolic Cosine

```latex
\cosh{0}         → 1
```

### `\tanh{x}` - Hyperbolic Tangent

```latex
\tanh{0}         → 0
```

## Example

```dart
final e = LatexMathEvaluator();

// Using with pi constant
e.evaluate(r'\sin{x}', {'x': 3.14159 / 2});  // ~1.0

// Inverse trig
e.evaluate(r'\asin{1}');  // π/2
```
