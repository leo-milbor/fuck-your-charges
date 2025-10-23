import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:fuck_your_charges/price_entry.dart';
import 'package:fuck_your_charges/total_breakdown.dart';

class PricesPage extends StatefulWidget {
  final ChargeCalculator calculator;
  final List<double?> prices;

  const PricesPage({super.key, required this.calculator, required this.prices});

  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  late List<UniqueKey?> keys = widget.prices.map((p) => UniqueKey()).toList();
  Widget totalBreakdown = Text('No prices yet!');
  List<double?> get prices => widget.prices;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: prices.length,
            addAutomaticKeepAlives: true,
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemBuilder: (context, index) {
              return PriceEntry(
                key: keys[index],
                price: prices[index],
                calculator: widget.calculator,
                onDeleted: () => tryRemoveAt(index),
                onUpdated: (price) => updatePrices(index, price),
                onUserValidated: tryAdd,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        totalBreakdown,
      ],
    );
  }

  @override
  void initState() {
    updateTotalBreakdown();
    super.initState();
  }

  void tryAdd() {
    if (!prices.any((p) => p == null)) {
      setState(() {
        prices.add(null);
        keys.add(UniqueKey());
        updateTotalBreakdown();
      });
    }
  }

  void tryRemoveAt(int index) {
    setState(() {
      if (prices.length > 1) {
        prices.removeAt(index);
        keys.removeAt(index);
        updateTotalBreakdown();
      } else {
        prices[0] = null;
      }
    });
  }

  void updatePrices(int index, double? price) {
    setState(() {
      prices[index] = price;
      updateTotalBreakdown();
    });
  }

  void updateTotalBreakdown() {
    totalBreakdown = TotalBreakdown(
      prices: prices.map((p) => p ?? 0),
      calculator: widget.calculator,
    );
  }
}
