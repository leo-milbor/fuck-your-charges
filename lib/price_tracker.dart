import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';

class PriceTracker extends StatefulWidget {
  final ChargeCalculator calculator;

  const PriceTracker({super.key, required this.calculator});

  @override
  State<PriceTracker> createState() => _PriceTrackerState();
}

class _PriceTrackerState extends State<PriceTracker> {
  List<double?> prices = [null];
  Widget totalBreakdown = Text('No prices yet!');

  void onTryAdd() {
    if (!prices.any((p) => p == null)) {
      setState(() {
        prices.add(null);
        updateTotal();
      });
    }
  }

  void removePriceRow(int index) {
    setState(() {
      if (prices.length > 1) {
        prices.removeAt(index);
        updateTotal();
      }
    });
  }

  void updatePrice(int index, double? value) {
    setState(() {
      prices[index] = value;
      updateTotal();
    });
  }

  void updateTotal() {
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
          child: ListView.builder(
            itemCount: prices.length,
            addAutomaticKeepAlives: true,
            itemBuilder: (context, index) {
              return PriceRow(
                value: prices[index],
                calculator: widget.calculator,
                onDelete: () => removePriceRow(index),
                onUpdate: (value) => updatePrice(index, value),
                onUserValidate: onTryAdd,
              );
            },
          ),
        ),
        ElevatedButton(onPressed: onTryAdd, child: const Text('Add Price Row')),
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
  final Function(double?) onUpdate;

  const PriceRow({
    super.key,
    required this.calculator,
    required this.onDelete,
    required this.onUpdate,
    required this.onUserValidate,
    required double? value,
  });

  @override
  State<StatefulWidget> createState() {
    return _PriceRowState();
  }
}

class _PriceRowState extends State<PriceRow> with AutomaticKeepAliveClientMixin {
  double? price;
  late FocusNode focusNode;

  void onUpdate(String value) {
    setState(() {
      price = double.tryParse(value);
    });
    widget.onUpdate(price);
  }

  void onValidate() {
    if (price != null) {
      widget.onUserValidate();
      focusNode.unfocus();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  onEditingComplete: onValidate,
                  autofocus: true,
                  focusNode: focusNode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Final: ${widget.calculator.calculateFinalPrice(price ?? 0).toStringAsFixed(2)}',
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
                widget.calculator.calculateTaxBreakdown(price ?? 0).entries.map(
                  (entry) {
                    return Text(
                      '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ).toList(),
          ),
        ],
      ),
    );
  }
}

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
