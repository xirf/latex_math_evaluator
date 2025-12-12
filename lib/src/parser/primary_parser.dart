import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin PrimaryParserMixin on BaseParser {
  @override
  Expression parsePrimary() {
    if (match([TokenType.number])) {
      final value = double.parse(tokens[position - 1].value);
      return NumberLiteral(value);
    }

    if (match([TokenType.variable])) {
      return Variable(tokens[position - 1].value);
    }

    if (match([TokenType.constant])) {
      return Variable(tokens[position - 1].value);
    }

    if (match([TokenType.infty])) {
      return NumberLiteral(double.infinity);
    }

    if (match([TokenType.function])) {
      return parseFunctionCall();
    }

    if (match([TokenType.lim])) {
      return parseLimitExpr();
    }

    if (match([TokenType.sum])) {
      return parseSumExpr();
    }

    if (match([TokenType.prod])) {
      return parseProductExpr();
    }

    if (match([TokenType.int])) {
      return parseIntegralExpr();
    }

    if (match([TokenType.frac])) {
      return parseFraction();
    }

    if (match([TokenType.binom])) {
      return parseBinom();
    }

    if (match([TokenType.begin])) {
      return parseMatrix();
    }

    if (match([TokenType.pipe])) {
      final expr = parseExpression();
      consume(TokenType.pipe, "Expected '|' after absolute value expression");
      return AbsoluteValue(expr);
    }

    if (match([TokenType.lparen])) {
      final closingChar = tokens[position - 1].value == '(' ? ')' : '}';
      final expr = parseExpression();

      if (!check(TokenType.rparen)) {
        throw ParserException("Expected '$closingChar'", current.position);
      }
      advance();

      if (closingChar == '}' &&
          check(TokenType.lparen) &&
          current.value == '{') {
        advance();
        final condition = parseExpression();
        consume(TokenType.rparen, "Expected '}' after condition");
        return ConditionalExpr(expr, condition);
      }

      return expr;
    }

    throw ParserException(
        'Expected expression, got: ${current.value}', current.position);
  }

  Expression parseFraction() {
    consume(TokenType.lparen, "Expected '{' after \\frac");
    final numerator = parseExpression();
    consume(TokenType.rparen, "Expected '}' after numerator");

    consume(TokenType.lparen, "Expected '{' after numerator");
    final denominator = parseExpression();
    consume(TokenType.rparen, "Expected '}' after denominator");

    return BinaryOp(numerator, BinaryOperator.divide, denominator);
  }

  Expression parseBinom() {
    consume(TokenType.lparen, "Expected '{' after \\binom");
    final n = parseExpression();
    consume(TokenType.rparen, "Expected '}' after n");

    consume(TokenType.lparen, "Expected '{' after n");
    final k = parseExpression();
    consume(TokenType.rparen, "Expected '}' after k");

    return FunctionCall.multivar('binom', [n, k]);
  }
}
