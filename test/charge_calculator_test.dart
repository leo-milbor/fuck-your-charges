import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/charge_calculator.dart'; // Adjust import based on your structure

void main() {
  test('Charge calculation with 10% and 9% default', () {
    final calculator = ChargeCalculator();
    expect(calculator.calculateCharge(100, 0.10), 110);
    expect(calculator.calculateCharge(110, 0.09), 119.90);
  });
}