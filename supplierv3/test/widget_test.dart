// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:supplierv3/app_model.dart';
import 'package:supplierv3/main.dart';
import 'package:supplierv3/ui/dashboard.dart';

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: ScopedModel<SupplierAppModel>(model: SupplierAppModel(), child: child,),
    );
  }
  testWidgets('Test Dasshboard Widget', (WidgetTester tester) async {
    Dashboard dashboard = Dashboard(null);
    await tester.pumpWidget(makeTestableWidget(child: dashboard));
  });
}
