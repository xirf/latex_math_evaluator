/// A library for parsing and evaluating LaTeX-formatted math expressions.
///
/// ## Usage
///
/// ```dart
/// import 'package:latex_math_evaluator/latex_math_evaluator.dart';
///
/// // Parse and evaluate a simple expression
/// final result = LatexMathEvaluator().evaluate('2 + 3 \\times 4');
/// print(result); // 14.0
///
/// // With variables
/// final result2 = LatexMathEvaluator().evaluate('x^{2} + 1', {'x': 3});
/// print(result2); // 10.0
///
/// // Logarithms
/// final result3 = LatexMathEvaluator().evaluate('\\log_{2}{8}');
/// print(result3); // 3.0
///
/// // Limits
/// final result4 = LatexMathEvaluator().evaluate('\\lim_{x \\to 0} x');
/// print(result4); // 0.0
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
export 'src/parser.dart';
export 'src/token.dart';
export 'src/tokenizer.dart';

import 'src/evaluator.dart';
import 'src/extensions.dart';
import 'src/parser.dart';
import 'src/tokenizer.dart';

/// A convenience class that combines tokenizing, parsing, and evaluation.
class LatexMathEvaluator {
  final ExtensionRegistry? _extensions;
  late final Evaluator _evaluator;

  /// Creates an evaluator with optional extension registry.
  LatexMathEvaluator({ExtensionRegistry? extensions}) : _extensions = extensions {
    _evaluator = Evaluator(extensions: _extensions);
  }

  /// Parses and evaluates a LaTeX math expression.
  ///
  /// [expression] is the LaTeX math string to evaluate.
  /// [variables] is an optional map of variable names to their numeric values.
  ///
  /// Returns the computed result as a double.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = LatexMathEvaluator();
  /// evaluator.evaluate('2 + 3'); // 5.0
  /// evaluator.evaluate('x + 1', {'x': 2}); // 3.0
  /// evaluator.evaluate('\\log{10}'); // 1.0
  /// evaluator.evaluate('\\lim_{x \\to 1} x^{2}'); // 1.0
  /// ```
  double evaluate(String expression, [Map<String, double> variables = const {}]) {
    final tokens = Tokenizer(expression, extensions: _extensions).tokenize();
    final ast = Parser(tokens).parse();
    return _evaluator.evaluate(ast, variables);
  }
}

