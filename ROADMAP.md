# LaTeX Math Evaluator - Development Roadmap

> **Vision:** Build a comprehensive, performant, and developer-friendly LaTeX math evaluation library for Dart/Flutter, bridging the gap between symbolic mathematics and practical computation.

This roadmap outlines concrete, actionable tasks organized by priority and timeline. Items are marked with their current status and organized into clear categories.

**Legend:**

- 🔴 High Priority - Core functionality or critical improvements
- 🟡 Medium Priority - Important enhancements
- 🟢 Low Priority - Nice-to-have features
- ✅ Completed | 🚧 In Progress | 📋 Planned | ⏸️ Paused | ⛔ Blocked

---

## 📊 Current State (v0.1.4-nightly)

### ✅ Implemented Features

- ✅ LaTeX tokenization and parsing (fractions, exponents, subscripts, functions)
- ✅ 30+ mathematical functions (trig, hyperbolic, logarithmic, rounding, etc.)
- ✅ Symbolic differentiation with full calculus rule support
- ✅ Symbolic algebra engine (simplification, expansion, factorization)
- ✅ Trigonometric identities (Pythagorean, double-angle formulas)
- ✅ Equation solving (linear and quadratic)
- ✅ Numerical integration (Simpson's Rule)
- ✅ Matrix operations (addition, multiplication, determinant, transpose, inverse)
- ✅ Vector operations (dot product, cross product, magnitude)
- ✅ Summation and product notation
- ✅ Limit evaluation (numerical approximation)
- ✅ Complex number support (basic arithmetic, Re, Im, conjugate)
- ✅ Domain assumptions & tracking (e.g., x > 0 for log simplification)
- ✅ Expression validation with detailed error messages
- ✅ Parse-once-evaluate-many pattern with LRU caching
- ✅ Extensible architecture for custom functions
- ✅ Implicit multiplication support
- ✅ LaTeX regeneration from AST (toLatex() method)
- ✅ 1000+ passing tests

---

## 🎯 Priority 1: Core Mathematical Capabilities

### 🔴 1.1 Symbolic Algebra Engine

**Status:** ✅ 18/12/2025 | **Owner:** @xirf

**Tasks:**

- [x] Implement symbolic simplification
  - [x] Polynomial expansion and factorization
  - [x] Trigonometric identities (Pythagorean, even/odd functions)
  - [x] Double-angle formulas (sin(2x), cos(2x), tan(2x))
  - [x] Logarithm laws (log(ab) = log(a) + log(b))
  - [x] Rational expression simplification
- [x] Expression equivalence testing
- [x] Symbolic equation solving (linear, quadratic)
- [x] Add tests for 50+ symbolic identities (700+ tests passing)
- [x] Document simplification rules and limitations

**Rationale:** Current differentiation has basic simplification, but advanced symbolic manipulation would enable algebraic workflows and make derivative results more readable.

**Success Criteria:**

- [x] Can simplify `(x+1)^2` to `x^2 + 2x + 1`
- [x] Can factor `x^2 - 4` to `(x+2)(x-2)`
- [x] 95%+ test coverage on symbolic operations
- [ ] Performance benchmarks vs SymPy ⏸️ - Paused: not relevant for now

---

### 🔴 1.2 Symbolic Integration

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [x] Implement symbolic indefinite integration
  - [x] Power rule for polynomials
  - [x] Trigonometric integrals
  - [x] Exponential and logarithmic integrals
  - [x] Integration by substitution (basic cases)
- [x] Symbolic definite integration with bounds evaluation
- [x] LaTeX notation: `\int f(x) dx` returns symbolic result
- [ ] Add 100+ integration test cases
- [x] Document supported integration patterns

**Rationale:** Currently only numerical integration via Simpson's Rule. Symbolic integration enables closed-form solutions.

**Success Criteria:**

- [ ] `\int x^n dx` returns `x^(n+1)/(n+1) + C`
- [ ] `\int \sin(x) dx` returns `-\cos(x) + C`
- [ ] Handles definite integrals with variable bounds
- [ ] Benchmark performance on standard integral corpus

---

### 🟡 1.3 Enhanced Complex Number Support

**Status:** 🚧 In Progress | **Owner:** Unassigned

**Tasks:**

- [ ] Full complex arithmetic in all functions
  - [ ] Complex trigonometric functions (sin(a+bi))
  - [ ] Complex exponentials and logarithms
  - [ ] Complex power operations
- [ ] Polar form representation (r∠θ)
- [ ] LaTeX notation: `a + bi` or `r \angle \theta`
- [ ] Complex differentiation and integration
- [ ] Expand complex tests to 100+ cases

**Current State:** Basic complex arithmetic works, but limited function support.

**Success Criteria:**

- [ ] `\sin(1+2i)` evaluates correctly
- [ ] `e^{i\pi}` returns `-1`
- [ ] All trig/log functions work with complex inputs
- [ ] Comprehensive documentation on complex support

---

### 🟡 1.4 Piecewise Functions and Conditionals

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Parse piecewise function syntax

$$
f(x) = \begin{cases}
    x^2 & x < 0 \\
    2x & x \geq 0
  \end{cases}
$$

```latex
f(x) = \begin{cases}
  x^2 & x < 0 \\
  2x & x \geq 0
\end{cases}
```

- [ ] Conditional expression support with domain checking
- [ ] Implement `\cases{}` LaTeX command
- [ ] Add derivative support for piecewise functions
- [ ] Add 50+ test cases

**Rationale:** Essential for real-world mathematical modeling.

**Success Criteria:**

- [ ] Piecewise functions evaluate correctly
- [ ] Domain violations throw clear errors
- [ ] Works with differentiation and integration

---

## 🔧 Priority 2: Parser & Language Support

### 🔴 2.1 Extended LaTeX Notation Support

**Status:** ✅ 19/12/2025 | **Owner:** @xirf

**Tasks:**

- [x] `\left( \right)` - Automatic sizing delimiters
- [x] `\binom{n}{k}` - Binomial coefficient notation
- [x] Multi-line equations with `\begin{align}...\end{align}`
- [x] `\iint`, `\iiint` - Multiple integrals
- [x] `\partial` - Partial derivatives
- [x] `\nabla` - Gradient operator
- [x] LaTeX spacing commands (`\,`, `\;`, `\quad`)
- [x] Greek letter support (α, β, γ as variables)
- [x] Add 200+ parser tests for new constructs

**Rationale:** Users copy expressions from papers/textbooks expecting them to work.

**Success Criteria:**

- [ ] Can parse 90%+ of expressions from standard calculus textbooks
- [ ] Parser test corpus includes real-world LaTeX samples
- [ ] Documentation of all supported LaTeX commands

---

### 🔴 2.2 Improved Error Messages and Recovery

**Status:** 🚧 In Progress | **Owner:** Unassigned

**Tasks:**

- [ ] Context-aware error suggestions
- [ ] Error recovery to continue parsing and find multiple errors
- [ ] Syntax highlighting in error messages
- [ ] Common mistake detection (e.g., `\frac12` vs `\frac{1}{2}`)
- [ ] Did-you-mean suggestions for unknown commands
- [ ] Interactive error fixing in validation results

**Current State:** Good error messages exist but could be more helpful.

**Success Criteria:**

- [ ] 90%+ of common syntax errors have actionable suggestions
- [ ] Can report multiple errors in one pass
- [ ] User testing shows 50%+ reduction in time to fix errors

---

### 🟡 2.3 Unicode and Alternative Notation

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Accept Unicode math symbols: `√`, `∑`, `∏`, `∫`, `≤`, `≥`
- [ ] Support common ASCII alternatives: `sqrt()`, `sum()`, `prod()`
- [ ] Mixed notation mode: LaTeX + Unicode + ASCII
- [ ] Add configuration option for notation style preference
- [ ] Document all supported input formats

**Rationale:** Users input math in many formats; flexibility increases adoption.

**Success Criteria:**

- [ ] `√16` works same as `\sqrt{16}`
- [ ] `∑_{i=1}^{10} i` works same as `\sum_{i=1}^{10} i`
- [ ] All three notations tested and documented

---

## ⚡ Priority 3: Performance & Optimization

### 🟡 3.1 Advanced Caching Strategies

**Status:** 🚧 In Progress | **Owner:** Unassigned

**Tasks:**

- [ ] Persistent cache with disk storage option (for long-running apps)
- [ ] Hierarchical caching (sub-expression results)
- [ ] Cache invalidation strategies
- [ ] Differentiation result caching
- [ ] Benchmark cache hit rates and performance gains
- [ ] Cache size limits and eviction policies
- [ ] Document caching best practices

**Current State:** Basic LRU cache for parsed expressions exists.

**Success Criteria:**

- [ ] At least 10x speedup on repeated evaluations (benchmarked)
- [ ] Cache memory usage configurable and monitored
- [ ] Performance documentation with benchmarks

---

### 🟢 3.2 Parallel Evaluation

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Isolate-based parallel evaluation for bulk operations
- [ ] Vectorized operations for arrays of variable values
- [ ] SIMD optimization exploration (native extensions)
- [ ] Benchmark parallel vs sequential evaluation
- [ ] API for batch evaluation modes

**Rationale:** Server applications may need to evaluate thousands of expressions.

**Success Criteria:**

- [ ] 4x speedup on 4-core systems for bulk evaluations
- [ ] Linear scalability demonstrated
- [ ] Production-ready API for parallel mode

---

### 🟢 3.3 Streaming Parser for Large Expressions

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Incremental tokenization for multi-megabyte LaTeX
- [ ] Memory-efficient AST construction
- [ ] Progressive parsing with partial results
- [ ] Stress tests with 1MB+ expressions

**Rationale:** Research papers may have extremely long equations.

**Success Criteria:**

- [ ] Can parse 10MB expression without OOM
- [ ] Constant memory usage regardless of input size

---

## 🌐 Priority 4: Interoperability & Ecosystem

### 🟡 4.1 AST Export Formats

**Status:** � In Progress | **Owner:** @xomodo

**Tasks:**

- [ ] MathML export (Presentation and Content MathML)
- [ ] JSON AST export for external tooling
- [ ] SymPy-compatible AST format
- [x] LaTeX regeneration from AST (round-trip support)
- [ ] Add import capabilities for each format
- [ ] Comprehensive format conversion tests

**Rationale:** Integration with visualization tools, other CAS systems, web display.

**Success Criteria:**

- [ ] Can export to all 4 formats
- [x] Round-trip parsing: LaTeX → AST → LaTeX → AST identical
- [ ] Examples of integration with MathJax, KaTeX

---

### 🟢 4.2 TypeScript / WASM Port & JS Ecosystem

**Status:** 🟡 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Implement TypeScript-first port (either native TS implementation or thin JS bindings to WASM)
- [ ] Publish `latex-math-evaluator` on NPM with TypeScript definitions
- [ ] Provide Bun & Deno-compatible module
- [ ] WASM build for browser usage (with JS bindings and README examples)
- [ ] Example integrations and benchmarks for React, Vue, Svelte, Bun, Node, and Deno
- [ ] Performance benchmarks vs math.js and algebrite on Node & Browser

**Rationale:** Focusing on the JS/TS ecosystem first gives the largest adoption lift with less maintenance than multiple native bindings.

**Note:** Python and Rust native bindings are deprioritized for now and will be revisited only if community demand justifies the long-term maintenance cost.

---

## 🛠️ Priority 5: Tooling & Developer Experience

### 🟡 5.1 CLI Tool

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Command-line evaluator: `latexmath eval "x^2" --x=3`
- [ ] Validator: `latexmath validate file.tex`
- [ ] Formatter: `latexmath format expression.tex`
- [ ] REPL mode: `latexmath repl`
- [ ] Batch processing from files
- [ ] Install via pub or npm (if web port exists)

**Rationale:** Useful for scripting, CI/CD validation, quick testing.

**Success Criteria:**

- [ ] Published on pub.dev as executable
- [ ] Documentation and examples
- [ ] Used in at least 5 public projects

---

### 🟡 5.2 Web Playground

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Interactive web app for testing expressions
- [ ] AST visualization (tree view)
- [ ] Step-by-step evaluation trace
- [ ] Share expressions via URL
- [ ] Example library with 100+ expressions
- [ ] Dark mode and mobile-friendly UI
- [ ] Deploy to Vercel/Netlify

**Rationale:** Marketing, demos, user onboarding, debugging.

**Success Criteria:**

- [ ] Live at future URL
- [ ] Featured in documentation

---

### 🟢 5.3 Benchmark Suite & Comparison Page

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Comprehensive benchmark suite
- [ ] Automated performance regression testing
- [ ] Public comparison page vs competitors:
  - `math_expressions` (Dart)
  - SymPy (Python)
  - math.js (JavaScript)
  - Algebrite (JavaScript)
- [ ] Publish results with CI/CD updates
- [ ] Include accuracy tests alongside performance

**Rationale:** Demonstrates library strengths and builds credibility.

**Success Criteria:**

- [ ] Benchmarks run on every PR
- [ ] Public dashboard showing trends
- [ ] Referenced in README

---

## 📚 Priority 6: Documentation & Examples

### 🔴 6.1 Comprehensive Documentation

**Status:** 🚧 In Progress | **Owner:** Unassigned

**Tasks:**

- [ ] Complete API reference documentation
- [ ] Advanced cookbook with 50+ recipes
- [ ] Migration guide from `math_expressions`
- [ ] Performance tuning guide
- [ ] Troubleshooting FAQ

**Current State:** Good foundation in `doc/` folder, needs expansion.

**Success Criteria:**

- [ ] 95%+ of public APIs documented
- [ ] Zero unanswered questions in discussions for 30 days

---

### 🟡 6.2 Feature Comparison Matrix

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Create detailed feature matrix comparing to alternatives
- [ ] Include: `math_expressions`, SymPy, math.js, algebrite, mathsteps
- [ ] Cover: parsing, evaluation, symbolic ops, performance, platform support
- [ ] Update quarterly with new features
- [ ] Add to README and documentation site

**Rationale:** Help users decide if this library fits their needs.

**Success Criteria:**

- [ ] Matrix includes 15+ libraries and 30+ features
- [ ] Linked from README introduction
- [ ] Community agrees it's accurate and fair

---

### 🟡 6.3 Real-World Examples & Showcases

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Build 10+ example applications:
  - [ ] Flutter calculator app with LaTeX input
  - [ ] Graphing calculator
  - [ ] Physics simulation with equation parsing
  - [ ] Statistical analysis tool
  - [ ] Educational math tutor app
- [ ] Showcase page listing projects using the library
- [ ] Blog posts demonstrating advanced use cases

**Rationale:** Inspires adoption and demonstrates capabilities.

**Success Criteria:**

- [ ] 10+ example apps in repo
- [ ] Featured projects page with 20+ community projects
- [ ] Case studies from production users

---

## 🏗️ Priority 7: Stability & Release Management

### 🔴 7.1 API Stability & Versioning

**Status:** 🚧 In Progress | **Owner:** Unassigned

**Tasks:**

- [ ] Semver policy documentation
- [ ] Deprecation schedule (min 3 months warning)
- [ ] Breaking change checklist
- [ ] Version compatibility matrix
- [ ] Automated API diff tool in CI
- [x] Publish roadmap for v1.0 stable

**Current State:** Pre-1.0, API changes happening frequently.

**Success Criteria:**

- [ ] v1.0 release with stability guarantee
- [ ] Published compatibility policy
- [ ] No breaking changes without major version bump

---

### 🔴 7.2 Testing & Quality Assurance

**Status:** 🚧 In Progress | **Owner:** Unassigned

**Tasks:**

- [ ] Achieve 95%+ code coverage (currently 80%)
- [x] Property-based testing expansion (fuzz testing)
- [ ] Integration testing with real-world expressions corpus
- [x] Regression test suite (prevent re-introducing bugs)
- [ ] Performance regression tests
- [ ] Coverage reports published with each release

**Current State:** 820+ tests, good coverage but edge cases remain.

**Success Criteria:**

- [ ] 95%+ line coverage
- [ ] 100% of public APIs have tests
- [ ] Zero known critical bugs

---

### 🟡 7.3 CI/CD & Release Automation

**Status:** 📋 Planned | **Owner:** Unassigned

**Tasks:**

- [ ] Automated pub.dev releases from tags
- [ ] Changelog auto-generation
- [ ] Release notes with migration guide
- [ ] Automated performance benchmarks on PR
- [ ] Security scanning (dependency audit)
- [ ] Multi-platform testing (Linux, macOS, Windows, Web, Mobile)

**Rationale:** Professional project management inspires confidence.

**Success Criteria:**

- [ ] Releases require one command
- [ ] All PRs tested on 5+ platforms
- [ ] Security vulnerabilities detected within 24 hours

---

## 🚀 Milestone Releases

### v0.2.0 - Enhanced Symbolic Math (Target: Q1 2026)

- [x] Basic symbolic simplification
- [x] Polynomial expansion and factorization
- [x] Trigonometric identities (Pythagorean, double-angle)
- [x] Logarithm laws and rational simplification
- [x] LaTeX regeneration (toLatex() method)
- [x] Extended LaTeX notation (`\left/\right`, `\binom`, `\iint`, `\partial`, `\nabla`, Greek letters)
- [ ] Enhanced complex number support
- [ ] Improved error messages
- [x] 1000+ tests

### v0.3.0 - Integration & Tooling (Target: Q2 2026)

- [ ] Symbolic integration (basic)
- [ ] Sum-to-product and product-to-sum formulas
- [ ] Half-angle formulas
- [ ] CLI tool release
- [ ] MathML export
- [ ] Web playground launch
- [ ] TypeScript / NPM package release (initial)
- [ ] Documentation overhaul

### v0.4.0 - Performance & Ecosystem (Target: Q3 2026)

- [ ] Advanced caching
- [ ] WASM compilation
- [ ] VS Code extension
- [ ] Piecewise functions
- [ ] 700+ tests

### v1.0.0 - Stable Release (Target: Q4 2026)

- [ ] API stability guarantee
- [ ] 95%+ test coverage
- [ ] Comprehensive documentation
- [ ] Production-ready performance
- [ ] Feature parity with math_expressions + unique features

---

## 📞 How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

**Quick Links:**

- [Open Issues](https://github.com/xirf/latex_math_evaluator/issues)
- [Feature Requests](https://github.com/xirf/latex_math_evaluator/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)
- [Good First Issues](https://github.com/xirf/latex_math_evaluator/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)

**Contact:**

- GitHub Discussions: <https://github.com/xirf/latex_math_evaluator/discussions>
- Issues: <https://github.com/xirf/latex_math_evaluator/issues>

---

**Last Updated:** December 19, 2025
