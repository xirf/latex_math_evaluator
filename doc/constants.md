# Built-in Constants

Constants are used as fallback when a variable is not provided by the user.

## Available Constants

| Name    | Symbol | Value            | Description            |
| ------- | ------ | ---------------- | ---------------------- |
| `e`     | e      | 2.71828182845905 | Euler's number         |
| `pi`    | π      | 3.14159265358979 | Pi                     |
| `tau`   | τ      | 6.28318530717959 | 2 × π                  |
| `phi`   | φ      | 1.61803398874989 | Golden ratio           |
| `gamma` | γ      | 0.57721566490153 | Euler-Mascheroni       |
| `Omega` | Ω      | 0.56714329040978 | Lambert W constant     |
| `delta` | δ      | 2.41421356237310 | Silver ratio (1+√2)    |
| `G`     | G      | 6.67430e-11      | Gravitational constant |
| `zeta3` | ζ(3)   | 1.20205690315959 | Apéry's constant       |
| `sqrt2` | √2     | 1.41421356237310 | Square root of 2       |
| `sqrt3` | √3     | 1.73205080756888 | Square root of 3       |
| `ln2`   | ln(2)  | 0.69314718055995 | Natural log of 2       |
| `ln10`  | ln(10) | 2.30258509299405 | Natural log of 10      |

## Usage

Constants work as single-letter variable names:

```dart
final e = LatexMathEvaluator();

// 'e' resolves to Euler's number
e.evaluate('e');  // 2.71828...

// Use in expressions
e.evaluate(r'\ln{e}');  // 1.0 (ln(e) = 1)
```

## Overriding Constants

User-provided variables override built-in constants by default:

```dart
// Override 'e' with custom value
e.evaluate('e', {'e': 3.0});  // 3.0

// Constant used when variable not provided
e.evaluate('e');  // 2.71828...
```

## Multi-character Constants

Multi-character constant names (like `pi`, `phi`) require using them as variable bindings since the parser only reads single characters:

```dart
// Bind pi value to a single-letter variable
e.evaluate(r'\sin{p}', {'p': 3.14159});  // ~0
```
