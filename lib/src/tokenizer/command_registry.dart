/// Registry for LaTeX commands and their corresponding token types.
library;

import '../token.dart';

/// Centralized registry for LaTeX command to token type mappings.
///
/// This registry handles all standard LaTeX commands recognized by the tokenizer.
/// Custom commands can be registered via [ExtensionRegistry].
class LatexCommandRegistry {
  static final LatexCommandRegistry _instance = LatexCommandRegistry._();

  /// Singleton instance of the command registry.
  static LatexCommandRegistry get instance => _instance;

  final Map<String, TokenType> _commands = {};

  LatexCommandRegistry._() {
    _registerMathFunctions();
    _registerGreekLetters();
    _registerCalculusNotation();
    _registerMatrixCommands();
    _registerLogicAndComparison();
    _registerSpecialCommands();
  }

  /// Registers all standard mathematical functions.
  void _registerMathFunctions() {
    // Trigonometric
    _commands['sin'] = TokenType.function;
    _commands['cos'] = TokenType.function;
    _commands['tan'] = TokenType.function;
    _commands['cot'] = TokenType.function;
    _commands['sec'] = TokenType.function;
    _commands['csc'] = TokenType.function;

    // Inverse trigonometric
    _commands['arcsin'] = TokenType.function;
    _commands['arccos'] = TokenType.function;
    _commands['arctan'] = TokenType.function;
    _commands['arccot'] = TokenType.function;
    _commands['arcsec'] = TokenType.function;
    _commands['arccsc'] = TokenType.function;
    _commands['asin'] = TokenType.function;
    _commands['acos'] = TokenType.function;
    _commands['atan'] = TokenType.function;
    _commands['acot'] = TokenType.function;
    _commands['asec'] = TokenType.function;
    _commands['acsc'] = TokenType.function;

    // Hyperbolic
    _commands['sinh'] = TokenType.function;
    _commands['cosh'] = TokenType.function;
    _commands['tanh'] = TokenType.function;
    _commands['coth'] = TokenType.function;
    _commands['sech'] = TokenType.function;
    _commands['csch'] = TokenType.function;

    // Inverse hyperbolic
    _commands['asinh'] = TokenType.function;
    _commands['acosh'] = TokenType.function;
    _commands['atanh'] = TokenType.function;
    _commands['acoth'] = TokenType.function;
    _commands['asech'] = TokenType.function;
    _commands['acsch'] = TokenType.function;

    // Logarithmic and exponential
    _commands['ln'] = TokenType.function;
    _commands['log'] = TokenType.function;
    _commands['exp'] = TokenType.function;

    // Power and root
    _commands['sqrt'] = TokenType.function;

    // Rounding
    _commands['floor'] = TokenType.function;
    _commands['ceil'] = TokenType.function;
    _commands['round'] = TokenType.function;

    // Other mathematical functions
    _commands['abs'] = TokenType.function;
    _commands['min'] = TokenType.function;
    _commands['max'] = TokenType.function;
    _commands['gcd'] = TokenType.function;
    _commands['lcm'] = TokenType.function;
    _commands['fibonacci'] = TokenType.function;
    _commands['sgn'] = TokenType.function;
    _commands['factorial'] = TokenType.function;

    // Complex number functions
    _commands['Re'] = TokenType.function;
    _commands['Im'] = TokenType.function;
    _commands['overline'] = TokenType.function;
    _commands['conjugate'] = TokenType.function;

    // Vector notation
    _commands['vec'] = TokenType.function;
    _commands['hat'] = TokenType.function;
  }

  /// Registers Greek letters and constants.
  void _registerGreekLetters() {
    _commands['pi'] = TokenType.constant;
    _commands['tau'] = TokenType.constant;
    _commands['phi'] = TokenType.constant;
    _commands['gamma'] = TokenType.constant;
    _commands['Omega'] = TokenType.constant;
    _commands['delta'] = TokenType.constant;
    _commands['theta'] = TokenType.constant;
    _commands['alpha'] = TokenType.constant;
    _commands['beta'] = TokenType.constant;
    _commands['epsilon'] = TokenType.constant;
    _commands['lambda'] = TokenType.constant;
    _commands['mu'] = TokenType.constant;
    _commands['sigma'] = TokenType.constant;
  }

  /// Registers calculus notation commands.
  void _registerCalculusNotation() {
    _commands['lim'] = TokenType.lim;
    _commands['sum'] = TokenType.sum;
    _commands['prod'] = TokenType.prod;
    _commands['int'] = TokenType.int;
    _commands['to'] = TokenType.to;
    _commands['rightarrow'] = TokenType.to;
    _commands['infty'] = TokenType.infty;
    _commands['frac'] = TokenType.frac;
    _commands['binom'] = TokenType.binom;
  }

  /// Registers matrix environment commands.
  void _registerMatrixCommands() {
    _commands['begin'] = TokenType.begin;
    _commands['end'] = TokenType.end;
    _commands['det'] = TokenType.function;
    _commands['trace'] = TokenType.function;
    _commands['tr'] = TokenType.function;
  }

  /// Registers logic and comparison commands.
  void _registerLogicAndComparison() {
    _commands['leq'] = TokenType.lessEqual;
    _commands['geq'] = TokenType.greaterEqual;
    _commands['neq'] = TokenType.notEqual;
  }

  /// Registers special commands (delimiters, spacing, etc.).
  void _registerSpecialCommands() {
    // Delimiter sizing (ignored during parsing)
    _commands['left'] = TokenType.ignored;
    _commands['right'] = TokenType.ignored;
    _commands['big'] = TokenType.ignored;
    _commands['Big'] = TokenType.ignored;
    _commands['bigg'] = TokenType.ignored;
    _commands['Bigg'] = TokenType.ignored;

    // Text mode
    _commands['text'] = TokenType.text;

    // Derivative notation
    _commands['d'] = TokenType.variable;
  }

  /// Gets the token type for a given LaTeX command.
  ///
  /// Returns `null` if the command is not registered.
  TokenType? getTokenType(String command) => _commands[command];

  /// Registers a custom command with its token type.
  ///
  /// This allows extending the tokenizer with new commands at runtime.
  void register(String command, TokenType type) {
    _commands[command] = type;
  }

  /// Checks if a command is registered.
  bool isRegistered(String command) => _commands.containsKey(command);
}
