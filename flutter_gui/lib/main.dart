import 'package:flutter/material.dart';
import 'package:flutter_gui/src/rust/api/simple.dart';
import 'package:flutter_gui/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const FuckYourChargesApp());
}

class FuckYourChargesApp extends StatefulWidget {
  const FuckYourChargesApp({super.key});

  @override
  State<StatefulWidget> createState() => FuckYourChargesState();
}

class FuckYourChargesState extends State<FuckYourChargesApp> {
  List<String> _charges = ["10", "9"];
  List<String> _prices = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Column(
            children: [
              DecimalListWidget(
                callback: (values) => setState(() => _charges = values),
                defaultValue: '10 9',
              ),
              DecimalListWidget(
                callback: (values) => setState(() => _prices = values),
                defaultValue: '',
              ),
              Text(
                calculateCharges(prices: _prices, charges: _charges)
                    .map(
                      (t) =>
                          'What was written: ${t.$1}, what you actually paid: ${t.$2}',
                    )
                    .join('\n'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef DecimalListCallback = void Function(List<String> values);

// Create a Form widget.
class DecimalListWidget extends StatefulWidget {
  static final _validDecimalListRegex = RegExp(
    r'^\d{1,4}(?:\.\d{1,2})?(?:\s+\d{1,4}(?:\.\d{1,2})?)*$',
  );

  final DecimalListCallback callback;
  final String defaultValue;

  const DecimalListWidget({
    super.key,
    required this.callback,
    required this.defaultValue,
  });

  @override
  State<DecimalListWidget> createState() => _DecimalListWidgetState();
}

class _DecimalListWidgetState extends State<DecimalListWidget> {
  final _key = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController(text: '');
  String defaultValue = '';

  @override
  void initState() {
    super.initState();
    defaultValue = widget.defaultValue;
    controller = TextEditingController(text: defaultValue);

    controller.addListener(() {
      setState(() {
        defaultValue = controller.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return GestureDetector(
      onTap: () {},
      child: Form(
        key: _key,
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null ||
                !DecimalListWidget._validDecimalListRegex.hasMatch(value)) {
              return 'Please enter space separated decimal numbers.';
            }
            return null;
          },
          onFieldSubmitted: (value) {
            _key.currentState!.save();
          },
          onSaved: (value) {
            if (value != null && _key.currentState!.validate()) {
              widget.callback(value.split(' ').map((s) => s.trim()).toList());
            }
          },
        ),
      ),
    );
  }
}
