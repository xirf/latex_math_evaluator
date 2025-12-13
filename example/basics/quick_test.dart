import 'package:latex_math_evaluator/latex_math_evaluator.dart';

void main() {
  // First tokenize to see what tokens we get
  final tokens = Tokenizer(r'\sqrt{|x|}').tokenize();
  print('Tokens:');
  for (final token in tokens) {
    print('  $token');
  }

  print('\nEvaluating...');
  final e = LatexMathEvaluator();
  print(e.evaluate(r'\sqrt{|x|}', {'x': -4}));
}
