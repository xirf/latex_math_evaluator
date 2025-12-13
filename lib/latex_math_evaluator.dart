/// A library for parsing and evaluating LaTeX-formatted math expressions.
///
/// ## Usage
///
/// ```dart
/// import 'package:latex_math_evaluator/latex_math_evaluator.dart';
///
/// // Parse and evaluate a simple expression
/// final result = LatexMathEvaluator().evaluate('2 + 3 \\times 4');
/// print(result.asNumeric()); // 14.0
///
/// // With variables
/// final result2 = LatexMathEvaluator().evaluate('x^{2} + 1', {'x': 3});
/// print(result2.asNumeric()); // 10.0
///
/// // Logarithms
/// final result3 = LatexMathEvaluator().evaluate('\\log_{2}{8}');
/// print(result3.asNumeric()); // 3.0
///
/// // Limits
/// final result4 = LatexMathEvaluator().evaluate('\\lim_{x \\to 0} x');
/// print(result4.asNumeric()); // 0.0
///
/// // Pattern matching on result type
/// final result5 = LatexMathEvaluator().evaluate('2 + 3');
/// switch (result5) {
///   case NumericResult(:final value):
///     print('Got number: $value');
///   case MatrixResult(:final matrix):
///     print('Got matrix: $matrix');
/// }
/// ```
///
/// ## Parse Once, Evaluate Many Times (Memory Efficient)
///
/// ```dart
/// final evaluator = LatexMathEvaluator();
///
/// // Parse the expression once
/// final equation = evaluator.parse('x^{2} + 2x + 1');
///
/// // Reuse with different variable values
/// print(evaluator.evaluateParsed(equation, {'x': 1}).asNumeric()); // 4.0
/// print(evaluator.evaluateParsed(equation, {'x': 2}).asNumeric()); // 9.0
/// print(evaluator.evaluateParsed(equation, {'x': 3}).asNumeric()); // 16.0
/// ```
///
/// ## Custom Extensions
///
/// ```dart
/// final registry = ExtensionRegistry();
/// registry.registerCommand('sqrt', (cmd, pos) =>
///   Token(type: TokenType.function, value: 'sqrt', position: pos));
/// registry.registerEvaluator((expr, vars, eval) {
///   if (expr is FunctionCall && expr.name == 'sqrt') {
///     return math.sqrt(eval(expr.argument));
///   }
///   return null;
/// });
/// final evaluator = LatexMathEvaluator(extensions: registry);
/// ```
library latex_math_evaluator;

export 'src/ast.dart';
export 'src/evaluator.dart';
export 'src/exceptions.dart';
export 'src/extensions.dart';
export 'src/matrix.dart';
export 'src/parser.dart';
export 'src/token.dart';
export 'src/tokenizer.dart';

import 'src/ast.dart';
import 'src/evaluator.dart';
import 'src/exceptions.dart';
import 'src/extensions.dart';
import 'src/matrix.dart';
import 'src/parser.dart';
import 'src/tokenizer.dart';

/// A convenience class that combines tokenizing, parsing, and evaluation.
class LatexMathEvaluator {
  final ExtensionRegistry? _extensions;
  final bool allowImplicitMultiplication;
  late final Evaluator _evaluator;

  /// Creates an evaluator with optional extension registry.
  LatexMathEvaluator(
      {ExtensionRegistry? extensions, this.allowImplicitMultiplication = true})
      : _extensions = extensions {
    _evaluator = Evaluator(extensions: _extensions);
  }

  /// Parses a LaTeX math expression into an AST without evaluating.
  ///
  /// This allows you to parse once and evaluate multiple times with different
  /// variable bindings, which is more memory efficient.
  ///
  /// [expression] is the LaTeX math string to parse.
  ///
  /// Returns the parsed AST [Expression] that can be reused.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  /// final equation = evaluator.parse('x^{2} + 2x + 1');
  ///
  /// // Reuse the parsed equation with different values
  /// final result1 = evaluator.evaluateParsed(equation, {'x': 1}); // 4.0
  /// final result2 = evaluator.evaluateParsed(equation, {'x': 2}); // 9.0
  /// final result3 = evaluator.evaluateParsed(equation, {'x': 3}); // 16.0
  /// ```
  Expression parse(String expression) {
    final tokens = Tokenizer(expression,
            extensions: _extensions,
            allowImplicitMultiplication: allowImplicitMultiplication)
        .tokenize();
    return Parser(tokens, expression).parse();
  }

  /// Evaluates a pre-parsed expression with variable bindings.
  ///
  /// [ast] is the parsed expression from [parse()].
  /// [variables] is a map of variable names to their values.
  ///
  /// Returns the computed result as an [EvaluationResult], which can be
  /// either a [NumericResult] or [MatrixResult].
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  /// final equation = evaluator.parse('x + y');
  /// final result = evaluator.evaluateParsed(equation, {'x': 10, 'y': 5});
  /// print(result.asNumeric()); // 15.0
  /// ```
  EvaluationResult evaluateParsed(Expression ast,
      [Map<String, double> variables = const {}]) {
    return _evaluator.evaluate(ast, variables);
  }

  /// Parses and evaluates a LaTeX math expression.
  ///
  /// [expression] is the LaTeX math string to evaluate.
  /// [variables] is an optional map of variable names to their numeric values.
  ///
  /// Returns the computed result as an [EvaluationResult], which can be
  /// either a [NumericResult] or [MatrixResult].
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  /// final result = evaluator.evaluate('2 + 3');
  /// print(result.asNumeric()); // 5.0
  ///
  /// final result2 = evaluator.evaluate('x + 1', {'x': 2});
  /// print(result2.asNumeric()); // 3.0
  ///
  /// final result3 = evaluator.evaluate('\\log{10}');
  /// print(result3.asNumeric()); // 1.0
  ///
  /// final result4 = evaluator.evaluate('\\lim_{x \\to 1} x^{2}');
  /// print(result4.asNumeric()); // 1.0
  /// ```
  EvaluationResult evaluate(String expression,
      [Map<String, double> variables = const {}]) {
    final ast = parse(expression);
    return _evaluator.evaluate(ast, variables);
  }

  /// Evaluates a LaTeX expression and returns a numeric result.
  ///
  /// This is a convenience method that evaluates the expression and automatically
  /// extracts the numeric value. Use this when you know the result will be numeric.
  ///
  /// [expression] is the LaTeX math string to evaluate.
  /// [variables] is an optional map of variable names to their numeric values.
  ///
  /// Returns the computed result as a [double].
  ///
  /// Throws [StateError] if the result is a matrix or non-real complex number.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  ///
  /// final result = evaluator.evaluateNumeric('2 + 3'); // 5.0
  /// final result2 = evaluator.evaluateNumeric('x^{2}', {'x': 3}); // 9.0
  /// final result3 = evaluator.evaluateNumeric('\sin{0}'); // 0.0
  /// ```
  double evaluateNumeric(String expression,
      [Map<String, double> variables = const {}]) {
    return evaluate(expression, variables).asNumeric();
  }

  /// Evaluates a LaTeX expression and returns a matrix result.
  ///
  /// This is a convenience method that evaluates the expression and automatically
  /// extracts the matrix value. Use this when you know the result will be a matrix.
  ///
  /// [expression] is the LaTeX math string to evaluate.
  /// [variables] is an optional map of variable names to their numeric values.
  ///
  /// Returns the computed result as a [Matrix].
  ///
  /// Throws [StateError] if the result is not a matrix.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  ///
  /// final matrix = evaluator.evaluateMatrix(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
  /// print(matrix); // [[1.0, 2.0], [3.0, 4.0]]
  /// ```
  Matrix evaluateMatrix(String expression,
      [Map<String, double> variables = const {}]) {
    return evaluate(expression, variables).asMatrix();
  }

  /// Checks if a LaTeX math expression is syntactically valid.
  ///
  /// This is a quick check that only validates syntax during tokenization
  /// and parsing. It does not check for undefined variables or evaluate
  /// the expression.
  ///
  /// [expression] is the LaTeX math string to validate.
  ///
  /// Returns `true` if the expression can be parsed successfully,
  /// `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  ///
  /// evaluator.isValid(r'2 + 3');        // true
  /// evaluator.isValid(r'\sin{x}');      // true (variables are OK)
  /// evaluator.isValid(r'\sin{');        // false (unclosed brace)
  /// evaluator.isValid(r'\unknown{5}');  // false (unknown command)
  /// ```
  bool isValid(String expression) {
    try {
      parse(expression);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Validates a LaTeX math expression and returns detailed error information.
  ///
  /// Unlike [isValid], this method returns a [ValidationResult] containing
  /// detailed information about any errors, including position and suggestions.
  ///
  /// This only validates syntax during tokenization and parsing. Variables
  /// are allowed in expressions and won't cause validation to fail.
  ///
  /// [expression] is the LaTeX math string to validate.
  ///
  /// Returns a [ValidationResult] with validation status and error details.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  ///
  /// final result = evaluator.validate(r'\sin{');
  /// if (!result.isValid) {
  ///   print('Error: ${result.errorMessage}');
  ///   print('Position: ${result.position}');
  ///   if (result.suggestion != null) {
  ///     print('Suggestion: ${result.suggestion}');
  ///   }
  /// }
  /// ```
  ValidationResult validate(String expression) {
    try {
      parse(expression);
      return const ValidationResult.valid();
    } on LatexMathException catch (e) {
      return ValidationResult.fromException(e);
    } catch (e) {
      // Handle unexpected errors
      return ValidationResult(
        isValid: false,
        errorMessage: 'Unexpected error: $e',
        suggestion: 'Please report this as a bug',
      );
    }
  }
}
