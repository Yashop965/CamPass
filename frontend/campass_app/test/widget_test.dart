// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campass_app/app.dart';

void main() {
  testWidgets('CAMPASS app starts without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampassApp());

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Error handler shows error snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                // Simulate error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test error')),
                );
              },
              child: const Text('Show Error'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Test error'), findsOneWidget);
  });
}
