import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';

class ChargeEntry extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback onUserValidate;
  final Function(Charge?) onUpdate;
  final Charge? charge;

  const ChargeEntry({
    super.key,
    required this.onDelete,
    required this.onUpdate,
    required this.onUserValidate,
    required this.charge,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChargeEntryState();
  }
}

class _ChargeEntryState extends State<ChargeEntry>
    with AutomaticKeepAliveClientMixin {
  late FocusNode focusNode;
  TextEditingController labelController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  String? label;
  double? rate;

  void onUpdateLabel(String value) {
    setState(() {
      label = value;
      if (rate != null && label != null) {
        widget.onUpdate(Charge(rate: rate!, label: label!));
      }
    });
  }

  void onUpdateRate(String value) {
    setState(() {
      rate = double.tryParse(value);
      if (rate != null && label != null) {
        widget.onUpdate(Charge(rate: rate!, label: label!));
      }
    });
  }

  void onValidate() {
    if (rate != null && label != null) {
      widget.onUserValidate();
      focusNode.unfocus();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    rate = widget.charge?.rate;
    label = widget.charge?.label;
    labelController.text = rate == null ? "" : label!;
    rateController.text = rate == null ? "" : rate!.toStringAsFixed(2);
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
                  controller: labelController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 20,
                  onChanged: onUpdateLabel,
                  onEditingComplete: onValidate,
                  autofocus: true,
                  focusNode: focusNode,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: rateController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 5,
                  onChanged: onUpdateRate,
                  onEditingComplete: onValidate,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
