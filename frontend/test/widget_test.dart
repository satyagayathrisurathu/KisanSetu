import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('KisanSetu app loads successfully', (WidgetTester tester) async {
    // Build the KisanSetu app and trigger a frame.
    await tester.pumpWidget(const KisanSetuApp());

    // Verify that the app loads.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}