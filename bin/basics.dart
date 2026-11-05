// Experiment 1(b): variables, a list, a loop, a function and interpolation.
int bill(List<int> prices) {
  int total = 0;
  for (final price in prices) {
    total += price;
  }
  return total;
}

void main() {
  final student = 'Student';
  // ignore: avoid_print
  print('$student ordered a dosa and tea. Total: Rs ${bill([60, 20])}');
}
