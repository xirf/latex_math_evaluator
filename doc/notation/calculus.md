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
- `\lim_{x \to 0} (x + 1)` evaluates to `1`.
- `\lim_{x \to \infty} \left(\frac{1}{x}\right)` evaluates to `0`.

## Integrals

Definite integrals are evaluated using **Simpson's Rule** for numerical approximation.

### Syntax

```latex
\int_{lower}^{upper} body dx
```

The differential term (e.g., `dx`, `dt`) at the end determined the variable of integration.

### Examples

- `\int_{0}^{1} x dx` evaluates to `0.5`.
- `\int_{0}^{\pi} \sin{x} dx` evaluates to `2.0`.
- `\int_{1}^{e} \frac{1}{t} dt` evaluates to `1.0`.

### Notes

- The integration range is divided into 10,000 intervals for high-precision approximation.
- **Improper integrals**: Infinite bounds (e.g., `\int_{0}^{\infty}`) are basic-supported by substituting a large numeric range (e.g., ±100). This works well for functions that decay rapidly at infinity.
