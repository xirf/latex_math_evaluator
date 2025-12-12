import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
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

    List<Expression> args = [];
    if (check(TokenType.lparen)) {
      advance();
      args.add(parseExpression());
      while (match([TokenType.comma])) {
        args.add(parseExpression());
      }
      consume(TokenType.rparen,
          "Expected closing brace/paren after function argument");
    } else {
      args.add(parseUnary());
    }

    if (args.length == 1) {
      return FunctionCall(name, args[0], base: base);
    }
    return FunctionCall.multivar(name, args, base: base);
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

  @override
  Expression parseIntegralExpr() {
    consume(TokenType.underscore, "Expected '_' after \\int");
    consume(TokenType.lparen, "Expected '{' after '_'");
    final lower = parseExpression();
    consume(TokenType.rparen, "Expected '}' after lower bound");

    consume(TokenType.power, "Expected '^' after integral subscript");
    consume(TokenType.lparen, "Expected '{' after '^'");
    final upper = parseExpression();
    consume(TokenType.rparen, "Expected '}' after upper bound");

    final fullBody = parseExpression();

    // Attempt to extract body and variable from "body * d * variable" structure
    Expression? body;
    String? variable;

    if (fullBody is BinaryOp && fullBody.operator == BinaryOperator.multiply) {
      final right = fullBody.right;
      final left = fullBody.left;

      if (right is Variable) {
        final potentialVar = right.name;

        if (left is Variable && left.name == 'd') {
          // Case: \int dx -> d * x
          body = NumberLiteral(1.0);
          variable = potentialVar;
        } else if (left is BinaryOp &&
            left.operator == BinaryOperator.multiply) {
          // Case: \int f(x) dx -> f(x) * d * x
          // left is (f(x) * d)
          if (left.right is Variable && (left.right as Variable).name == 'd') {
            body = left.left;
            variable = potentialVar;
          }
        }
      }
    }

    if (body == null || variable == null) {
      throw ParserException(
          "Expected differential (e.g., 'dx') at the end of integral",
          tokens[position - 1].position);
    }

    return IntegralExpr(lower, upper, body, variable);
  }
}
