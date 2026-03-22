import 'package:flutter_test/flutter_test.dart';
import 'package:fuck_your_charges/charge_calculator.dart';

void main() {
  group('ChargeCalculator', () {
    final calculator = ChargeCalculator(
      charges: [
        Charge(rate: 10, label: 'Service Charge'),
        Charge(rate: 9, label: 'GST'),
      ],
    );

    test('applyRate computes correct charge amount', () {
      expect(calculator.applyRate(100, 10), 10.0);
      expect(calculator.applyRate(110, 9), 9.9);
    });

    test('calculateFinalPrice compounds charges correctly', () {
      // 100 + 10% = 110, then 110 + 9% = 119.90
      expect(calculator.calculateFinalPrice(100), closeTo(119.90, 0.001));
    });

    test('calculateTaxBreakdown returns correct amounts per charge', () {
      final breakdown = calculator.calculateTaxBreakdown(100);
      expect(breakdown['Service Charge'], closeTo(10.0, 0.001));
      expect(breakdown['GST'], closeTo(9.9, 0.001));
    });
  });
}
