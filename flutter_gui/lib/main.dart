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
        appBar: AppBar(
          title: Center(
            child: const Text(
              style: TextStyle(fontWeight: FontWeight.bold),
              'Fuck you charges!',
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(
                child: DecimalListWidget(
                  callback: (values) => setState(() => _charges = values),
                  defaultValue: '10 9',
                  inputDecoration: const InputDecoration(
                    filled: true,
                    hintText: 'Enter space separated charges.',
                    labelText: 'Charges',
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                child: DecimalListWidget(
                  callback: (values) => setState(() => _prices = values),
                  defaultValue: '',
                  inputDecoration: const InputDecoration(
                    filled: true,
                    hintText: 'Enter space separated prices.',
                    labelText: 'Prices',
                  ),
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children:
                    calculateCharges(prices: _prices, charges: _charges)
                        .map(
                          (t) => Row(
                            children: [
                              Text(
                                style: TextStyle(fontSize: 25),
                                'What was written: ',
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                t.$1,
                              ),
                              Text(
                                style: TextStyle(fontSize: 25),
                                ' what you actually paid: ',
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                t.$2,
                              ),
                            ],
                          ),
                        )
                        .toList(),
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
  final InputDecoration? inputDecoration;

  const DecimalListWidget({
    super.key,
    required this.callback,
    required this.defaultValue,
    this.inputDecoration,
  });

  @override
  State<DecimalListWidget> createState() => _DecimalListWidgetState();
}

class _DecimalListWidgetState extends State<DecimalListWidget> {
  final _key = GlobalKey<FormState>();
  InputDecoration? inputDecoration;
  TextEditingController controller = TextEditingController(text: '');
  String defaultValue = '';

  @override
  void initState() {
    super.initState();
    defaultValue = widget.defaultValue;
    controller = TextEditingController(text: defaultValue);
    inputDecoration = widget.inputDecoration;

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
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: inputDecoration,
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
