/// WASM benchmark entry point for latex_math_evaluator
///
/// Compile with: dart compile wasm benchmark/wasm/wasm_benchmark.dart -o benchmark/wasm/benchmark.wasm
///
/// Note: WASM output currently requires a browser environment with WasmGC support.
library;

import 'dart:js_interop';

import 'package:latex_math_evaluator/latex_math_evaluator.dart';

@JS('console.log')
external void consoleLog(String message);

/// Run all benchmarks and return results as JSON
@JS()
external void runBenchmarks();

void main() {
  consoleLog('WASM Benchmark - latex_math_evaluator');
  consoleLog('=====================================');

  final evaluator = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);

  // Benchmark expressions
  final expressions = [
    ('SimpleArithmetic', r'1 + 2 + 3 + 4 + 5', <String, double>{}),
    ('Multiplication', r'x * y * z', {'x': 2.0, 'y': 3.0, 'z': 4.0}),
    ('Trigonometry', r'\sin(x) + \cos(x)', {'x': 0.5}),
    ('PowerAndSqrt', r'\sqrt{x^2 + y^2}', {'x': 3.0, 'y': 4.0}),
    ('Polynomial', r'x^3 + 2*x^2 - 5*x + 7', {'x': 2.0}),
    ('NestedFunctions', r'\sin(\cos(x))', {'x': 1.0}),
    (
      'NormalPDF',
      r'\frac{1}{\sigma \sqrt{2\pi}} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}',
      {'x': 0.0, 'mu': 0.0, 'sigma': 1.0}
    ),
  ];

  const iterations = 10000;

  consoleLog('\nRunning $iterations iterations per expression...\n');

  for (final (name, latex, vars) in expressions) {
    // Warmup
    for (var i = 0; i < 100; i++) {
      evaluator.evaluate(latex, vars);
    }

    // Benchmark
    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      evaluator.evaluate(latex, vars);
    }
    sw.stop();

    final avgUs = sw.elapsedMicroseconds / iterations;
    consoleLog('$name: ${avgUs.toStringAsFixed(2)} µs/op');
  }

  consoleLog('\n=====================================');
  consoleLog('WASM Benchmark Complete');
}
