import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

const _partial = 'partial';
const _nabla = 'nabla';
const _d = 'd';

mixin PrimaryParserMixin on BaseParser {
  @override
  Expression parsePrimary() {
    final t = matchToken(TokenType.number);
    if (t != null) {
      registerNode();
      return NumberLiteral(t.numberValue!);
    }

    final vt = matchToken(TokenType.variable);
    if (vt != null) {
      registerNode();
      return Variable(vt.value);
    }

    final ct = matchToken(TokenType.constant);
    if (ct != null) {
      registerNode();
      return Variable(ct.value);
    }

    if (match1(TokenType.infty)) {
      registerNode();
      return Variable('infty');
    }

    if (match1(TokenType.function)) {
      return parseFunctionCall();
    }

    if (match1(TokenType.lim)) {
      return parseLimitExpr();
    }

    if (match1(TokenType.sum)) {
      return parseSumExpr();
    }

    if (match1(TokenType.prod)) {
      return parseProductExpr();
    }

    if (match1(TokenType.int)) {
      return parseIntegralExpr();
    }

    final mt = matchToken(TokenType.iint) ?? matchToken(TokenType.iiint);
    if (mt != null) {
      final order = mt.type == TokenType.iint ? 2 : 3;
      return parseMultiIntegralExpr(order);
    }

    if (match1(TokenType.frac)) {
      return parseFraction();
    }

    if (match1(TokenType.binom)) {
      return parseBinom();
    }

    if (match1(TokenType.partial)) {
      registerNode();
      return Variable(_partial);
    }

    if (match1(TokenType.nabla)) {
      registerNode();
      return Variable(_nabla);
    }

    if (match1(TokenType.text)) {
      final text = parseLatexArgument();
      registerNode();
      return Variable(text);
    }

    // Handle font commands like \mathbf{E}, \mathcal{F}
    final fontToken = matchToken(TokenType.fontCommand);
    if (fontToken != null) {
      final content = parseLatexArgument();
      registerNode();
      // Store font style as prefix for LaTeX round-trip
      return Variable('${fontToken.value}:$content');
    }

    if (match1(TokenType.begin)) {
      return parseMatrix();
    }

    if (match1(TokenType.pipe)) {
      delimiterStack.add('|');
      final expr = parseExpression();
      delimiterStack.removeLast();
      consume(TokenType.pipe, "Expected closing |");
      registerNode();
      return AbsoluteValue(expr);
    }

    final pt = matchToken(TokenType.lparen);
    if (pt != null) {
      final char = pt.value;
      final expr = parseExpression();

      if (!check(TokenType.rparen) && !check(TokenType.rbracket)) {
        throw ParserException(
          "Expected '${char == '(' ? ')' : '}'}'",
          position: current.position,
          expression: sourceExpression,
          suggestion: char == '('
              ? 'Add a closing parenthesis ) to match the opening'
              : char == '{'
                  ? 'Add a closing brace } to match the opening'
                  : 'Add a closing bracket ] to match the opening',
        );
      }
      advance();

      if (char == '{' && check(TokenType.lparen) && current.value == '{') {
        advance();
        final condition = parseExpression();
        consume(TokenType.rparen, "Expected '}' after condition");
        registerNode();
        return ConditionalExpr(expr, condition);
      }

      return expr;
    }

    if (match1(TokenType.sqrt)) {
      registerNode();
      // Check for [n]
      if (match1(TokenType.lbracket)) {
        final n = parseExpression();
        consume(TokenType.rbracket, "Expected ']' after root order");
        final argument = parseLatexArgumentExpr();
        return FunctionCall.multivar('sqrt', [argument, n]);
      }
      final argument = parseLatexArgumentExpr();
      return FunctionCall.multivar('sqrt', [argument]);
    }

    throw ParserException(
      'Expected expression, got: ${isAtEnd ? "EOF" : current.type.name}',
      position: isAtEnd ? null : current.position,
      expression: sourceExpression,
      suggestion: 'Check for missing operands or invalid syntax',
    );
  }

  /// Parses a fraction \frac{numerator}{denominator}.
  Expression parseFraction() {
    // Check if this looks like derivative notation: \frac{d}{dx} or \frac{d^n}{dx^n}
    // We need to check the raw tokens before parsing
    if (_isDerivativeNotation()) {
      return _parseDerivative();
    }

    // Otherwise, parse as a regular fraction
    final numerator = parseLatexArgumentExpr();
    final denominator = parseLatexArgumentExpr();
    registerNode();
    return BinaryOp(numerator, BinaryOperator.divide, denominator);
  }

  /// Checks if the current fraction represents derivative notation by examining tokens.
  bool _isDerivativeNotation() {
    int i = position;
    if (i >= tokens.length) return false;

    // Consume '{'
    if (tokens[i].type != TokenType.lparen) return false;
    i++;
    if (i >= tokens.length) return false;

    bool isPartial = tokens[i].type == TokenType.partial;
    bool isD = tokens[i].type == TokenType.variable && tokens[i].value == _d;
    if (!isPartial && !isD) return false;
    i++;

    if (i < tokens.length && tokens[i].type == TokenType.power) {
      i++;
      if (i < tokens.length && tokens[i].type == TokenType.lparen) {
        i++;
        if (i < tokens.length && tokens[i].type != TokenType.number) {
          return false;
        }
        i++;
        if (i < tokens.length && tokens[i].type != TokenType.rparen) {
          return false;
        }
        i++;
      } else {
        if (i < tokens.length && tokens[i].type != TokenType.number) {
          return false;
        }
        i++;
      }
    }

    if (i >= tokens.length || tokens[i].type != TokenType.rparen) return false;
    i++;
    if (i >= tokens.length || tokens[i].type != TokenType.lparen) return false;
    i++;

    final dType = isPartial ? TokenType.partial : TokenType.variable;
    if (i >= tokens.length || tokens[i].type != dType) return false;
    if (!isPartial && tokens[i].value != _d) {
      return false; // Ensure it's 'd' if not partial
    }
    i++;

    if (i >= tokens.length || tokens[i].type != TokenType.variable) {
      return false;
    }

    return true;
  }

  /// Parses a derivative from \frac{d}{dx} or \frac{d^n}{dx^n} notation.
  Expression _parseDerivative() {
    // Consume the initial '{' for the fraction
    consume(TokenType.lparen, "Expected '{' after \\frac");

    // Parse numerator to get order
    int order = 1;

    // Should be 'd' or '\partial'
    final isPartial = match1(TokenType.partial);
    if (!isPartial) {
      consume(TokenType.variable,
          "Expected 'd' or '\\partial' in derivative numerator");
    }

    // Check for ^n
    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
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
    if (isPartial) {
      consume(
          TokenType.partial, "Expected '\\partial' in derivative denominator");
    } else {
      consume(TokenType.variable, "Expected 'd' in derivative denominator");
    }

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
    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
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
    if (isPartial) {
      return PartialDerivativeExpr(body, variable, order: order);
    }
    return DerivativeExpr(body, variable, order: order);
  }

  Expression parseBinom() {
    final n = parseLatexArgumentExpr();
    final k = parseLatexArgumentExpr();

    registerNode();
    return BinomExpr(n, k);
  }

  /// Parses an integral with optional bounds \int_{lower}^{upper} body dx.
  @override
  Expression parseIntegralExpr() {
    Expression? lower;
    Expression? upper;

    // Parse optional bounds
    if (match1(TokenType.underscore)) {
      if (match1(TokenType.lparen)) {
        lower = parseExpression();
        consume(TokenType.rparen, "Expected '}' after lower bound");
      } else {
        lower = parsePrimary();
      }
    }

    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
        upper = parseExpression();
        consume(TokenType.rparen, "Expected '}' after upper bound");
      } else {
        upper = parsePrimary();
      }
    }

    // Parse expression body
    final body = parseExpression();

    // Parse variable (e.g., dx)
    String variable = 'x';
    final dt = matchToken(TokenType.variable);
    if (dt != null && dt.value == _d) {
      final vt = matchToken(TokenType.variable);
      if (vt != null) {
        variable = vt.value;
      }
    }

    registerNode();
    return IntegralExpr(lower, upper, body, variable);
  }

  Expression parseMultiIntegralExpr(int order) {
    Expression? lower;
    Expression? upper;

    // Parse optional bounds: \iint_{a}^{b}
    if (match1(TokenType.underscore)) {
      if (match1(TokenType.lparen)) {
        lower = parseExpression();
        consume(TokenType.rparen, "Expected '}' after lower bound");
      } else {
        lower = parsePrimary();
      }
    }

    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
        upper = parseExpression();
        consume(TokenType.rparen, "Expected '}' after upper bound");
      } else {
        upper = parsePrimary();
      }
    }

    // Parse body
    final body = parseExpression();

    // Pre-size with defaults: 'x', 'y' for iint and 'x', 'y', 'z' for iiint
    final variables = order == 2 ? <String>['x', 'y'] : <String>['x', 'y', 'z'];

    // Try to parse explicit variables: dx dy ...
    int varIndex = 0;
    while (
        check(TokenType.variable) && current.value == _d && varIndex < order) {
      advance(); // consume 'd'
      if (check(TokenType.variable)) {
        variables[varIndex] = current.value;
        advance();
        varIndex++;
      }
    }

    registerNode();
    return MultiIntegralExpr(order, lower, upper, body, variables);
  }
}
