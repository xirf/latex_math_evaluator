import '../ast.dart';
import '../exceptions.dart';
import '../token.dart';

abstract class BaseParser {
  final List<Token> tokens;
  String? sourceExpression;
  int position = 0;

  BaseParser(this.tokens, [this.sourceExpression]);

  bool get isAtEnd => position >= tokens.length;

  Token get current => tokens[position];

  int _recursionDepth = 0;
  static const int maxRecursionDepth = 500;

  int _nodeCount = 0;
  static const int maxNodeCount = 10000;

  void registerNode() {
    if (++_nodeCount > maxNodeCount) {
      throw ParserException(
        'Expression complexity limit exceeded (too many nodes)',
        position: isAtEnd ? null : current.position,
        expression: sourceExpression,
        suggestion: 'Simplify your expression to reduce its size',
      );
    }
  }

  void enterRecursion() {
    if (++_recursionDepth > maxRecursionDepth) {
      throw ParserException(
        'Maximum nesting depth exceeded',
        position: isAtEnd ? null : current.position,
        expression: sourceExpression,
        suggestion: 'Simplify your expression or check for infinite recursion',
      );
    }
  }

  void exitRecursion() {
    _recursionDepth--;
  }

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

  @pragma('vm:prefer-inline')
  bool match1(TokenType type) {
    if (check(type)) {
      advance();
      return true;
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  Token? matchToken(TokenType type) {
    if (check(type)) {
      final t = current;
      advance();
      return t;
    }
    return null;
  }

  Token consume(TokenType type, String message) {
    if (check(type)) return advance();
    throw ParserException(
      message,
      position: current.position,
      expression: sourceExpression,
      suggestion: _getSuggestion(type, message),
    );
  }

  String? _getSuggestion(TokenType expectedType, String message) {
    if (message.contains("Expected '{'")) {
      return 'Add an opening brace {';
    } else if (message.contains("Expected '}'")) {
      return 'Add a closing brace } or check for matching braces';
    } else if (message.contains("Expected '('")) {
      return 'Add an opening parenthesis (';
    } else if (message.contains("Expected ')'")) {
      return 'Add a closing parenthesis ) or check for matching parentheses';
    }
    return null;
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

  Expression parseLatexArgumentExpr() {
    consume(TokenType.lparen, "Expected '{'");
    final expr = parseExpression();
    consume(TokenType.rparen, "Expected '}'");
    return expr;
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
