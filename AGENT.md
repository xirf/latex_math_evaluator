# AGENT.md - AI Agent Guide

This document helps AI agents understand and work with the LaTeX Math Evaluator package.

## Package Overview

**Purpose**: Parse and evaluate mathematical expressions written in LaTeX format.

**Architecture**: Three-stage pipeline: Tokenization → Parsing → Evaluation

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
```bash
dart format .
```

### Understanding Evaluation Flow

1. **User calls**: `evaluator.evaluate(r'\sin{x}', {'x': 0})`
2. **Tokenizer**: Converts `\sin{x}` → `[Token(function, 'sin'), Token(lparen), Token(variable, 'x'), Token(rparen)]`
3. **Parser**: Converts tokens → `FunctionCall('sin', Variable('x'))`
4. **Evaluator**: 
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
