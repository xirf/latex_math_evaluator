import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin ExpressionParserMixin on BaseParser {
  @override
  Expression parseExpression() {
    return parseComparison();
  }

  Expression parseComparison() {
    var left = parsePlusMinus();

    final expressions = <Expression>[left];
    final operators = <ComparisonOperator>[];

    while (match([
      TokenType.less,
      TokenType.greater,
      TokenType.lessEqual,
      TokenType.greaterEqual,
      TokenType.equals
    ])) {
      final operator = tokens[position - 1];
      final right = parsePlusMinus();

      ComparisonOperator op;
      switch (operator.type) {
        case TokenType.less:
          op = ComparisonOperator.less;
          break;
        case TokenType.greater:
          op = ComparisonOperator.greater;
          break;
        case TokenType.lessEqual:
          op = ComparisonOperator.lessEqual;
          break;
        case TokenType.greaterEqual:
          op = ComparisonOperator.greaterEqual;
          break;
        case TokenType.equals:
          op = ComparisonOperator.equal;
          break;
        default:
          throw ParserException(
              'Unknown comparison operator', operator.position);
      }

      expressions.add(right);
      operators.add(op);
    }

    if (operators.length > 1) {
      return ChainedComparison(expressions, operators);
    } else if (operators.length == 1) {
      return Comparison(expressions[0], operators[0], expressions[1]);
    }

    return left;
  }

  Expression parsePlusMinus() {
    var left = parseTerm();

    while (match([TokenType.plus, TokenType.minus])) {
      final operator = tokens[position - 1];
      final right = parseTerm();

      left = BinaryOp(
        left,
        operator.type == TokenType.plus
            ? BinaryOperator.add
            : BinaryOperator.subtract,
        right,
      );
    }

    return left;
  }

  @override
  Expression parseTerm() {
    var left = parsePower();

    while (true) {
      if (match([TokenType.multiply, TokenType.divide])) {
        final operator = tokens[position - 1];
        final right = parsePower();

        left = BinaryOp(
          left,
          operator.type == TokenType.multiply
              ? BinaryOperator.multiply
              : BinaryOperator.divide,
          right,
        );
      } else if (checkImplicitMultiplication()) {
        final right = parsePower();
        left = BinaryOp(left, BinaryOperator.multiply, right);
      } else {
        break;
      }
    }

    return left;
  }

  bool checkImplicitMultiplication() {
    if (isAtEnd) return false;
    return check(TokenType.number) ||
        check(TokenType.variable) ||
        check(TokenType.constant) ||
        check(TokenType.lparen) || 
        check(TokenType.function) ||
        check(TokenType.lim) ||
        check(TokenType.sum) ||
        check(TokenType.prod) ||
        check(TokenType.frac) ||
        check(TokenType.infty);
  }

  @override
  Expression parsePower() {
    var left = parseUnary();

    if (match([TokenType.power])) {
      if (check(TokenType.lparen) && current.value == '{') {
        advance(); 
        final right = parseExpression(); 
        consume(TokenType.rparen, "Expected '}' after exponent");
        return BinaryOp(left, BinaryOperator.power, right);
      } else {
        final right = parsePower(); 
        return BinaryOp(left, BinaryOperator.power, right);
      }
    }

    return left;
  }

  @override
  Expression parseUnary() {
    if (match([TokenType.minus])) {
      final operand = parseUnary();
      return UnaryOp(UnaryOperator.negate, operand);
    }

    return parsePrimary();
  }
}
