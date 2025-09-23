class Charge {
  final double rate;
  final String label;

  const Charge({required this.rate, required this.label});
}

class ChargeCalculator {
  final List<Charge> charges;
  ChargeCalculator({required this.charges});

  double calculateFinalPrice(double basePrice) {
    double currentPrice = basePrice;
    for (final tax in charges) {
      currentPrice += (currentPrice * tax.rate);
    }
    return currentPrice;
  }

  Map<String, double> calculateTaxBreakdown(double basePrice) {
    final breakdown = <String, double>{};
    double currentPrice = basePrice;

    for (final charge in charges) {
      final chargeAmount = currentPrice * charge.rate;
      breakdown[charge.label] = chargeAmount;
      currentPrice += chargeAmount;
    }

    return breakdown;
  }
}
