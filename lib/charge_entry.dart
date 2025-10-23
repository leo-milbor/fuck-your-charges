import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

class ChargeEntry extends StatefulWidget {
  final VoidCallback onDeleted;
  final VoidCallback onUserValidated;
  final Function(Charge) onUpdated;
  final Charge charge;

  const ChargeEntry({
    super.key,
    required this.onDeleted,
    required this.onUpdated,
    required this.onUserValidated,
    required this.charge,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChargeEntryState();
  }
}

class _ChargeEntryState extends State<ChargeEntry>
    with AutomaticKeepAliveClientMixin {
  late FocusNode labelFocusNode;
  late FocusNode rateFocusNode;
  TextEditingController labelController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  String? label;
  double? rate;

  @override
  bool get wantKeepAlive => true;

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
                  controller: labelController,
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onLabelUpdated,
                  onEditingComplete: onValidated,
                  autofocus: true,
                  focusNode: labelFocusNode,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: rateController,
                  inputFormatters: [
                    PercentageTextInputFormatter(
                      decimalDigits: 2,
                      insertDecimalDigits: false,
                      allowNegative: false,
                    ),
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onRateUpdated,
                  onEditingComplete: onValidated,
                  focusNode: rateFocusNode,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDeleted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    labelFocusNode.dispose();
    rateFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    label = widget.charge.label;
    labelController.text = label!;
    labelFocusNode = FocusNode();

    rate = widget.charge.rate;
    rateController.text = rate!.toStringAsFixed(2);
    rateFocusNode = FocusNode();
  }

  void onUpdated() {
    widget.onUpdated(Charge(rate: rate ?? 0, label: label ?? ""));
  }

  void onLabelUpdated(String value) {
    setState(() {
      label = value;
      onUpdated();
    });
  }

  void onRateUpdated(String value) {
    setState(() {
      rate = double.tryParse(value);
      onUpdated();
    });
  }

  void onValidated() {
    if (rate != null && label != null) {
      widget.onUserValidated();
      labelFocusNode.unfocus();
      rateFocusNode.unfocus();
    }
  }
}
