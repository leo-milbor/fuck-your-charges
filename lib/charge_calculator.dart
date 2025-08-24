class Charge {
  final double rate;
  final String label;

  const Charge({required this.rate, required this.label});
}

class ChargeCalculator {
  List<Charge> charges = [
    Charge(rate: 0.09, label: 'GST'),
    Charge(rate: 0.10, label: 'Service Charge'),
  ];

  ChargeCalculator(this.charges);

  // Calculate price with all charges applied
  double calculateFinalPrice(double basePrice) {
    double currentPrice = basePrice;
    for (final tax in charges) {
      currentPrice += (currentPrice * tax.rate);
    }
    return currentPrice;
  }

  // Calculate individual charge impact
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
