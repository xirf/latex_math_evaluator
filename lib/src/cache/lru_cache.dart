import 'dart:collection';

/// A small, dependency-free LRU cache.
///
/// Uses [LinkedHashMap] iteration order as access order by removing and
/// reinserting on reads/writes.
class LruCache<K, V> {
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  int _maxSize;

  /// Creates an LRU cache with a maximum number of entries.
  ///
  /// If [maxSize] is 0, the cache is effectively disabled (all puts are ignored).
  LruCache({required int maxSize}) : _maxSize = maxSize < 0 ? 0 : maxSize;

  int get maxSize => _maxSize;

  set maxSize(int value) {
    _maxSize = value < 0 ? 0 : value;
    _evictIfNeeded();
  }

  int get length => _map.length;

  bool get isEnabled => _maxSize > 0;

  void clear() => _map.clear();

  bool containsKey(K key) => _map.containsKey(key);

  V? get(K key) {
    final value = _map.remove(key);
    if (value == null) return null;
    // Reinsert to mark as most recently used.
    _map[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (!isEnabled) return;
    // Replace while marking MRU.
    _map.remove(key);
    _map[key] = value;
    _evictIfNeeded();
  }

  void _evictIfNeeded() {
    if (!isEnabled) {
      _map.clear();
      return;
    }
    while (_map.length > _maxSize) {
      _map.remove(_map.keys.first);
    }
  }
}
