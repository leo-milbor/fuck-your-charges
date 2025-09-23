import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:fuck_your_charges/charge_calculator_config_page.dart';
import 'package:fuck_your_charges/prices_page.dart';

void main() {
  runApp(FuckYourChargesApp());
}

class FuckYourChargesApp extends StatefulWidget {
  static const String title = 'Fuck your charges!';

  final ChargeCalculator calculator = ChargeCalculator([
    Charge(rate: 0.10, label: 'Service Charge'),
    Charge(rate: 0.09, label: 'GST'),
  ]);

  final List<double?> prices = [null];

  FuckYourChargesApp({super.key});

  @override
  State<FuckYourChargesApp> createState() => _FuckYourChargesAppState();
}

class _FuckYourChargesAppState extends State<FuckYourChargesApp> {
  int _selectedIndex = 0;
  List<Widget> get _widgetOptions => <Widget>[
    PricesPage(calculator: widget.calculator, prices: widget.prices),
    ChargesCalculatorConfigPage(calculator: widget.calculator),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FuckYourChargesApp.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Center(child: Text(FuckYourChargesApp.title)),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        body: Center(child: _widgetOptions[_selectedIndex]),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menu'),
              ),
              ListTile(
                title: const Text('Prices'),
                selected: _selectedIndex == 0,
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Configure charges'),
                selected: _selectedIndex == 1,
                onTap: () {
                  _onItemTapped(1);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
