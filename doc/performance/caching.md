# Caching and Performance

This page explains the small LRU cache for parsed expressions and other memoized functions.

## Parsed Expression LRU Cache

- **What**: LRU cache stores parsed ASTs keyed by the expression string.
- **Why**: Re-parsing is some CPU/memory overhead; when the same expression is evaluated repeatedly with different variables, reusing the AST reduces cost.
- **How to configure**:

```dart
// Create evaluator with a cache of up to 256 parsed expressions
final evaluator = LatexMathEvaluator(parsedExpressionCacheSize: 256);

// Disable cache entirely
final noCache = LatexMathEvaluator(parsedExpressionCacheSize: 0);
```

- **Important**: If you add custom commands or extension tokenizers at runtime, clear the cache using `clearParsedExpressionCache()` to avoid stale parses.

## Memoized Math Functions

Several functions that can be expensive when called repeatedly (like `\factorial{n}` or `\fibonacci{n}`) use in-memory memoization to speed up repeated evaluations.

- `\factorial{n}` caches results up to n=170.
- `\fibonacci{n}` caches computed values and will expand the cache as higher indices are requested; extremely large indexes may overflow a `double`.

## Notes and Caveats

- The cache is local to each `LatexMathEvaluator` instance.
- The LRU implementation is minimal and avoids external dependencies; adjust cache size based on available memory and expected expression variety.

```dart
// Example: using the cache and clearing on dynamic changes
final evaluator = LatexMathEvaluator(parsedExpressionCacheSize: 1000);
final parsed = evaluator.parse(r'\sin{x} + \cos{x}');
final value = evaluator.evaluateParsed(parsed, {'x': 0});
// After changing extensions at runtime that affect parsing
evaluator.clearParsedExpressionCache();
```

## Running the micro-benchmark

A small script is provided under `benchmark/expression_cache_benchmark.dart`.

Run it with:

```bash
dart run benchmark/expression_cache_benchmark.dart
```

It will print timings comparing cached vs non-cached evaluation, and an example of fibonacci memoization.

Sample output (your times may vary):

```
Benchmark: repeated evaluate() calls (with and without parsed-expression caching)
Without cache: 19 ms; avg 0.0095 ms/op
With cache: 5 ms; avg 0.0025 ms/op

Benchmark: parsed parse() + evaluateParsed (with cache) vs reparse on each evaluate
evaluateParsed (no parse every time): 3 ms; avg 0.0015 ms/op
evaluate (parse every time): 7 ms; avg 0.0035 ms/op

Fibonacci memoization benchmark:
Fibonacci benchmark (n=40):
  Ran 5 iterations: 3 ms; avg 0.6000 ms/op
Fibonacci benchmark (n=40):
  Ran 100 iterations: 0 ms; avg 0.0000 ms/op
```
