/// Recursive descent parser for LaTeX math expressions.
library;

import 'ast.dart';
import 'exceptions.dart';
import 'token.dart';

/// Parses a list of tokens into an Abstract Syntax Tree.
class Parser {
  final List<Token> _tokens;
  int _position = 0;

  Parser(this._tokens);

  /// Parses the token stream and returns the root expression.
  Expression parse() {
    // Check for function definition pattern: f(x) = ...
    // We currently ignore the definition part and just parse the RHS.
    // Pattern: variable + lparen + variable + rparen + equals
    if (_tokens.length > 4 &&
        _tokens[0].type == TokenType.variable &&
        _tokens[1].type == TokenType.lparen &&
        _tokens[2].type == TokenType.variable &&
        _tokens[3].type == TokenType.rparen &&
        _tokens[4].type == TokenType.equals) {
      _position += 5;
    }

    var expr = _parseExpression();

    // Handle comma-separated constraints: expr, condition
    // Parse as a conditional expression
    if (_match([TokenType.comma])) {
      final condition = _parseExpression();
      expr = ConditionalExpr(expr, condition);
    }

    if (!_isAtEnd && _current.type != TokenType.eof) {
      throw ParserException('Unexpected token: ${_current.value}', _current.position);
    }

    return expr;
  }

  bool get _isAtEnd => _position >= _tokens.length;

  Token get _current => _tokens[_position];

  // Token? get _peek => _position + 1 < _tokens.length ? _tokens[_position + 1] : null;

  Token _advance() {
    if (!_isAtEnd) _position++;
    return _tokens[_position - 1];
  }

  bool _check(TokenType type) => !_isAtEnd && _current.type == type;

  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw ParserException(message, _current.position);
  }

  /// Expression → Comparison
  Expression _parseExpression() {
    return _parseComparison();
  }

  /// Comparison → PlusMinus (('<' | '>' | '<=' | '>=' | '=') PlusMinus)*
  Expression _parseComparison() {
    var left = _parsePlusMinus();
    
    final expressions = <Expression>[left];
    final operators = <ComparisonOperator>[];

    while (_match([
      TokenType.less,
      TokenType.greater,
      TokenType.lessEqual,
      TokenType.greaterEqual,
      TokenType.equals
    ])) {
      final operator = _tokens[_position - 1];
      final right = _parsePlusMinus();

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
          throw ParserException('Unknown comparison operator', operator.position);
      }

      expressions.add(right);
      operators.add(op);
    }

    // If we have multiple comparisons, create a ChainedComparison
    if (operators.length > 1) {
      return ChainedComparison(expressions, operators);
    } else if (operators.length == 1) {
      return Comparison(expressions[0], operators[0], expressions[1]);
    }

    return left;
  }

  /// PlusMinus → Term (('+' | '-') Term)*
  Expression _parsePlusMinus() {
    var left = _parseTerm();

    while (_match([TokenType.plus, TokenType.minus])) {
      final operator = _tokens[_position - 1];
      final right = _parseTerm();

      left = BinaryOp(
        left,
        operator.type == TokenType.plus ? BinaryOperator.add : BinaryOperator.subtract,
        right,
      );
    }

    return left;
  }

  /// Term → Power (('*' | '/' | '\times' | '\div') Power | Implicit)*
  Expression _parseTerm() {
    var left = _parsePower();

    while (true) {
      if (_match([TokenType.multiply, TokenType.divide])) {
        final operator = _tokens[_position - 1];
        final right = _parsePower();

        left = BinaryOp(
          left,
          operator.type == TokenType.multiply
              ? BinaryOperator.multiply
              : BinaryOperator.divide,
          right,
        );
      } else if (_checkImplicitMultiplication()) {
        final right = _parsePower();
        left = BinaryOp(left, BinaryOperator.multiply, right);
      } else {
        break;
      }
    }

    return left;
  }



  bool _checkImplicitMultiplication() {
    if (_isAtEnd) return false;
    
    // Check if the next token is a valid start of a Primary expression
    // Note: We intentionally exclude TokenType.minus to avoid ambiguity with subtraction.
    // Subtraction is handled by _parseExpression.
    // e.g. "x - y" is x minus y, not x times -y.
    return _check(TokenType.number) ||
        _check(TokenType.variable) ||
        _check(TokenType.constant) ||
        _check(TokenType.lparen) || // ( or {
        _check(TokenType.function) ||
        _check(TokenType.lim) ||
        _check(TokenType.sum) ||
        _check(TokenType.prod) ||
        _check(TokenType.frac) ||
        _check(TokenType.infty);
  }

  //// Power → Unary ('^' Unary)* (Right-Associative)
  Expression _parsePower() {
    var left = _parseUnary();

    if (_match([TokenType.power])) {
      // Handle optional braces after ^
      if (_check(TokenType.lparen) && _current.value == '{') {
        _advance(); // consume {
        final right = _parseExpression(); // Recurse here for right-associativity? Usually parseExpression or parsePower depending on precedence desires
        _consume(TokenType.rparen, "Expected '}' after exponent");
        // Recursion happens implicitly if _parseExpression calls back down, 
        // but for strict right-associativity typically: right = _parsePower();
        return BinaryOp(left, BinaryOperator.power, right);
      } else {
        final right = _parsePower(); // Recursive call to self handles a^b^c correctly
        return BinaryOp(left, BinaryOperator.power, right);
      }
    }

    return left;
  }

  /// Unary → '-' Unary | Primary
  Expression _parseUnary() {
    if (_match([TokenType.minus])) {
      final operand = _parseUnary();
      return UnaryOp(UnaryOperator.negate, operand);
    }

    return _parsePrimary();
  }

  /// Primary → NUMBER | VARIABLE | '(' Expression ')' | '{' Expression '}' | Function | Limit
  Expression _parsePrimary() {
    // Number literal
    if (_match([TokenType.number])) {
      final value = double.parse(_tokens[_position - 1].value);
      return NumberLiteral(value);
    }

    // Variable
    if (_match([TokenType.variable])) {
      return Variable(_tokens[_position - 1].value);
    }

    // Mathematical constant (\pi, \tau, etc.)
    if (_match([TokenType.constant])) {
      return Variable(_tokens[_position - 1].value);
    }

    // Infinity
    if (_match([TokenType.infty])) {
      return NumberLiteral(double.infinity);
    }

    // Function call: \log{x}, \ln{x}, \log_{base}{x}
    if (_match([TokenType.function])) {
      return _parseFunctionCall();
    }

    // Limit expression: \lim_{x \to a} expr
    if (_match([TokenType.lim])) {
      return _parseLimitExpr();
    }

    // Sum expression: \sum_{i=start}^{end} expr
    if (_match([TokenType.sum])) {
      return _parseSumExpr();
    }

    // Product expression: \prod_{i=start}^{end} expr
    if (_match([TokenType.prod])) {
      return _parseProductExpr();
    }

    // Fraction: \frac{numerator}{denominator}
    if (_match([TokenType.frac])) {
      return _parseFraction();
    }

    // Absolute value: |expression|
    if (_match([TokenType.pipe])) {
      final expr = _parseExpression();
      _consume(TokenType.pipe, "Expected '|' after absolute value expression");
      return AbsoluteValue(expr);
    }

    // Grouped expression
    if (_match([TokenType.lparen])) {
      final closingChar = _tokens[_position - 1].value == '(' ? ')' : '}';
      final expr = _parseExpression();
      
      if (!_check(TokenType.rparen)) {
        throw ParserException("Expected '$closingChar'", _current.position);
      }
      _advance();
      
      // Check for condition after closing brace: {...}{condition}
      if (closingChar == '}' && _check(TokenType.lparen) && _current.value == '{') {
        _advance(); // consume {
        final condition = _parseExpression();
        _consume(TokenType.rparen, "Expected '}' after condition");
        return ConditionalExpr(expr, condition);
      }
      
      return expr;
    }

    throw ParserException('Expected expression, got: ${_current.value}', _current.position);
  }

  /// Parses function call: \log{x} or \log_{base}{x}
  FunctionCall _parseFunctionCall() {
    final name = _tokens[_position - 1].value;
    Expression? base;

    // Check for subscript base: \log_{2}
    if (_match([TokenType.underscore])) {
      _consume(TokenType.lparen, "Expected '{' after '_'");
      base = _parseExpression();
      _consume(TokenType.rparen, "Expected '}' after base");
    }

    // Parse argument: {x} or (x)
    Expression argument;
    if (_check(TokenType.lparen)) {
      _advance();
      argument = _parseExpression();
      _consume(TokenType.rparen, "Expected closing brace/paren after function argument");
    } else {
      // Allow single token without braces
      argument = _parseUnary();
    }

    return FunctionCall(name, argument, base: base);
  }

  /// Parses limit expression: \lim_{x \to a} expr
  LimitExpr _parseLimitExpr() {
    // Expect _{
    _consume(TokenType.underscore, "Expected '_' after \\lim");
    _consume(TokenType.lparen, "Expected '{' after '_'");

    // Parse variable
    final varToken = _consume(TokenType.variable, "Expected variable in limit");
    final variable = varToken.value;

    // Parse \to
    _consume(TokenType.to, "Expected '\\to' in limit");

    // Parse target
    final target = _parseExpression();

    // Close }
    _consume(TokenType.rparen, "Expected '}' after limit subscript");

    // Parse body expression
    final body = _parseExpression();

    return LimitExpr(variable, target, body);
  }

  /// Parses sum expression: \sum_{i=start}^{end} body
  SumExpr _parseSumExpr() {
    // Parse subscript: _{i=start}
    _consume(TokenType.underscore, "Expected '_' after \\sum");
    _consume(TokenType.lparen, "Expected '{' after '_'");

    final varToken = _consume(TokenType.variable, "Expected variable in sum");
    final variable = varToken.value;

    _consume(TokenType.equals, "Expected '=' after variable");

    final start = _parseExpression();

    _consume(TokenType.rparen, "Expected '}' after start value");

    // Parse superscript: ^{end}
    _consume(TokenType.power, "Expected '^' after sum subscript");
    _consume(TokenType.lparen, "Expected '{' after '^'");

    final end = _parseExpression();

    _consume(TokenType.rparen, "Expected '}' after end value");

    // Parse body
    final body = _parseExpression();

    return SumExpr(variable, start, end, body);
  }

  /// Parses product expression: \prod_{i=start}^{end} body
  ProductExpr _parseProductExpr() {
    // Parse subscript: _{i=start}
    _consume(TokenType.underscore, "Expected '_' after \\prod");
    _consume(TokenType.lparen, "Expected '{' after '_'");

    final varToken = _consume(TokenType.variable, "Expected variable in product");
    final variable = varToken.value;

    _consume(TokenType.equals, "Expected '=' after variable");

    final start = _parseExpression();

    _consume(TokenType.rparen, "Expected '}' after start value");

    // Parse superscript: ^{end}
    _consume(TokenType.power, "Expected '^' after product subscript");
    _consume(TokenType.lparen, "Expected '{' after '^'");

    final end = _parseExpression();

    _consume(TokenType.rparen, "Expected '}' after end value");

    // Parse body
    final body = _parseExpression();

    return ProductExpr(variable, start, end, body);
  }

  /// Parses fraction: \frac{numerator}{denominator}
  Expression _parseFraction() {
    // Parse numerator
    _consume(TokenType.lparen, "Expected '{' after \\frac");
    final numerator = _parseExpression();
    _consume(TokenType.rparen, "Expected '}' after numerator");

    // Parse denominator
    _consume(TokenType.lparen, "Expected '{' after numerator");
    final denominator = _parseExpression();
    _consume(TokenType.rparen, "Expected '}' after denominator");

    return BinaryOp(numerator, BinaryOperator.divide, denominator);
  }
}
