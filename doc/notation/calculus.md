# Calculus Notation

The library supports basic calculus operations including limits and integration.

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

The library supports both symbolic and numerical integration.

### Symbolic Integration

Indefinite and definite integrals are evaluated symbolically using standard calculus rules.

#### Supported Rules

- **Power Rule**: `\int x^n dx = \frac{x^{n+1}}{n+1}` (including `\int \frac{1}{x} dx = \ln|x|`)
- **Linearity**: `\int (f(x) \pm g(x)) dx = \int f(x) dx \pm \int g(x) dx`
- **Constant Multiple**: `\int c \cdot f(x) dx = c \cdot \int f(x) dx`
- **Exponentials**: `\int e^{ax+b} dx`, `\int \exp(ax+b) dx`
- **Trigonometric**: `\int \sin(ax+b) dx`, `\int \cos(ax+b) dx`

### Syntax

```latex
\int expression dx
\int_{lower}^{upper} expression dx
```

The differential term (e.g., `dx`, `dt`) determines the variable of integration.

### Examples

- `\int x dx` evaluates to `x^2 / 2`.
- `\int_{0}^{1} x dx` evaluates to `0.5`.
- `\int \sin(x) dx` evaluates to `-\cos(x)`.
- `\int e^x dx` evaluates to `e^x`.

### Numerical Integration (Fallback)

If a definite integral cannot be solved symbolically, it may fall back to numerical approximation using **Simpson's Rule**.

### Notes

- For numerical fallback, the integration range is divided into 1000 intervals.
- Improper integrals (infinite bounds) are not fully supported in numerical mode and may result in `Infinity` or `NaN`.
