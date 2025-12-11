/// Token types and Token class for the LaTeX math lexer.
library;

/// Represents the type of a lexical token.
enum TokenType {
  /// Numeric literal (integer or decimal).
  number,

  /// Variable identifier (single letter).
  variable,

  /// Addition operator `+`.
  plus,

  /// Subtraction operator `-`.
  minus,

  /// Multiplication operator `*`, `\times`, or `\cdot`.
  multiply,

  /// Division operator `/` or `\div`.
  divide,

  /// Power/exponent operator `^`.
  power,

  /// Left parenthesis `(` or left brace `{`.
  lparen,

  /// Right parenthesis `)` or right brace `}`.
  rparen,

  /// Underscore `_` for subscripts.
  underscore,

  /// Function name (e.g., `\log`, `\ln`, `\sin`).
  function,

  /// Fraction `\frac`.
  frac,

  /// Limit keyword `\lim`.
  lim,

  /// Sum keyword `\sum`.
  sum,

  /// Product keyword `\prod`.
  prod,

  /// Arrow `\to` or `\rightarrow`.
  to,

  /// Equals sign `=`.
  equals,

  /// Infinity `\infty`.
  infty,

  /// Mathematical constant (e.g., `\pi`, `\tau`, `\phi`).
  constant,

  // Comparison
  less,
  greater,
  lessEqual,
  greaterEqual,

  // Misc
  /// Comma `,`.
  comma,

  /// Pipe `|` for absolute value.
  pipe,

  /// Ampersand `&` for matrix column separation.
  ampersand,

  /// Double backslash `\\` for matrix row separation.
  backslash,

  /// Begin environment `\begin`.
  begin,

  /// End environment `\end`.
  end,

  /// End of input.
  eof,
}

/// Represents a single lexical token.
class Token {
  /// The type of this token.
  final TokenType type;

  /// The literal value of this token (e.g., "3.14" for a number).
  final String value;

  /// The position in the source string where this token starts.
  final int position;

  const Token({
    required this.type,
    required this.value,
    required this.position,
  });

  @override
  String toString() => 'Token($type, "$value", pos:$position)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}
