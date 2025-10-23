import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:fuck_your_charges/charge_entry.dart';

class ChargesConfigPage extends StatefulWidget {
  final ChargeCalculator calculator;

  const ChargesConfigPage({super.key, required this.calculator});

  @override
  State<ChargesConfigPage> createState() => _ChargesConfigPageState();
}

class _ChargesConfigPageState extends State<ChargesConfigPage> {
  late List<UniqueKey> keys =
      widget.calculator.charges.map((p) => UniqueKey()).toList();
  List<Charge> get charges => widget.calculator.charges;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: charges.length,
            itemBuilder: (context, index) {
              return ChargeEntry(
                key: keys[index],
                onDeleted: () => tryRemoveAt(index),
                onUpdated: (charge) => updateCharges(index, charge),
                onUserValidated: tryAdd,
                charge: charges[index],
              );
            },
          ),
        ),
      ],
    );
  }

  void tryAdd() {
    if (!charges.any((c) => c.rate == 0 || c.label == "")) {
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
        charges[0] = Charge(rate: 0, label: "");
      }
    });
  }

  void updateCharges(int index, Charge charge) {
    setState(() {
      charges[index] = charge;
    });
  }
}
