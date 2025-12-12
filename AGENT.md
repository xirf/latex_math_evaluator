# AGENT.md - AI Agent Guide

This document helps AI agents understand and work with the LaTeX Math Evaluator package.

## Package Overview

**Purpose**: Parse and evaluate mathematical expressions written in LaTeX format.

**Architecture**: Four-stage pipeline:
1. **Tokenization** - LaTeX string → Tokens
2. **Parsing** - Tokens → Abstract Syntax Tree (AST)
3. **Variable Injection** - Variables bound to AST during evaluation
4. **Evaluation** - AST + Variables → Result (number or matrix)

## Project Structure

```
lib/src/
├── token.dart              # Token types and definitions
├── exceptions.dart         # Custom exceptions
├── ast.dart                # Abstract Syntax Tree nodes
├── tokenizer.dart          # LaTeX → Tokens
├── parser.dart             # Tokens → AST
├── evaluator.dart          # AST + Variables → Result
├── extensions.dart         # User extension system
├── constants/              # Mathematical constants (organized by category)
│   ├── constant_registry.dart
│   ├── circle.dart         # pi, tau
│   ├── mathematical.dart   # e, phi, gamma, omega, delta, zeta3, G
│   └── common.dart         # sqrt2, sqrt3, ln2, ln10
└── functions/              # Function handlers (organized by category)
    ├── function_registry.dart
    ├── logarithmic.dart    # ln, log
    ├── trigonometric.dart  # sin, cos, tan, asin, acos, atan
    ├── hyperbolic.dart     # sinh, cosh, tanh
    ├── power.dart          # sqrt, exp
    ├── rounding.dart       # ceil, floor, round
    └── other.dart          # abs, sgn, factorial, min, max
```

## Key Design Patterns

### 1. Registry Pattern
- `FunctionRegistry`: Centralized function handler registration
- `ConstantRegistry`: Mathematical constants with fallback behavior
- Both use singleton pattern with `.instance` accessor

### 2. Visitor Pattern (Implicit)
- `Evaluator.evaluate()` recursively evaluates AST nodes
- Each expression type handled separately

### 3. Extension System
- `ExtensionRegistry`: Allows users to add custom LaTeX commands
- Custom evaluators run before built-in evaluation

### 4. Separation of Concerns
- Functions separated by mathematical category (trig, log, etc.)
- Constants separated by type (circle, mathematical, common)
- Each file focused on single responsibility

## Adding New Features

### Adding a New Function

1. **Create handler** in appropriate category file:
   ```dart
   // lib/src/functions/trigonometric.dart
   double handleNewFunc(FunctionCall func, Map<String, double> vars, 
                        double Function(Expression) evaluate) {
     return someCalculation(evaluate(func.argument));
   }
   ```

2. **Register** in `function_registry.dart`:
   ```dart
   register('newfunc', trig.handleNewFunc);
   ```

3. **Add tokenizer support** in `tokenizer.dart`:
   ```dart
   case 'newfunc':
     return Token(type: TokenType.function, value: 'newfunc', position: startPos);
   ```

4. **Add tests** in `test/evaluator_test.dart`

5. **Update docs** in `docs/functions/`

### Adding a New Constant

1. **Add to category file** (e.g., `lib/src/constants/mathematical.dart`):
   ```dart
   const double myConstant = 1.23456;
   ```

2. **Register** in `constant_registry.dart`:
   ```dart
   register('myconst', mathematical.myConstant);
   ```

3. **Add tests** and update `docs/constants.md`

### Adding New AST Node

1. **Define in `ast.dart`**:
   ```dart
   class MyExpr extends Expression {
     final Expression child;
     const MyExpr(this.child);
     // Add toString, ==, hashCode
   }
   ```

2. **Update parser** to create the node
3. **Update evaluator** to handle the node
4. **Add tests**

## Important Conventions

### Naming
- Handler functions: `handleFunctionName` (e.g., `handleSin`)
- Private methods: `_prefixedWithUnderscore`
- Constants: `camelCase` for multi-word (e.g., `gravitationalConstant`)

### Error Handling
- Use custom exceptions: `TokenizerException`, `ParserException`, `EvaluatorException`
- Include position information when possible
- Provide clear error messages

### Testing
- All features must have tests
- Use descriptive test names
- Group related tests with `group()`
- Current: 122 tests, all passing

### Commit Messages
Follow Conventional Commits:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation
- `test:` - Tests
- `refactor:` - Code refactoring
- `chore:` - Maintenance

## Common Tasks

### Running Tests
```bash
dart test                    # All tests
dart test test/evaluator_test.dart  # Specific file
```

### Code Formatting
### Understanding Evaluation Flow

1. **User calls**: `evaluator.evaluate(r'\sin{x}', {'x': 0})`

2. **Tokenization Phase**: 
   - Input: `\sin{x}`
   - Output: `[Token(function, 'sin'), Token(lbrace), Token(variable, 'x'), Token(rbrace)]`
   - Creates token stream from LaTeX string

3. **Parsing Phase**: 
   - Input: Token stream
   - Output: AST → `FunctionCall('sin', Variable('x'))`
   - Builds Abstract Syntax Tree

4. **Variable Injection & Evaluation Phase**: 
   - Input: AST + `{'x': 0}`
   - Process:
     - Looks up 'sin' in `FunctionRegistry`
     - Calls `handleSin(FunctionCall, {'x': 0}, evaluateCallback)`
     - Evaluates `Variable('x')` → looks up in variables map → 0
     - Computes `math.sin(0)`
   - Output: `0.0`

**Key Insight**: Variables are NOT injected into the AST structure. Instead, they're passed alongside the AST during evaluation, allowing the same parsed AST to be reused with different variable values.
   - Looks up 'sin' in `FunctionRegistry`
   - Calls `handleSin(FunctionCall, {'x': 0}, evaluateCallback)`
   - Evaluates `Variable('x')` → looks up in variables → 0
   - Returns `math.sin(0)` → 0.0

## Variable Resolution

Variables are resolved in this order:
1. User-provided variables (from function call)
2. Built-in constants (from `ConstantRegistry`)
3. Error if not found

This allows users to override constants like `e` or `pi`.

## Extension Points

Users can extend via `ExtensionRegistry`:
- **Custom commands**: Register new LaTeX commands
- **Custom evaluators**: Add evaluation logic for custom expressions
- Extensions run before built-in logic

## File Organization Philosophy

- **Flat when simple**: Core files (token, ast, parser) are single files
- **Grouped when complex**: Functions and constants split by category
- **Registry pattern**: Central registry imports and coordinates category files
- **Easy navigation**: Related code grouped together, clear naming

## Testing Philosophy

- **Comprehensive**: Test all functions, edge cases, error conditions
- **Organized**: Group tests by feature/category
- **Clear**: Descriptive names, comments for complex cases
- **Fast**: Pure Dart, no external dependencies

## Documentation

- **README.md**: Quick start, feature overview
- **docs/**: Detailed guides organized by topic
- **example/**: Working code examples
- **Inline docs**: Public APIs have doc comments

## Post-Implementation Checklist

After successfully implementing ANY new feature, follow these steps in order:

### 1. Update Tests ✅
**Location**: `test/`
- Add comprehensive tests for the new feature
- Include edge cases and error conditions
- Run `dart test` to ensure all tests pass
- Aim for high code coverage

**Example**:
```dart
// test/evaluator_test.dart or create new test file
group('New Feature', () {
  test('basic functionality', () {
    expect(evaluator.evaluate(r'\newfeature{5}'), equals(expectedResult));
  });
  
  test('edge case: zero', () {
    expect(evaluator.evaluate(r'\newfeature{0}'), equals(0));
  });
  
  test('error handling', () {
    expect(
      () => evaluator.evaluate(r'\newfeature{invalid}'),
      throwsA(isA<EvaluatorException>()),
    );
  });
});
```

### 2. Update CHANGELOG.md 📝
**Location**: `CHANGELOG.md`
**Format**: Follow existing structure

Add entry at the TOP under current version section (or create new version):

```markdown
## [Version] - YYYY-MM-DD (or ## Version Nightly)

### Added
- Added support for **New Feature**: `\newcommand{args}` - brief description
- Added `functionName()` for specific use case

### Changed
- Modified `existingFunction()` to support new parameter
- Improved error messages for feature X

### Fixed
- Fixed bug where feature Y failed on edge case Z

### Breaking Changes (if any)
- **BREAKING**: Changed return type of `method()` from X to Y
```

**Categories**:
- **Added**: New features, functions, commands
- **Changed**: Modifications to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Deleted features
- **Fixed**: Bug fixes
- **Security**: Security patches
- **Breaking Changes**: API changes requiring user action

### 3. Update Documentation 📚

#### A. Update README.md (if user-facing feature)
**Location**: `README.md`

Add to appropriate section:
- **Supported Functions table**: If new function
- **Quick Start examples**: If fundamental feature
- **Feature list**: If major capability

```markdown
## Supported Functions

| Category | Functions |
|----------|-----------|
| **New Category** | `\newfunc`, `\anotherfunc` |

## Examples

// Add brief, clear example
evaluator.evaluate(r'\newfunc{5}');  // expectedResult
```

#### B. Create/Update Detailed Documentation
**Location**: `doc/` (organized by category)

Create new file or update existing:
- `doc/functions/` - For function documentation
- `doc/notation/` - For notation features
- `doc/` - For general features

**Template** (`doc/functions/newcategory.md`):
```markdown
# New Category Functions

## Overview
Brief description of this category.

## Functions

### `\functionname{arg}`

**Description**: What it does

**Syntax**: 
\`\`\`latex
\functionname{argument}
\functionname_{subscript}{argument}  // if applicable
\`\`\`

**Parameters**:
- `argument`: Description (type: number/expression)

**Returns**: Description of return value

**Examples**:
\`\`\`dart
// Basic usage
evaluator.evaluate(r'\functionname{5}');  // Result

// With variables
evaluator.evaluate(r'\functionname{x}', {'x': 10});  // Result

// Nested
evaluator.evaluate(r'\functionname{\sin{0}}');  // Result
\`\`\`

**Mathematical Definition**:
$$
f(x) = \text{mathematical notation}
$$

**Edge Cases**:
- Zero: `\functionname{0}` returns X
- Negative: `\functionname{-5}` returns Y
- Undefined: Throws `EvaluatorException` when...

**Notes**:
- Implementation uses [algorithm/approach]
- Computational complexity: O(n)
- Related functions: `\otherfunc`, `\relatedfunc`
```

#### C. Update Function/Constant READMEs
**Location**: `doc/functions/README.md` or `doc/constants.md`

Add link to new documentation:
```markdown
## Function Categories

- [New Category](newcategory.md) - Brief description
```

### 4. Update Examples 💡
**Location**: `example/`

Add practical example demonstrating the feature:

**Option A**: Add to existing example file if related
```dart
// example/advanced_math_demo.dart
void demonstrateNewFeature() {
  print('=== New Feature Demo ===');
  
  final evaluator = LatexMathEvaluator();
  
  // Basic example
  final result1 = evaluator.evaluate(r'\newfeature{5}');
  print('Basic: $result1');
  
  // Practical use case
  final result2 = evaluator.evaluate(r'\newfeature{x^2}', {'x': 3});
  print('With expression: $result2');
}
```

**Option B**: Create new example file for major features
```dart
// example/newfeature_demo.dart
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

/// Demonstrates the new feature functionality
void main() {
  final evaluator = LatexMathEvaluator();
  
  print('=== New Feature Examples ===\n');
  
  // Example 1: Basic usage
  print('1. Basic Usage:');
  print(evaluator.evaluate(r'\newfeature{5}'));
  
  // Example 2: Real-world application
  print('\n2. Real-World Use Case:');
  // Demonstrate practical scenario
  
  // Example 3: Edge cases
  print('\n3. Edge Cases:');
  // Show important edge cases
}
```

**Update example/main.dart** to reference new example:
```dart
// Add import if new file created
import 'newfeature_demo.dart' as newfeature;

void main() {
  // ... existing examples ...
  newfeature.main();  // Add call to new example
}
```

### 5. Update API Documentation (dartdoc) 📖

Add comprehensive dartdoc comments to all public APIs:

```dart
/// Brief one-line description.
///
/// Detailed description explaining:
/// - What the function/class does
/// - When to use it
/// - Important behavior notes
///
/// **Parameters**:
/// - [param1]: Description
/// - [param2]: Description
///
/// **Returns**: Description of return value
///
/// **Throws**:
/// - [ExceptionType]: When this occurs
///
/// **Example**:
/// ```dart
/// final result = functionName(arg1, arg2);
/// print(result); // expectedOutput
/// ```
///
/// See also:
/// - [RelatedFunction]
/// - [RelatedClass]
double functionName(double param1, String param2) {
  // implementation
}
```

### 6. Version Update Strategy 🔢

**For Nightly/Development**:
- Keep version as `X.Y.Z-nightly` in `pubspec.yaml`
- Add changes under `## X.Y.Z Nightly` in CHANGELOG

**For Release**:
1. Update `pubspec.yaml` version: `X.Y.Z-nightly` → `X.Y.Z`
2. Update CHANGELOG: `## X.Y.Z Nightly` → `## X.Y.Z - YYYY-MM-DD`
3. Create git tag: `git tag vX.Y.Z`
4. Publish: `dart pub publish`

**Semantic Versioning**:
- **Patch** (0.0.X): Bug fixes, documentation
- **Minor** (0.X.0): New features, backward compatible
- **Major** (X.0.0): Breaking changes

### 7. Final Verification ✓

Before marking task complete:
- [ ] All tests pass: `dart test`
- [ ] Code formatted: `dart format .`
- [ ] No analysis issues: `dart analyze`
- [ ] CHANGELOG.md updated
- [ ] Documentation added/updated
- [ ] Examples demonstrate feature
- [ ] README.md updated (if user-facing)
- [ ] dartdoc comments added
- [ ] Git committed with conventional commit message

**Conventional Commit Message Format**:
```
type(scope): brief description

Detailed explanation if needed

BREAKING CHANGE: description (if applicable)
```

**Types**: feat, fix, docs, test, refactor, perf, chore

**Example**:
```bash
git add .
git commit -m "feat(functions): add complex number support

- Add Complex class for complex arithmetic
- Add support for i notation in expressions
- Add conjugate, real, imag functions

Closes #123"
```

## Quick Reference: File Locations

| What to Update | Where | When |
|----------------|-------|------|
| Tests | `test/*.dart` | Always (first step) |
| Changelog | `CHANGELOG.md` | Always |
| Function docs | `doc/functions/*.md` | New functions |
| Notation docs | `doc/notation/*.md` | New notation |
| General docs | `doc/*.md` | General features |
| Examples | `example/*.dart` | Always (demonstrate usage) |
| README | `README.md` | User-facing features |
| API docs | Inline dartdoc | All public APIs |
| Version | `pubspec.yaml` | Release time |

## Priority Order for Documentation

1. **Critical** (Must have): Tests, CHANGELOG, basic example
2. **Important** (Should have): Detailed docs, dartdoc comments
3. **Nice to have**: Advanced examples, edge case documentation

## Templates Location

All templates above can be copied and adapted for specific features.
Key principle: **Make it easy for users to understand and use the feature.**

---

# Improvement Roadmap

This section tracks planned improvements and their implementation status.

## Implementation Strategy

### Phase 1: Quick Wins (High Impact, Low Effort)
These can be implemented quickly and provide immediate value.

#### 1.1 Add Validation API ✅
**Status**: Complete (December 13, 2025)  
**Effort**: Low (1-2 hours)  
**Impact**: High (improves DX)  

**Implementation**:
- Add `isValid(String expression)` method
- Add `validate(String expression)` with detailed error info
- Returns validation result without evaluation

**Files modified**:
- `lib/src/exceptions.dart` - Added ValidationResult class
- `lib/latex_math_evaluator.dart` - Added public API methods
- `test/validation_test.dart` - Added 28 comprehensive tests
- `doc/validation.md` - Complete documentation
- `example/validation_demo.dart` - Practical examples
- `README.md` - Added to features and quick start
- `CHANGELOG.md` - Documented changes

#### 1.2 Improve Error Messages ⏳
**Status**: Not Started  
**Effort**: Low (2-3 hours)  
**Impact**: High (better debugging)  

**Implementation**:
- Add `suggestion` field to exceptions
- Include expression snippet in error messages
- Add position markers (show where error occurred)

**Files to modify**:
- `lib/src/exceptions.dart` - Enhance exception classes
- `lib/src/tokenizer.dart` - Better error context
- `lib/src/parser.dart` - Better error context
- `lib/src/evaluator.dart` - Better error context
- `test/*_test.dart` - Update error tests

#### 1.3 Add Type-Safe Result Class ⏳
**Status**: Not Started  
**Effort**: Medium (3-4 hours)  
**Impact**: Medium (better type safety)  

**Implementation**:
- Create sealed `EvaluationResult` class
- `NumericResult(double)` and `MatrixResult(Matrix)`
- Migrate `evaluate()` return type from `dynamic`

**Files to modify**:
- `lib/src/ast.dart` - Add result classes
- `lib/src/evaluator.dart` - Return typed results
- `lib/latex_math_evaluator.dart` - Update API
- All tests - Update expectations

#### 1.4 Add dartdoc Comments ⏳
**Status**: Not Started  
**Effort**: Medium (4-5 hours)  
**Impact**: High (professional documentation)  

**Implementation**:
- Add comprehensive dartdoc to all public APIs
- Include examples in doc comments
- Document all parameters and return values

**Files to modify**:
- All `lib/src/*.dart` files
- Focus on public APIs first

### Phase 2: New Features (Medium Effort)

#### 2.1 Complex Number Support ⏳
**Status**: Not Started  
**Effort**: High (6-8 hours)  
**Impact**: High (new capability)  

**Implementation**:
- Create `Complex` class
- Support `i` notation
- Add `\text{Re}`, `\text{Im}`, `\overline{z}` (conjugate)
- Complex arithmetic operations

**Files to create/modify**:
- `lib/src/complex.dart` - New Complex class
- `lib/src/tokenizer.dart` - Recognize `i`
- `lib/src/parser.dart` - Parse complex expressions
- `lib/src/evaluator.dart` - Evaluate complex operations
- `lib/src/functions/complex.dart` - Complex functions
- `test/complex_test.dart` - New test file
- `doc/functions/complex.md` - Documentation
- `example/complex_demo.dart` - Examples

#### 2.2 Statistical Functions ⏳
**Status**: Not Started  
**Effort**: Medium (4-5 hours)  
**Impact**: Medium (useful for data analysis)  

**Implementation**:
- `\text{mean}(list)`, `\text{median}(list)`
- `\text{std}(list)`, `\text{var}(list)`
- Support for list notation: `[1, 2, 3, 4, 5]`

**Files to create/modify**:
- `lib/src/ast.dart` - Add `ListExpr`
- `lib/src/tokenizer.dart` - Parse `[` and `]`
- `lib/src/parser.dart` - Parse lists
- `lib/src/functions/statistical.dart` - New functions
- `lib/src/functions/function_registry.dart` - Register
- `test/statistical_test.dart` - Tests
- `doc/functions/statistical.md` - Documentation

#### 2.3 Vector Operations ⏳
**Status**: Not Started  
**Effort**: Medium (4-5 hours)  
**Impact**: Medium (extends matrix functionality)  

**Implementation**:
- Dot product: `\vec{a} \cdot \vec{b}`
- Cross product: `\vec{a} \times \vec{b}`
- Magnitude: `|\vec{a}|`
- Unit vector: `\hat{a}`

**Files to create/modify**:
- `lib/src/vector.dart` - Vector class
- `lib/src/parser.dart` - Parse vector notation
- `lib/src/evaluator.dart` - Vector operations
- `lib/src/functions/vector.dart` - Vector functions
- `test/vector_test.dart` - Tests
- `doc/notation/vectors.md` - Documentation

### Phase 3: Performance & Quality (Ongoing)

#### 3.1 Optimize Matrix Operations ⏳
**Status**: Not Started  
**Effort**: Medium (5-6 hours)  
**Impact**: High (performance for large matrices)  

**Implementation**:
- LU decomposition for determinant (matrices > 3x3)
- Cache matrix operations
- Benchmark suite

**Files to modify**:
- `lib/src/matrix.dart` - Optimize algorithms
- `benchmark/matrix_benchmark.dart` - New benchmark
- `test/matrix_test.dart` - Add large matrix tests

#### 3.2 Add Expression Caching ⏳
**Status**: Not Started  
**Effort**: Medium (4-5 hours)  
**Impact**: Medium (performance for repeated evaluations)  

**Implementation**:
- Cache parsed expressions
- Memoize expensive calculations (factorial, fibonacci)
- LRU cache with configurable size

**Files to create/modify**:
- `lib/src/cache.dart` - Cache implementation
- `lib/src/evaluator.dart` - Use caching
- `lib/latex_math_evaluator.dart` - Cache configuration
- `test/cache_test.dart` - Cache tests

#### 3.3 Fuzzing & Property-Based Testing ⏳
**Status**: Not Started  
**Effort**: Medium (4-6 hours)  
**Impact**: High (find edge cases)  

**Implementation**:
- Random expression generation
- Property-based tests (commutativity, associativity)
- Fuzzing for crash detection

**Files to create**:
- `test/fuzzing_test.dart` - Fuzzing tests
- `test/property_test.dart` - Property tests

### Phase 4: Advanced Features (High Effort)

#### 4.1 Symbolic Differentiation ⏳
**Status**: Not Started  
**Effort**: Very High (10-15 hours)  
**Impact**: High (powerful new capability)  

**Implementation**:
- `\frac{d}{dx}(expression)` syntax
- Derivative rules (power, product, chain, etc.)
- Simplification engine
- Return symbolic expression or evaluate at point

**Major undertaking**: Requires symbolic math engine

#### 4.2 Unit Support ⏳
**Status**: Not Started  
**Effort**: High (8-10 hours)  
**Impact**: Medium (useful for physics/engineering)  

**Implementation**:
- Parse units: `5\text{ m/s}`
- Unit conversion
- Dimensional analysis

### Phase 5: Ecosystem & Publishing

#### 5.1 Publish Stable Release ⏳
**Status**: Not Started  
**Effort**: Low (1-2 hours)  
**Impact**: High (discoverability)  

**Tasks**:
- Update version to `0.2.0` or `1.0.0`
- Final documentation review
- Publish to pub.dev
- Create GitHub release

#### 5.2 CI/CD Pipeline ⏳
**Status**: Not Started  
**Effort**: Medium (3-4 hours)  
**Impact**: High (code quality)  

**Implementation**:
- GitHub Actions for tests
- Code coverage reporting (Codecov)
- Automated pub.dev publishing
- Dart analyzer in CI

**Files to create**:
- `.github/workflows/test.yml`
- `.github/workflows/publish.yml`
- `codecov.yml`

#### 5.3 Platform Testing ⏳
**Status**: Not Started  
**Effort**: Medium (2-3 hours)  
**Impact**: Medium (compatibility assurance)  

**Tasks**:
- Test on web platform
- Test on mobile (Flutter)
- Test on desktop
- Document platform support

## Implementation Guidelines

### Before Starting Any Task:
1. **Understand the scope** - Read this guide thoroughly
2. **Check dependencies** - Does this require other features first?
3. **Review existing code** - Understand current implementation
4. **Plan the approach** - Think through architecture

### During Implementation:
1. **Write tests first** (TDD approach recommended)
2. **Implement incrementally** - Small, testable chunks
3. **Run tests frequently** - `dart test` after each change
4. **Format code** - `dart format .` regularly
5. **Keep commits small** - Easier to review and revert

### After Implementation:
**Follow the Post-Implementation Checklist above** ✅

### Task Status Indicators:
- ⏳ Not Started
- 🔄 In Progress  
- ✅ Complete
- 🚫 Blocked
- ⏸️ Paused

## Current Focus

**Next Task**: To be determined based on user priorities

**Recommended Starting Point**: Phase 1.1 (Validation API) - Quick win with high impact

---

## Notes for AI Agents

When implementing improvements:
1. **One task at a time** - Complete entire workflow including docs
2. **Follow post-implementation checklist** - Don't skip steps
3. **Update this roadmap** - Change status indicators
4. **Commit with conventional commits** - Maintain clean history
5. **Ask for clarification** - If requirements unclear

**Remember**: Quality over speed. A well-documented, tested feature is worth more than quick, undocumented code.
