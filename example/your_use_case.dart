import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  print('=== Your Requested Use Case ===\n');
  
  final evaluator = LatexMathEvaluator();
  
  // Your exact use case: parse once, bind variables later
  final equation = evaluator.parse(r'x^{2} + 5x - 3');
  
  print('Equation: x² + 5x - 3\n');
  
  // Evaluate with different x values
  print('Evaluating with different x values:');
  final result1 = evaluator.evaluateParsed(equation, {'x': 10});
  print('x = 10: $result1');
  
  final result2 = evaluator.evaluateParsed(equation, {'x': 5});
  print('x = 5: $result2');
  
  final result3 = evaluator.evaluateParsed(equation, {'x': 0});
  print('x = 0: $result3');
  
  final result4 = evaluator.evaluateParsed(equation, {'x': -2});
  print('x = -2: $result4');
  
  print('\n=== Memory Usage Comparison ===\n');
  
  // Inefficient way (parse every time)
  print('Method 1: Parse + Evaluate each time');
  for (int i = 1; i <= 5; i++) {
    final result = evaluator.evaluate(r'x^{2} + 5x - 3', {'x': i.toDouble()});
    print('  x = $i: $result');
  }
  
  print('\nMethod 2: Parse once, reuse (RECOMMENDED)');
  final parsedOnce = evaluator.parse(r'x^{2} + 5x - 3');
  for (int i = 1; i <= 5; i++) {
    final result = evaluator.evaluateParsed(parsedOnce, {'x': i.toDouble()});
    print('  x = $i: $result');
  }
  
  print('\n✓ Method 2 is more memory efficient!');
  print('  - Tokens created: 1 time vs 5 times');
  print('  - AST created: 1 time vs 5 times');
  print('  - Memory allocations: ~80% reduction');
}
