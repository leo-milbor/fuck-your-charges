import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuck_your_charges/main.dart';

void main() {
  testWidgets('App renders title and menu icon', (WidgetTester tester) async {
    await tester.pumpWidget(const FuckYourChargesApp());
    await tester.pumpAndSettle();

    expect(find.text('Fuck your charges!'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('Drawer opens with navigation items', (WidgetTester tester) async {
    await tester.pumpWidget(const FuckYourChargesApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Prices'), findsOneWidget);
    expect(find.text('Configure charges'), findsOneWidget);
  });
}
