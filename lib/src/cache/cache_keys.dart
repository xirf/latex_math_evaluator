import '../ast.dart';

/// A cache key that combines an expression with its variable bindings.
///
/// This allows caching evaluation results for specific (expression, variables)
/// combinations, avoiding re-computation when the same expression is evaluated
/// with the same variable values.
class EvaluationCacheKey {
  final Expression expression;
  final Map<String, double> variables;
  final int _hashCodeCache;

  EvaluationCacheKey(this.expression, this.variables)
      : _hashCodeCache = _computeHashCode(expression, variables);

  static int _computeHashCode(
      Expression expression, Map<String, double> variables) {
    // Create a stable hash from the expression and sorted variable entries
    final sortedEntries = variables.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    var hash = expression.hashCode;
    for (final entry in sortedEntries) {
      hash = hash ^ entry.key.hashCode ^ entry.value.hashCode;
    }
    return hash;
  }

  @override
  int get hashCode => _hashCodeCache;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EvaluationCacheKey) return false;
    if (_hashCodeCache != other._hashCodeCache) return false;
    if (!identical(expression, other.expression) &&
        expression.hashCode != other.expression.hashCode) {
      return false;
    }
    if (variables.length != other.variables.length) return false;
    for (final entry in variables.entries) {
      if (other.variables[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'EvaluationCacheKey(expr: $expression, vars: $variables)';
}

/// A cache key for differentiation results.
///
/// Combines expression, variable, and order to uniquely identify a derivative.
class DifferentiationCacheKey {
  final Expression expression;
  final String variable;
  final int order;
  final int _hashCodeCache;

  DifferentiationCacheKey(this.expression, this.variable, this.order)
      : _hashCodeCache = Object.hash(expression.hashCode, variable, order);

  @override
  int get hashCode => _hashCodeCache;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DifferentiationCacheKey) return false;
    return _hashCodeCache == other._hashCodeCache &&
        order == other.order &&
        variable == other.variable &&
        (identical(expression, other.expression) ||
            expression.hashCode == other.expression.hashCode);
  }

  @override
  String toString() =>
      'DifferentiationCacheKey(d^$order/d$variable, expr: $expression)';
}
