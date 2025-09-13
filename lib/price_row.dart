import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';

class PriceRow extends StatefulWidget {
  final ChargeCalculator calculator;
  final VoidCallback onDelete;
  final VoidCallback onUserValidate;
  final Function(double?) onUpdate;
  final double? price;

  const PriceRow({
    super.key,
    required this.calculator,
    required this.onDelete,
    required this.onUpdate,
    required this.onUserValidate,
    required this.price,
  });

  @override
  State<StatefulWidget> createState() {
    return _PriceRowState();
  }
}

class _PriceRowState extends State<PriceRow>
    with AutomaticKeepAliveClientMixin {
  double? price;
  late FocusNode focusNode;
  late Widget priceBreakDown;
  TextEditingController controller = TextEditingController();

  void onUpdate(String value) {
    setState(() {
      price = double.tryParse(value);
      priceBreakDown = PriceBreakDown(
        calculator: widget.calculator,
        price: price!,
      );
      widget.onUpdate(price);
    });
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
    price = widget.price;
    controller.text = price == null ? "" : price!.toStringAsFixed(2);
    priceBreakDown = PriceBreakDown(
      calculator: widget.calculator,
      price: price,
    );
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
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Base Price',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 9,
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
                    price == null
                        ? "No full price to show."
                        : 'Final: ${widget.calculator.calculateFinalPrice(price ?? 0).toStringAsFixed(2)}',
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
          // Show tax breakdown
          priceBreakDown,
        ],
      ),
    );
  }
}

class PriceBreakDown extends StatelessWidget {
  static const Text emptyPriceWidget = Text("No price to break down.");
  final ChargeCalculator calculator;
  final double? price;

  const PriceBreakDown({
    super.key,
    required this.calculator,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return price == null
        ? emptyPriceWidget
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              calculator.calculateTaxBreakdown(price!).entries.map((entry) {
                return Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }).toList(),
        );
  }
}
