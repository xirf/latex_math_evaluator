/// Tokenizer (lexer) for LaTeX math expressions.
library;

import 'exceptions.dart';
import 'extensions.dart';
import 'token.dart';

/// Converts a LaTeX math string into a stream of tokens.
class Tokenizer {
  final String _source;
  final ExtensionRegistry? _extensions;
  int _position = 0;

  Tokenizer(this._source, {ExtensionRegistry? extensions})
      : _extensions = extensions;

  /// Returns all tokens from the source string.
  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd) {
      _skipWhitespace();
      if (_isAtEnd) break;

      final token = _nextToken();
      if (token != null) {
        tokens.add(token);
      }
    }

    tokens.add(Token(type: TokenType.eof, value: '', position: _position));
    return tokens;
  }

  bool get _isAtEnd => _position >= _source.length;

  String get _current => _source[_position];

  String? get _peek =>
      _position + 1 < _source.length ? _source[_position + 1] : null;

  void _skipWhitespace() {
    while (!_isAtEnd && _isWhitespace(_current)) {
      _position++;
    }
  }

  bool _isWhitespace(String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';

  bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;

  bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  Token? _nextToken() {
    final startPos = _position;
    final char = _current;

    // Numbers
    if (_isDigit(char)) {
      return _readNumber();
    }

    // LaTeX commands
    if (char == '\\') {
      return _readLatexCommand();
    }

    // Single character tokens
    _position++;

    switch (char) {
      case '+':
        return Token(type: TokenType.plus, value: '+', position: startPos);
      case '-':
        return Token(type: TokenType.minus, value: '-', position: startPos);
      case '*':
        return Token(type: TokenType.multiply, value: '*', position: startPos);
      case '/':
        return Token(type: TokenType.divide, value: '/', position: startPos);
      case '^':
        return Token(type: TokenType.power, value: '^', position: startPos);
      case '_':
        return Token(
            type: TokenType.underscore, value: '_', position: startPos);
      case '=':
        return Token(type: TokenType.equals, value: '=', position: startPos);
      case '<':
        if (!_isAtEnd && _current == '=') {
          _position++;
          return Token(
              type: TokenType.lessEqual, value: '<=', position: startPos);
        }
        return Token(type: TokenType.less, value: '<', position: startPos);
      case '>':
        if (!_isAtEnd && _current == '=') {
          _position++;
          return Token(
              type: TokenType.greaterEqual, value: '>=', position: startPos);
        }
        return Token(type: TokenType.greater, value: '>', position: startPos);
      case '(':
      case '{':
        return Token(type: TokenType.lparen, value: char, position: startPos);
      case ')':
      case '}':
        return Token(type: TokenType.rparen, value: char, position: startPos);
      case ',':
        return Token(type: TokenType.comma, value: ',', position: startPos);
      case '|':
        return Token(type: TokenType.pipe, value: '|', position: startPos);
      case '&':
        return Token(type: TokenType.ampersand, value: '&', position: startPos);
      default:
        if (_isLetter(char)) {
          return Token(
              type: TokenType.variable, value: char, position: startPos);
        }
        throw TokenizerException('Unexpected character: $char', startPos);
    }
  }

  Token _readNumber() {
    final startPos = _position;
    final buffer = StringBuffer();

    // Integer part
    while (!_isAtEnd && _isDigit(_current)) {
      buffer.write(_current);
      _position++;
    }

    // Decimal part
    if (!_isAtEnd && _current == '.' && _peek != null && _isDigit(_peek!)) {
      buffer.write(_current);
      _position++;

      while (!_isAtEnd && _isDigit(_current)) {
        buffer.write(_current);
        _position++;
      }
    }

    return Token(
        type: TokenType.number, value: buffer.toString(), position: startPos);
  }

  Token _readLatexCommand() {
    final startPos = _position;
    _position++; // Skip the backslash

    if (_isAtEnd) {
      throw TokenizerException('Unexpected end after backslash', startPos);
    }

    // Handle double backslash \\
    if (_current == '\\') {
      _position++;
      return Token(
          type: TokenType.backslash, value: '\\\\', position: startPos);
    }

    final buffer = StringBuffer();
    while (!_isAtEnd && _isLetter(_current)) {
      buffer.write(_current);
      _position++;
    }

    final command = buffer.toString();

    // Built-in commands
    switch (command) {
      case 'times':
      case 'cdot':
        return Token(
            type: TokenType.multiply, value: '\\$command', position: startPos);
      case 'div':
        return Token(
            type: TokenType.divide, value: '\\div', position: startPos);
      // Logarithmic functions
      case 'log':
      case 'ln':
      // Trigonometric functions
      case 'sin':
      case 'cos':
      case 'tan':
      // Inverse trig (normalize aliases)
      case 'asin':
      case 'acos':
      case 'atan':
      // Hyperbolic functions
      case 'sinh':
      case 'cosh':
      case 'tanh':
      // Other functions
      case 'sqrt':
      case 'abs':
      case 'ceil':
      case 'floor':
      case 'round':
      case 'exp':
      case 'sgn':
      case 'factorial':
      case 'min':
      case 'max':
        return Token(
            type: TokenType.function, value: command, position: startPos);
      // Handle arcsin/arccos/arctan aliases
      case 'arcsin':
        return Token(
            type: TokenType.function, value: 'asin', position: startPos);
      case 'arccos':
        return Token(
            type: TokenType.function, value: 'acos', position: startPos);
      case 'arctan':
        return Token(
            type: TokenType.function, value: 'atan', position: startPos);
      // Limit notation
      case 'lim':
        return Token(type: TokenType.lim, value: 'lim', position: startPos);
      // Sum and product
      case 'sum':
        return Token(type: TokenType.sum, value: 'sum', position: startPos);
      case 'prod':
        return Token(type: TokenType.prod, value: 'prod', position: startPos);
      // Matrix environments
      case 'begin':
        return Token(type: TokenType.begin, value: 'begin', position: startPos);
      case 'end':
        return Token(type: TokenType.end, value: 'end', position: startPos);
      case 'to':
      case 'rightarrow':
        return Token(type: TokenType.to, value: '\\to', position: startPos);
      case 'infty':
        return Token(
            type: TokenType.infty, value: '\\infty', position: startPos);
      // Fraction
      case 'frac':
        return Token(type: TokenType.frac, value: 'frac', position: startPos);
      // Mathematical constants
      case 'pi':
      case 'tau':
      case 'phi':
      case 'gamma':
      case 'Omega':
      case 'delta':
        return Token(
            type: TokenType.constant, value: command, position: startPos);
      default:
        // Try extension registry
        if (_extensions != null) {
          final token = _extensions!.tryTokenize(command, startPos);
          if (token != null) {
            return token;
          }
        }
        throw TokenizerException('Unknown LaTeX command: \\$command', startPos);
    }
  }
}
