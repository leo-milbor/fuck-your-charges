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
    for (final charge in charges) {
      currentPrice += applyRate(currentPrice, charge.rate);
    }
    return currentPrice;
  }

  Map<String, double> calculateTaxBreakdown(double basePrice) {
    final breakdown = <String, double>{};
    double currentPrice = basePrice;

    for (final charge in charges) {
      final chargeAmount = applyRate(currentPrice, charge.rate);
      breakdown[charge.label] = chargeAmount;
      currentPrice += chargeAmount;
    }

    return breakdown;
  }

  double applyRate(double price, double rate) {
    return (price * rate / 100);
  }
}
