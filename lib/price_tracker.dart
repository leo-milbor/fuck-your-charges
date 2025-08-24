import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';

class PriceTracker extends StatefulWidget {
  final ChargeCalculator calculator;

  const PriceTracker({super.key, required this.calculator});

  @override
  State<PriceTracker> createState() => _PriceTrackerState();
}

class _PriceTrackerState extends State<PriceTracker> {
  List<double> prices = [0];
  Widget totalBreakdown = Text('No prices yet!');

  void addPriceRow() {
    setState(() {
      prices.insert(0, 0);
      updateTotal();
    });
  }

  void removePriceRow(int index) {
    setState(() {
      if (prices.length > 1) {
        prices.removeAt(index);
        updateTotal();
      }
    });
  }

  void updatePrice(int index, String value) {
    final double? price = double.tryParse(value);
    if (price != null) {
      setState(() {
        prices[index] = price;
        updateTotal();
      });
    }
  }

  void updateTotal() {
    totalBreakdown = TotalBreakdown(
      prices: prices,
      calculator: widget.calculator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: prices.length,
            itemBuilder: (context, index) {
              return PriceRow(
                calculator: widget.calculator,
                onDelete: () => removePriceRow(index),
                onUpdate: (value) => updatePrice(index, value),
                onUserValidate: addPriceRow,
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: addPriceRow,
          child: const Text('Add Price Row'),
        ),
        const SizedBox(height: 16),
        totalBreakdown,
      ],
    );
  }
}

class PriceRow extends StatefulWidget {
  final ChargeCalculator calculator;
  final VoidCallback onDelete;
  final VoidCallback onUserValidate;
  final Function(String) onUpdate;

  const PriceRow({
    super.key,
    required this.calculator,
    required this.onDelete,
    required this.onUpdate,
    required this.onUserValidate,
  });

  @override
  State<StatefulWidget> createState() {
    return _PriceRowState();
  }
}

class _PriceRowState extends State<PriceRow> {
  double price = 0;

  void onUpdate(String value) {
    widget.onUpdate(value);
    setState(() {
      price = double.parse(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Base Price',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onUpdate,
                  onEditingComplete: widget.onUserValidate,
                  autofocus: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Final: ${widget.calculator.calculateFinalPrice(price).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show tax breakdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                widget.calculator.calculateTaxBreakdown(price).entries.map((
                  entry,
                ) {
                  return Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class TotalBreakdown extends StatelessWidget {
  final List<double> prices;
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
