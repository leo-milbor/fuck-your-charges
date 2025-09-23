import 'package:flutter/material.dart';
import 'package:fuck_your_charges/charge_calculator.dart';
import 'package:fuck_your_charges/charge_config_page.dart';
import 'package:fuck_your_charges/prices_page.dart';

void main() {
  runApp(FuckYourChargesApp());
}

class FuckYourChargesApp extends StatelessWidget {
  static const String title = 'Fuck your charges!';

  const FuckYourChargesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  final ChargeCalculator calculator = ChargeCalculator(
    charges: [
      Charge(rate: 10, label: 'Service Charge'),
      Charge(rate: 9, label: 'GST'),
    ],
  );

  final List<double?> prices = [null];

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<Widget> get _widgetOptions => <Widget>[
    PricesPage(calculator: widget.calculator, prices: widget.prices),
    ChargesConfigPage(calculator: widget.calculator),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FuckYourChargesApp.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
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
        body: Center(child: _widgetOptions[selectedIndex]),
        drawer: Builder(
          builder: (context) {
            return Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('Menu'),
                  ),
                  ListTile(
                    title: const Text('Prices'),
                    selected: selectedIndex == 0,
                    onTap: () {
                      onItemTapped(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Configure charges'),
                    selected: selectedIndex == 1,
                    onTap: () {
                      onItemTapped(1);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
