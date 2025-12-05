# Mathematical Notation

This library supports standard LaTeX mathematical notation for summation, products, and limits.

## Supported Notation

| Notation | LaTeX | Example |
|----------|-------|---------|
| [Summation](sum_product.md) | `\sum_{i=a}^{b} expr` | `\sum_{i=1}^{5} i` → 15 |
| [Product](sum_product.md) | `\prod_{i=a}^{b} expr` | `\prod_{i=1}^{5} i` → 120 |
| [Limit](limits.md) | `\lim_{x \to a} expr` | `\lim_{x \to 0} x` → 0 |

## Common Patterns

```latex
% Sum of integers 1 to n
\sum_{i=1}^{n} i

% Factorial (product)
\prod_{i=1}^{n} i

% Sum of squares
\sum_{i=1}^{n} i^{2}

% Limit approaching a value
\lim_{x \to 0} \sin{x}
```

## Example

```dart
final e = LatexMathEvaluator();

// Sum: 1 + 2 + 3 + 4 + 5 = 15
e.evaluate(r'\sum_{i=1}^{5} i');  // 15.0

// Product: 5! = 120
e.evaluate(r'\prod_{i=1}^{5} i');  // 120.0
```
