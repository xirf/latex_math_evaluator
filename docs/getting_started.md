# Getting Started

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  latex_math_evaluator:
    path: path/to/latex_math_evaluator
```

Then run:
```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  final evaluator = LatexMathEvaluator();
  
  // Simple expression
  print(evaluator.evaluate(r'2 + 3'));  // 5.0
  
  // With variables
  print(evaluator.evaluate(r'x^{2}', {'x': 4}));  // 16.0
  
  // LaTeX operators
  print(evaluator.evaluate(r'6 \div 2'));  // 3.0
  print(evaluator.evaluate(r'3 \times 4'));  // 12.0
}
```

## Understanding the Pipeline

The evaluator works in 3 stages:

1. **Tokenization**: LaTeX string → Tokens
2. **Parsing**: Tokens → Abstract Syntax Tree (AST)
3. **Evaluation**: AST + Variables → Result

```dart
// Manual pipeline (for advanced use)
final tokens = Tokenizer(r'\sin{x}').tokenize();
final ast = Parser(tokens).parse();
final result = Evaluator().evaluate(ast, {'x': 0});
```

## Error Handling

```dart
try {
  evaluator.evaluate(r'\log{0}');
} on EvaluatorException catch (e) {
  print('Math error: $e');
} on ParserException catch (e) {
  print('Syntax error: $e');
} on TokenizerException catch (e) {
  print('Invalid character: $e');
}
```

## Next Steps

- [Functions](functions/README.md) - Available mathematical functions
- [Notation](notation/README.md) - Sum, product, and limit notation
- [Constants](constants.md) - Built-in mathematical constants
- [Extensions](extensions.md) - Adding custom functions
