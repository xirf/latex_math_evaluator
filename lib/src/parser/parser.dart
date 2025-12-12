import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';
import 'expression_parser.dart';
import 'primary_parser.dart';
import 'function_parser.dart';
import 'matrix_parser.dart';

/// Recursive descent parser for LaTeX math expressions.
class Parser extends BaseParser
    with
        ExpressionParserMixin,
        PrimaryParserMixin,
        FunctionParserMixin,
        MatrixParserMixin {
  Parser(List<Token> tokens) : super(tokens);

  /// Parses the token stream and returns the root expression.
  Expression parse() {
    if (tokens.length > 4 &&
        tokens[0].type == TokenType.variable &&
        tokens[1].type == TokenType.lparen &&
        tokens[2].type == TokenType.variable &&
        tokens[3].type == TokenType.rparen &&
        tokens[4].type == TokenType.equals) {
      position += 5;
    }

    var expr = parseExpression();

    if (match([TokenType.comma])) {
      final condition = parseExpression();
      expr = ConditionalExpr(expr, condition);
    }

    if (!isAtEnd && current.type != TokenType.eof) {
      throw ParserException(
          'Unexpected token: ${current.value}', current.position);
    }

    return expr;
  }
}
