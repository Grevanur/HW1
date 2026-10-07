import 'package:calculator_studio/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorEngine', () {
    test('performs all four decimal operations', () {
      expect(CalculatorEngine.apply(1.5, 2.25, '+'), 3.75);
      expect(CalculatorEngine.apply(5.5, 2.25, '−'), 3.25);
      expect(CalculatorEngine.apply(1.5, 2.0, '×'), 3.0);
      expect(CalculatorEngine.apply(7.5, 2.5, '÷'), 3.0);
    });

    test('rejects division by zero', () {
      expect(CalculatorEngine.apply(7, 0, '÷'), isNull);
    });

    test('formats whole and decimal results readably', () {
      expect(CalculatorEngine.format(8.0), '8');
      expect(CalculatorEngine.format(0.125), '0.125');
    });
  });
}
