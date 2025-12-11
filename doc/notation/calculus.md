# Calculus Notation

The library supports basic calculus operations including limits and numerical integration.

## Limits

Limits are evaluated by substituting the target value into the expression. Note that this is a simple substitution and does not handle indeterminate forms (like 0/0) using L'Hôpital's rule.

### Syntax

```latex
\lim_{variable \to target} expression
```

### Examples

- `\lim_{x \to 0} (x + 1)` evaluates to `1`.
- `\lim_{x \to \infty} (1/x)` evaluates to `0`.

## Integrals

Definite integrals are evaluated using **Simpson's Rule** for numerical approximation.

### Syntax

```latex
\int_{lower}^{upper} expression dx
```

The differential term (e.g., `dx`, `dt`) determines the variable of integration.

### Examples

- `\int_{0}^{1} x dx` evaluates to `0.5`.
- `\int_{0}^{\pi} \sin(x) dx` evaluates to `2.0`.
- `\int_{1}^{e} \frac{1}{t} dt` evaluates to `1.0`.

### Notes

- The integration range is divided into 1000 intervals for approximation.
- Improper integrals (infinite bounds) are not supported and may result in `Infinity` or `NaN`.
