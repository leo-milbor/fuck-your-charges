import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:fuck_your_charges/total_breakdown.dart';
import 'package:fuck_your_charges/price_row.dart';

class PriceTracker extends StatefulWidget {
  final ChargeCalculator calculator;
  final List<double?> prices;

  const PriceTracker({
    super.key,
    required this.calculator,
    required this.prices,
  });

  @override
  State<PriceTracker> createState() => _PriceTrackerState();
}

class _PriceTrackerState extends State<PriceTracker> {
  List<double?> get prices => widget.prices;
  late List<UniqueKey?> keys = widget.prices.map((p) => UniqueKey()).toList();
  Widget totalBreakdown = Text('No prices yet!');

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

  void updatePrice(int index, double? price) {
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
              return PriceRow(
                key: keys[index],
                price: prices[index],
                calculator: widget.calculator,
                onDelete: () => tryRemoveAt(index),
                onUpdate: (price) => updatePrice(index, price),
                onUserValidate: tryAdd,
              );
            },
          ),
        ),
        ElevatedButton(onPressed: tryAdd, child: const Text('Add Price Row')),
        const SizedBox(height: 16),
        totalBreakdown,
      ],
    );
  }
}
