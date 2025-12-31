# WASM Benchmark

This directory contains the WebAssembly (WasmGC) build of `latex_math_evaluator`.

## Requirements

- **Dart SDK 3.0+** for compilation
- **Browser with WasmGC support**: Chrome 119+, Firefox 120+, Edge 119+

## Building

```bash
cd /path/to/latex_math_evaluator
dart compile wasm benchmark/wasm/wasm_benchmark.dart -o benchmark/wasm/benchmark.wasm
```

This generates:
- `benchmark.wasm` - The optimized WASM module (~134KB)
- `benchmark.mjs` - JavaScript bootstrap for WasmGC

## Running

```bash
cd benchmark/wasm
python3 -m http.server 8080
```

Then open http://localhost:8080 in a WasmGC-compatible browser.

## Results

| Expression       | Native Dart (µs) | WASM (µs) | Overhead |
| ---------------- | ---------------- | --------- | -------- |
| SimpleArithmetic | 0.73             | 2.99      | 4.1x     |
| Trigonometry     | 1.18             | 3.38      | 2.9x     |
| NormalPDF        | 4.50             | 10.77     | 2.4x     |

## Notes

- **WASM is slower than native Dart** due to JIT vs AOT compilation differences
- **WASM is comparable to JavaScript** and faster than Python
- WasmGC support is still maturing; expect improvements over time
