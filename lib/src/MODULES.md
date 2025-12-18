# Module Organization

This directory contains the modular organization of the LaTeX Math Evaluator library.

## Module Structure

### `core/` - Core Evaluation Pipeline
The fundamental building blocks of expression evaluation:
- **AST**: Abstract syntax tree node definitions
- **Tokenizer**: Lexical analysis of LaTeX strings
- **Parser**: Syntax analysis and AST construction  
- **Evaluator**: Expression evaluation with variable bindings
- **Caching**: Performance optimization through expression caching

```dart
import 'package:latex_math_evaluator/src/core/core.dart';
```

### `features/` - Advanced Mathematical Capabilities
High-level specialized features:
- **Symbolic Algebra**: Simplification and algebraic transformations
- **Extensions**: Custom operation registration system
- **Validation**: Expression validation utilities

```dart
import 'package:latex_math_evaluator/src/features/features.dart';
```

### `data_types/` - Mathematical Data Types
Specialized numeric types beyond standard Dart:
- **Complex**: Complex numbers with real/imaginary parts
- **Matrix**: Linear algebra matrices
- **Vector**: Geometric vectors with operations

```dart
import 'package:latex_math_evaluator/src/data_types/data_types.dart';
```

### `utils/` - Supporting Utilities
Helper modules and constants:
- **Constants**: Mathematical and physical constants
- **Exceptions**: Error types for debugging

```dart
import 'package:latex_math_evaluator/src/utils/utils.dart';
```

## Benefits of Modular Structure

1. **Clarity**: Related functionality grouped together
2. **Selective Imports**: Import only what you need
3. **Maintainability**: Easier to locate and modify code
4. **Testing**: Test modules in isolation
5. **Documentation**: Clear separation of concerns

## Usage

### Full Library (Recommended for most users)
```dart
import 'package:latex_math_evaluator/latex_math_evaluator.dart';
```

### Modular Import (For specialized use cases)
```dart
// Only core evaluation
import 'package:latex_math_evaluator/src/core/core.dart';

// Core + symbolic algebra
import 'package:latex_math_evaluator/src/core/core.dart';
import 'package:latex_math_evaluator/src/features/features.dart';
```

## Migration Note

This modular structure is **additive** - all existing imports continue to work unchanged. The main library export remains the same, ensuring backward compatibility.
