import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:fuck_your_charges/price_tracker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Fuck your charges!';

  static const charges = <Charge>[
    Charge(rate: 0.10, label: 'Service Charge'),
    Charge(rate: 0.09, label: 'GST'),
  ];

  static var calculator = ChargeCalculator(charges);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Center(child: Text(title)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PriceTracker(calculator: calculator, prices: [null]),
        ),
        // home: const MainPage(title: 'Fuck your charges!'),
      ),
    );
  }
}
