import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:fuck_your_charges/charge_entry.dart';

class ChargesCalculatorConfigPage extends StatefulWidget {
  final ChargeCalculator calculator;

  const ChargesCalculatorConfigPage({super.key, required this.calculator});

  @override
  State<ChargesCalculatorConfigPage> createState() =>
      _ChargesCalculatorConfigPageState();
}

class _ChargesCalculatorConfigPageState
    extends State<ChargesCalculatorConfigPage> {
  List<Charge?> get charges => widget.calculator.charges;
  late List<UniqueKey?> keys =
      widget.calculator.charges.map((p) => UniqueKey()).toList();

  void tryAdd() {
    if (!charges.any((c) => c == null || c.rate == 0 || c.label == "")) {
      setState(() {
        charges.add(Charge(rate: 0, label: ""));
        keys.add(UniqueKey());
      });
    }
  }

  void tryRemoveAt(int index) {
    setState(() {
      if (charges.length > 1) {
        charges.removeAt(index);
        keys.removeAt(index);
      } else {
        charges[0] = null;
      }
    });
  }

  void updateCharges(int index, Charge? charge) {
    setState(() {
      charges[index] = charge;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ChargeEntry(
                onDelete: () => tryRemoveAt(index),
                onUpdate: (charge) => updateCharges(index, charge),
                onUserValidate: tryAdd,
                charge: charges[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
