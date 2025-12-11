import '../ast.dart';
import '../exceptions.dart';
import '../token.dart';

abstract class BaseParser {
  final List<Token> tokens;
  int position = 0;

  BaseParser(this.tokens);

  bool get isAtEnd => position >= tokens.length;

  Token get current => tokens[position];

  Token advance() {
    if (!isAtEnd) position++;
    return tokens[position - 1];
  }

  bool check(TokenType type) => !isAtEnd && current.type == type;

  bool match(List<TokenType> types) {
    for (final type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }
    return false;
  }

  Token consume(TokenType type, String message) {
    if (check(type)) return advance();
    throw ParserException(message, current.position);
  }

  String parseLatexArgument() {
    consume(TokenType.lparen, "Expected '{'");
    final buffer = StringBuffer();
    while (!check(TokenType.rparen) && !isAtEnd) {
      buffer.write(advance().value);
    }
    consume(TokenType.rparen, "Expected '}'");
    return buffer.toString();
  }
  
  // Abstract methods for mutual recursion
  Expression parseExpression();
  Expression parsePrimary();
  Expression parseUnary();
  Expression parseTerm();
  Expression parsePower();
  
  Expression parseFunctionCall();
  Expression parseLimitExpr();
  Expression parseSumExpr();
  Expression parseProductExpr();
  Expression parseIntegralExpr();
  Expression parseMatrix();
}
