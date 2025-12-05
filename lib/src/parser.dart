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
    final expr = _parseExpression();

    if (!_isAtEnd && _current.type != TokenType.eof) {
      throw ParserException('Unexpected token: ${_current.value}', _current.position);
    }

    return expr;
  }

  bool get _isAtEnd => _position >= _tokens.length;

  Token get _current => _tokens[_position];

  Token? get _peek => _position + 1 < _tokens.length ? _tokens[_position + 1] : null;

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

  /// Expression → Term (('+' | '-') Term)*
  Expression _parseExpression() {
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

  /// Term → Power (('*' | '/' | '\times' | '\div') Power)*
  Expression _parseTerm() {
    var left = _parsePower();

    while (_match([TokenType.multiply, TokenType.divide])) {
      final operator = _tokens[_position - 1];
      final right = _parsePower();

      left = BinaryOp(
        left,
        operator.type == TokenType.multiply ? BinaryOperator.multiply : BinaryOperator.divide,
        right,
      );
    }

    return left;
  }

  /// Power → Unary ('^' Unary)*
  Expression _parsePower() {
    var left = _parseUnary();

    while (_match([TokenType.power])) {
      // Handle optional braces after ^
      if (_check(TokenType.lparen) && _current.value == '{') {
        _advance(); // consume {
        final right = _parseExpression();
        _consume(TokenType.rparen, "Expected '}' after exponent");
        left = BinaryOp(left, BinaryOperator.power, right);
      } else {
        final right = _parseUnary();
        left = BinaryOp(left, BinaryOperator.power, right);
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

    // Grouped expression
    if (_match([TokenType.lparen])) {
      final closingChar = _tokens[_position - 1].value == '(' ? ')' : '}';
      final expr = _parseExpression();
      
      if (!_check(TokenType.rparen)) {
        throw ParserException("Expected '$closingChar'", _current.position);
      }
      _advance();
      
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
}
