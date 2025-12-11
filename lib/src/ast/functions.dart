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

  /// The function argument.
  final Expression argument;

  /// Optional base for functions like \log_{base}{arg}.
  final Expression? base;

  const FunctionCall(this.name, this.argument, {this.base});

  @override
  String toString() => base != null
      ? 'FunctionCall($name, base: $base, arg: $argument)'
      : 'FunctionCall($name, $argument)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCall &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          argument == other.argument &&
          base == other.base;

  @override
  int get hashCode => name.hashCode ^ argument.hashCode ^ (base?.hashCode ?? 0);
}
