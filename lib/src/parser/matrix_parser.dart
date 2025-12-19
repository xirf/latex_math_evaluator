import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin MatrixParserMixin on BaseParser {
  @override
  Expression parseMatrix() {
    final env = parseLatexArgument();
    if (!['matrix', 'pmatrix', 'bmatrix', 'vmatrix', 'align', 'aligned']
        .contains(env)) {
      throw ParserException(
        'Unsupported environment: $env',
        position: position,
        expression: sourceExpression,
        suggestion: 'Use matrix, pmatrix, bmatrix, vmatrix, or align',
      );
    }

    final rows = <List<Expression>>[];
    var currentRow = <Expression>[];

    while (!check(TokenType.end) && !isAtEnd) {
      if (check(TokenType.ampersand) ||
          check(TokenType.backslash) ||
          check(TokenType.end)) {
        registerNode();
        currentRow.add(NumberLiteral(0.0));
      } else {
        currentRow.add(parseExpression());
      }

      if (match1(TokenType.ampersand)) {
        continue;
      } else if (match1(TokenType.backslash)) {
        rows.add(currentRow);
        currentRow = [];
      } else if (!check(TokenType.end)) {
        throw ParserException(
          'Expected & or \\\\ or \\end',
          position: current.position,
          expression: sourceExpression,
          suggestion: 'Use & to separate columns or \\\\ to start a new row',
        );
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    consume(TokenType.end, "Expected \\end after matrix body");
    final endEnv = parseLatexArgument();

    if (endEnv != env) {
      throw ParserException(
        'Environment mismatch: \\begin{$env} ... \\end{$endEnv}',
        position: position,
        expression: sourceExpression,
        suggestion: 'Use \\end{$env} to match \\begin{$env}',
      );
    }

    registerNode();
    return MatrixExpr(rows);
  }
}
