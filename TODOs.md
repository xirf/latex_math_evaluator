
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

#### 1.2 Improve Error Messages ✅
**Status**: Complete (December 13, 2025)  
**Effort**: Low (2-3 hours)  
**Impact**: High (better debugging)  

**Implementation**:
- Add `suggestion` field to exceptions
- Include expression snippet in error messages
- Add position markers (show where error occurred)

**Files modified**:
- `lib/src/exceptions.dart` - Enhanced exception classes with suggestion, expression, and position markers
- `lib/src/tokenizer.dart` - Better error context with expression snippets and suggestions
- `lib/src/parser.dart` - Better error context in all parser files
- `lib/src/parser/base_parser.dart` - Added sourceExpression field and suggestion helper
- `lib/src/parser/parser.dart` - Enhanced error messages
- `lib/src/parser/primary_parser.dart` - Enhanced error messages
- `lib/src/parser/expression_parser.dart` - Enhanced error messages
- `lib/src/parser/matrix_parser.dart` - Enhanced error messages
- `lib/src/parser/function_parser.dart` - Enhanced error messages
- `lib/src/evaluator.dart` - Added helpful suggestions to all error messages
- `test/validation_test.dart` - Updated to use named parameters
- `example/error_messages_demo.dart` - Created comprehensive demo

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