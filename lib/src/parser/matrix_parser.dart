import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin MatrixParserMixin on BaseParser {
  @override
  Expression parseMatrix() {
    final env = parseLatexArgument();
    if (!['matrix', 'pmatrix', 'bmatrix', 'vmatrix'].contains(env)) {
      throw ParserException('Unsupported matrix environment: $env', position);
    }

    final rows = <List<Expression>>[];
    var currentRow = <Expression>[];

    while (!check(TokenType.end) && !isAtEnd) {
      if (check(TokenType.ampersand) ||
          check(TokenType.backslash) ||
          check(TokenType.end)) {
        currentRow.add(NumberLiteral(0.0));
      } else {
        currentRow.add(parseExpression());
      }

      if (match([TokenType.ampersand])) {
        continue;
      } else if (match([TokenType.backslash])) {
        rows.add(currentRow);
        currentRow = [];
      } else if (!check(TokenType.end)) {
        throw ParserException('Expected & or \\\\ or \\end', current.position);
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    consume(TokenType.end, "Expected \\end after matrix body");
    final endEnv = parseLatexArgument();

    if (endEnv != env) {
      throw ParserException(
          'Environment mismatch: \\begin{$env} ... \\end{$endEnv}', position);
    }

    return MatrixExpr(rows);
  }
}
