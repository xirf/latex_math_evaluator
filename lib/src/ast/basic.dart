import 'expression.dart';

/// A numeric literal value.
class NumberLiteral extends Expression {
  final double value;

  const NumberLiteral(this.value);

  @override
  String toString() => 'NumberLiteral($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberLiteral &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// A variable reference.
class Variable extends Expression {
  final String name;

  const Variable(this.name);

  @override
  String toString() => 'Variable($name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Variable &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
