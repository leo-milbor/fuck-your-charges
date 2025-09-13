import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';

class TotalBreakdown extends StatelessWidget {
  final Iterable<double> prices;
  final ChargeCalculator calculator;

  const TotalBreakdown({
    super.key,
    required this.prices,
    required this.calculator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Base Total: ${prices.reduce((a, b) => a + b).toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...calculator.charges.map((charge) {
          final chargeAmount = prices
              .map((p) => calculator.calculateTaxBreakdown(p)[charge.label]!)
              .reduce((a, b) => a + b);
          return Text(
            '${charge.label}: ${chargeAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          );
        }),
        Text(
          'Final Total: ${calculator.calculateFinalPrice(prices.reduce((a, b) => a + b)).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
