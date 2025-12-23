import '../ast.dart';
import 'cache_config.dart';
import 'cache_keys.dart';
import 'cache_statistics.dart';
import 'lfu_cache.dart';
import 'lru_cache.dart';

/// Manages all cache layers and provides a unified API for caching.
///
/// The cache manager handles four layers:
/// - L1: Parsed expressions (String → Expression)
/// - L2: Evaluation results (Expression + Variables → Result)
/// - L3: Differentiation results (Expression + Variable + Order → Expression)
/// - L4: Sub-expression results (for hierarchical caching)
///
/// Example:
/// ```dart
/// final manager = CacheManager(CacheConfig.highPerformance);
///
/// // Cache a parsed expression
/// manager.putParsedExpression('x^2', expr);
///
/// // Get cached evaluation result
/// final result = manager.getEvaluationResult(expr, {'x': 2.0});
/// ```
class CacheManager {
  final CacheConfig config;

  // L1: Parsed expressions
  late final dynamic _parsedCache;

  // L2: Evaluation results
  late final dynamic _evaluationCache;

  // L3: Differentiation results
  late final dynamic _differentiationCache;

  // L4: Sub-expression results (always LFU since frequency matters)
  late final LfuCache<int, double>? _subExpressionCache;

  // Statistics
  final MultiLayerCacheStatistics _statistics;

  CacheManager(this.config) : _statistics = MultiLayerCacheStatistics() {
    _initializeCaches();
  }

  void _initializeCaches() {
    final collectStats = config.collectStatistics;

    // L1: Parsed expressions
    if (config.parsedExpressionCacheSize > 0) {
      _parsedCache = _createCache<String, Expression>(
        config.parsedExpressionCacheSize,
        collectStats ? _statistics.parsedExpressions : null,
      );
    } else {
      _parsedCache = null;
    }

    // L2: Evaluation results
    if (config.evaluationResultCacheSize > 0) {
      _evaluationCache = _createCache<EvaluationCacheKey, EvaluationResult>(
        config.evaluationResultCacheSize,
        collectStats ? _statistics.evaluationResults : null,
      );
    } else {
      _evaluationCache = null;
    }

    // L3: Differentiation results
    if (config.differentiationCacheSize > 0) {
      _differentiationCache = _createCache<DifferentiationCacheKey, Expression>(
        config.differentiationCacheSize,
        collectStats ? _statistics.differentiation : null,
      );
    } else {
      _differentiationCache = null;
    }

    // L4: Sub-expression cache (always LFU for frequency-based eviction)
    if (config.subExpressionCacheSize > 0) {
      _subExpressionCache = LfuCache<int, double>(
        maxSize: config.subExpressionCacheSize,
        statistics: collectStats ? _statistics.subExpressions : null,
      );
    } else {
      _subExpressionCache = null;
    }
  }

  dynamic _createCache<K, V>(int maxSize, CacheStatistics? stats) {
    switch (config.evictionPolicy) {
      case EvictionPolicy.lru:
        return LruCache<K, V>(
          maxSize: maxSize,
          statistics: stats,
          timeToLive: config.timeToLive,
        );
      case EvictionPolicy.lfu:
        return LfuCache<K, V>(
          maxSize: maxSize,
          statistics: stats,
        );
    }
  }

  // ========== L1: Parsed Expression Cache ==========

  /// Gets a cached parsed expression, or null if not found.
  Expression? getParsedExpression(String expression) {
    if (_parsedCache == null) return null;
    return _parsedCache.get(expression) as Expression?;
  }

  /// Caches a parsed expression.
  void putParsedExpression(String expression, Expression ast) {
    _parsedCache?.put(expression, ast);
  }

  // ========== L2: Evaluation Result Cache ==========

  /// Gets a cached evaluation result, or null if not found.
  EvaluationResult? getEvaluationResult(
      Expression expr, Map<String, double> variables) {
    if (_evaluationCache == null) return null;
    final key = EvaluationCacheKey(expr, variables);
    return _evaluationCache.get(key) as EvaluationResult?;
  }

  /// Caches an evaluation result.
  void putEvaluationResult(
      Expression expr, Map<String, double> variables, EvaluationResult result) {
    if (_evaluationCache == null) return;
    final key = EvaluationCacheKey(expr, variables);
    _evaluationCache.put(key, result);
  }

  // ========== L3: Differentiation Cache ==========

  /// Gets a cached differentiation result, or null if not found.
  Expression? getDifferentiationResult(
      Expression expr, String variable, int order) {
    if (_differentiationCache == null) return null;
    final key = DifferentiationCacheKey(expr, variable, order);
    return _differentiationCache.get(key) as Expression?;
  }

  /// Caches a differentiation result.
  void putDifferentiationResult(
      Expression expr, String variable, int order, Expression derivative) {
    if (_differentiationCache == null) return;
    final key = DifferentiationCacheKey(expr, variable, order);
    _differentiationCache.put(key, derivative);
  }

  // ========== L4: Sub-Expression Cache ==========

  /// Gets a cached sub-expression result, or null if not found.
  double? getSubExpressionResult(int expressionHash) {
    return _subExpressionCache?.get(expressionHash);
  }

  /// Caches a sub-expression result.
  void putSubExpressionResult(int expressionHash, double result) {
    _subExpressionCache?.put(expressionHash, result);
  }

  // ========== Cache Management ==========

  /// Gets combined statistics for all cache layers.
  MultiLayerCacheStatistics get statistics => _statistics;

  /// Clears all caches.
  void clear() {
    _parsedCache?.clear();
    _evaluationCache?.clear();
    _differentiationCache?.clear();
    _subExpressionCache?.clear();
    _statistics.reset();
  }

  /// Clears a specific cache layer.
  void clearLayer(CacheLayer layer) {
    switch (layer) {
      case CacheLayer.parsedExpressions:
        _parsedCache?.clear();
        _statistics.parsedExpressions.reset();
      case CacheLayer.evaluationResults:
        _evaluationCache?.clear();
        _statistics.evaluationResults.reset();
      case CacheLayer.differentiation:
        _differentiationCache?.clear();
        _statistics.differentiation.reset();
      case CacheLayer.subExpressions:
        _subExpressionCache?.clear();
        _statistics.subExpressions.reset();
    }
  }

  /// Warms up the parsed expression cache with common expressions.
  ///
  /// The [parser] function is called for each expression that isn't cached.
  void warmUp(List<String> expressions, Expression Function(String) parser) {
    if (_parsedCache == null) return;
    for (final expr in expressions) {
      if (getParsedExpression(expr) == null) {
        try {
          final ast = parser(expr);
          putParsedExpression(expr, ast);
        } catch (_) {
          // Skip invalid expressions
        }
      }
    }
  }

  /// Whether any caching is enabled.
  bool get isEnabled =>
      _parsedCache != null ||
      _evaluationCache != null ||
      _differentiationCache != null ||
      _subExpressionCache != null;
}

/// Identifies a specific cache layer.
enum CacheLayer {
  parsedExpressions,
  evaluationResults,
  differentiation,
  subExpressions,
}
