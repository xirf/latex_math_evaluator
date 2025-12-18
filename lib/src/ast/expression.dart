/// Base class for all expression nodes.
///
/// This is an abstract class rather than sealed to allow users to create
/// custom expression types for extension purposes.
abstract class Expression {
  const Expression();

  /// Converts this expression to LaTeX notation.
  ///
  /// This enables round-trip support: LaTeX → AST → LaTeX.
  /// The generated LaTeX should be parseable back into an equivalent AST.
  ///
  /// Example:
  /// ```dart
  /// final expr = parser.parse(r'\frac{x^2 + 1}{2}');
  /// final latex = expr.toLatex(); // Returns: \frac{x^{2}+1}{2}
  /// ```
  String toLatex();
}
