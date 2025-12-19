import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin PrimaryParserMixin on BaseParser {
  @override
  Expression parsePrimary() {
    enterRecursion();
    try {
      if (match([TokenType.number])) {
        final value = double.parse(tokens[position - 1].value);
        registerNode();
        return NumberLiteral(value);
      }

      if (match([TokenType.variable])) {
        registerNode();
        return Variable(tokens[position - 1].value);
      }

      if (match([TokenType.constant])) {
        registerNode();
        return Variable(tokens[position - 1].value);
      }

      if (match([TokenType.infty])) {
        registerNode();
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
        registerNode();
        return AbsoluteValue(expr);
      }

      if (match([TokenType.lparen])) {
        final closingChar = tokens[position - 1].value == '(' ? ')' : '}';
        final expr = parseExpression();

        if (!check(TokenType.rparen)) {
          throw ParserException(
            "Expected '$closingChar'",
            position: current.position,
            expression: sourceExpression,
            suggestion: closingChar == ')'
                ? 'Add a closing parenthesis ) to match the opening'
                : 'Add a closing brace } to match the opening',
          );
        }
        advance();

        if (closingChar == '}' &&
            check(TokenType.lparen) &&
            current.value == '{') {
          advance();
          final condition = parseExpression();
          consume(TokenType.rparen, "Expected '}' after condition");
          registerNode();
          return ConditionalExpr(expr, condition);
        }

        return expr;
      }

      throw ParserException(
        'Expected expression, got: ${current.value}',
        position: current.position,
        expression: sourceExpression,
        suggestion: 'Check for missing operands or invalid syntax',
      );
    } finally {
      exitRecursion();
    }
  }

  Expression parseFraction() {
    enterRecursion();
    try {
      consume(TokenType.lparen, "Expected '{' after \\frac");

      // Check if this looks like derivative notation: \frac{d}{dx} or \frac{d^n}{dx^n}
      // We need to check the raw tokens before parsing
      if (_isDerivativeNotation()) {
        return _parseDerivative();
      }

      // Otherwise, parse as a regular fraction
      final numerator = parseExpression();
      consume(TokenType.rparen, "Expected '}' after numerator");

      consume(TokenType.lparen, "Expected '{' after numerator");
      final denominator = parseExpression();
      consume(TokenType.rparen, "Expected '}' after denominator");

      registerNode();
      return BinaryOp(numerator, BinaryOperator.divide, denominator);
    } finally {
      exitRecursion();
    }
  }

  /// Checks if the current fraction represents derivative notation by examining tokens.
  bool _isDerivativeNotation() {
    // Save current position
    final savedPos = position;

    try {
      // Numerator should be 'd' or 'd^n'
      if (!check(TokenType.variable) || current.value != 'd') {
        return false;
      }
      advance(); // consume 'd'

      // Check for optional ^n
      if (check(TokenType.power)) {
        advance(); // consume '^'
        if (check(TokenType.lparen)) {
          advance(); // consume '{'
          if (!check(TokenType.number)) {
            return false;
          }
          advance(); // consume number
          if (!check(TokenType.rparen)) {
            return false;
          }
          advance(); // consume '}'
        } else if (check(TokenType.number)) {
          advance(); // consume number
        }
      }

      // Must have closing brace for numerator
      if (!check(TokenType.rparen)) {
        return false;
      }
      advance(); // consume '}'

      // Must have opening brace for denominator
      if (!check(TokenType.lparen)) {
        return false;
      }
      advance(); // consume '{'

      // Denominator should be 'd' followed by variable
      if (!check(TokenType.variable) || current.value != 'd') {
        return false;
      }
      advance(); // consume 'd'

      // Must have a variable after 'd'
      if (!check(TokenType.variable)) {
        return false;
      }

      // Looks like derivative notation!
      return true;
    } finally {
      // Restore position
      position = savedPos;
    }
  }

  /// Parses a derivative from \frac{d}{dx} or \frac{d^n}{dx^n} notation.
  Expression _parseDerivative() {
    // Parse numerator to get order
    int order = 1;

    // Should be 'd'
    consume(TokenType.variable, "Expected 'd' in derivative numerator");

    // Check for ^n
    if (check(TokenType.power)) {
      advance(); // consume '^'
      if (check(TokenType.lparen)) {
        consume(TokenType.lparen, "Expected '{' after ^");
        if (check(TokenType.number)) {
          order = int.parse(current.value);
          advance();
        }
        consume(TokenType.rparen, "Expected '}' after exponent");
      } else if (check(TokenType.number)) {
        order = int.parse(current.value);
        advance();
      }
    }

    consume(TokenType.rparen, "Expected '}' after derivative numerator");
    consume(TokenType.lparen, "Expected '{' for denominator");

    // Parse denominator to get variable
    consume(TokenType.variable, "Expected 'd' in derivative denominator");

    if (!check(TokenType.variable)) {
      throw ParserException(
        'Expected variable after d in derivative notation',
        position: current.position,
        expression: sourceExpression,
        suggestion: 'Use \\frac{d}{dx} where x is the variable',
      );
    }

    final variable = current.value;
    advance();

    // Check for optional ^n in denominator (should match numerator order)
    if (check(TokenType.power)) {
      advance(); // consume '^'
      if (check(TokenType.lparen)) {
        consume(TokenType.lparen, "Expected '{' after ^");
        if (check(TokenType.number)) {
          // We could validate this matches the numerator order, but we'll ignore for now
          advance();
        }
        consume(TokenType.rparen, "Expected '}' after exponent");
      } else if (check(TokenType.number)) {
        advance();
      }
    }

    consume(TokenType.rparen, "Expected '}' after derivative denominator");

    // Now parse the function body in parentheses
    consume(TokenType.lparen, "Expected '(' after derivative operator");
    final body = parseExpression();
    consume(TokenType.rparen, "Expected ')' after derivative body");

    registerNode();
    return DerivativeExpr(body, variable, order: order);
  }

  Expression parseBinom() {
    consume(TokenType.lparen, "Expected '{' after \\binom");
    final n = parseExpression();
    consume(TokenType.rparen, "Expected '}' after n");

    consume(TokenType.lparen, "Expected '{' after n");
    final k = parseExpression();
    consume(TokenType.rparen, "Expected '}' after k");

    registerNode();
    return FunctionCall.multivar('binom', [n, k]);
  }
}
