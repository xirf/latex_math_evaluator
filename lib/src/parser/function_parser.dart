import '../ast.dart';
import '../token.dart';
import 'base_parser.dart';

mixin FunctionParserMixin on BaseParser {
  @override
  Expression parseFunctionCall() {
    final name = tokens[position - 1].value;
    Expression? base;

    if (match([TokenType.underscore])) {
      consume(TokenType.lparen, "Expected '{' after '_'");
      base = parseExpression();
      consume(TokenType.rparen, "Expected '}' after base");
    }

    Expression argument;
    if (check(TokenType.lparen)) {
      advance();
      argument = parseExpression();
      consume(TokenType.rparen,
          "Expected closing brace/paren after function argument");
    } else {
      argument = parseUnary();
    }

    return FunctionCall(name, argument, base: base);
  }

  @override
  Expression parseLimitExpr() {
    consume(TokenType.underscore, "Expected '_' after \\lim");
    consume(TokenType.lparen, "Expected '{' after '_'");

    final varToken = consume(TokenType.variable, "Expected variable in limit");
    final variable = varToken.value;

    consume(TokenType.to, "Expected '\\to' in limit");

    final target = parseExpression();

    consume(TokenType.rparen, "Expected '}' after limit subscript");

    final body = parseExpression();

    return LimitExpr(variable, target, body);
  }

  @override
  Expression parseSumExpr() {
    consume(TokenType.underscore, "Expected '_' after \\sum");
    consume(TokenType.lparen, "Expected '{' after '_'");

    final varToken = consume(TokenType.variable, "Expected variable in sum");
    final variable = varToken.value;

    consume(TokenType.equals, "Expected '=' after variable");

    final start = parseExpression();

    consume(TokenType.rparen, "Expected '}' after start value");

    consume(TokenType.power, "Expected '^' after sum subscript");
    consume(TokenType.lparen, "Expected '{' after '^'");

    final end = parseExpression();

    consume(TokenType.rparen, "Expected '}' after end value");

    final body = parseExpression();

    return SumExpr(variable, start, end, body);
  }

  @override
  Expression parseProductExpr() {
    consume(TokenType.underscore, "Expected '_' after \\prod");
    consume(TokenType.lparen, "Expected '{' after '_'");

    final varToken =
        consume(TokenType.variable, "Expected variable in product");
    final variable = varToken.value;

    consume(TokenType.equals, "Expected '=' after variable");

    final start = parseExpression();

    consume(TokenType.rparen, "Expected '}' after start value");

    consume(TokenType.power, "Expected '^' after product subscript");
    consume(TokenType.lparen, "Expected '{' after '^'");

    final end = parseExpression();

    consume(TokenType.rparen, "Expected '}' after end value");

    final body = parseExpression();

    return ProductExpr(variable, start, end, body);
  }
}
