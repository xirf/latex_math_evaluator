# Academic LaTeX Support

This library supports common LaTeX notation found in academic papers, textbooks, and lecture notes, allowing copy-paste of mathematical expressions from these sources.

## Delimiter Sizing Commands

LaTeX provides commands to control the size of delimiters (parentheses, brackets, braces, etc.). These are purely visual in LaTeX and don't affect the mathematical meaning, so they are silently ignored during evaluation.

### Supported Commands

#### `\left` and `\right`

Used for automatic delimiter sizing:

```latex
\left|x+1\right|        % Absolute value
\left(2+3\right)        % Parentheses
\left(\frac{a}{b}\right)  % Fraction in parentheses
```

Examples:
```dart
final e = LatexMathEvaluator();

// Absolute value with \left and \right
e.evaluate(r'\sqrt{\left|x+1\right|}', {'x': -2});  // 1.0

// Nested delimiters
e.evaluate(r'\left(\left(2+3\right) * 4\right) + 1');  // 21.0

// Complex expressions
e.evaluate(r'\frac{\left|x-2\right|}{\left(x+1\right)}', {'x': 5});  // 0.5
```

#### `\big`, `\Big`, `\bigg`, `\Bigg`

Manual delimiter sizing commands (also ignored):

```latex
\big(x+y\big)
\Big[a+b\Big]
\bigg(2+3\bigg)
\Bigg|x\Bigg|
```

### Escaped Braces

LaTeX uses `\{` and `\}` to display literal braces (since `{` and `}` are used for grouping). These are treated as regular parentheses:

```latex
\left\{2+3\right\}  % Same as \left(2+3\right)
```

Example:
```dart
e.evaluate(r'\left\{2+3\right\} * 5');  // 25.0
```

## Notes

- **Mismatch Tolerance**: Unlike LaTeX rendering, this library does not require `\left` and `\right` to be properly matched; they are ignored during parsing.
- **No Visual Effect**: Since evaluation is mathematical (not visual), delimiter sizes have no impact on the result.
- **Copy-Paste Friendly**: You can copy expressions directly from papers or notes without removing these commands.

## Examples from Academic Sources

### Calculus Notation

```dart
// From a calculus textbook
e.evaluate(r'\left(\frac{d}{dx}\right)^2');  // If d and x are defined

// Limit notation
e.evaluate(r'\lim_{x \to 0} \frac{\left|x\right|}{x}');  // NaN (undefined)
```

### Physics Formulas

```dart
// Energy equation with delimiters
e.evaluate(r'\left(\frac{1}{2}\right) m v^2', {'m': 2, 'v': 3});  // 9.0
```

### Complex Expressions

```dart
// Multi-level nesting common in academic papers
e.evaluate(
  r'\left[\left(\frac{x}{2}\right)^2 + 1\right]',
  {'x': 4},
);  // 5.0
```

## See Also

- [Getting Started](getting_started.md) - Basic usage
- [Functions](functions/README.md) - Available functions
- [Notation](notation/README.md) - Mathematical notation support
