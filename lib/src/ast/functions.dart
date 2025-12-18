import 'expression.dart';

/// Absolute value expression: |x|
class AbsoluteValue extends Expression {
  final Expression argument;

  const AbsoluteValue(this.argument);

  @override
  String toString() => 'AbsoluteValue($argument)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbsoluteValue &&
          runtimeType == other.runtimeType &&
          argument == other.argument;

  @override
  int get hashCode => argument.hashCode;
}

/// A function call expression (e.g., \log{x}, \ln{x}, \sin{x}).
///
/// For functions with a subscript base like \log_{2}{x}, use [base].
class FunctionCall extends Expression {
  /// The function name (e.g., 'log', 'ln', 'sin').
  final String name;

  /// The function arguments.
  final List<Expression> args;

  /// The function argument (first argument).
  Expression get argument => args[0];

  /// Optional base for functions like \log_{base}{arg}.
  final Expression? base;

  /// Optional parameter for functions like \sqrt[n]{x}.
  final Expression? optionalParam;

  FunctionCall(this.name, Expression argument, {this.base, this.optionalParam}) : args = [argument];

  FunctionCall.multivar(this.name, this.args, {this.base, this.optionalParam});

  @override
  String toString() {
    final parts = ['FunctionCall($name'];
    if (base != null) parts.add('base: $base');
    if (optionalParam != null) parts.add('optionalParam: $optionalParam');
    parts.add('args: $args)');
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCall &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          // Deep equality for list
          args.length == other.args.length &&
          base == other.base &&
          optionalParam == other.optionalParam; // Simplified check

  @override
  int get hashCode => Object.hash(name, Object.hashAll(args), base, optionalParam);
}
