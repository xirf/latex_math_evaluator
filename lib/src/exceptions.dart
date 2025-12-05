/// Custom exceptions for the LaTeX math evaluator library.
library;

/// Base exception for all LaTeX math evaluator errors.
sealed class LatexMathException implements Exception {
  final String message;
  final int? position;

  const LatexMathException(this.message, [this.position]);

  @override
  String toString() {
    if (position != null) {
      return '$runtimeType at position $position: $message';
    }
    return '$runtimeType: $message';
  }
}

/// Exception thrown during tokenization.
class TokenizerException extends LatexMathException {
  const TokenizerException(super.message, [super.position]);
}

/// Exception thrown during parsing.
class ParserException extends LatexMathException {
  const ParserException(super.message, [super.position]);
}

/// Exception thrown during evaluation.
class EvaluatorException extends LatexMathException {
  const EvaluatorException(super.message, [super.position]);
}
