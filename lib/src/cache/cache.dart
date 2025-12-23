/// Cache module providing multi-layer caching for the evaluator.
///
/// This module provides:
/// - [CacheConfig] - Configuration for cache behavior
/// - [CacheManager] - Unified cache management
/// - [CacheStatistics] - Performance monitoring
/// - [LruCache] - Least Recently Used cache
/// - [LfuCache] - Least Frequently Used cache
library cache;

export 'cache_config.dart';
export 'cache_keys.dart';
export 'cache_manager.dart';
export 'cache_statistics.dart';
export 'lfu_cache.dart';
export 'lru_cache.dart';
