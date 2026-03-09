import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dansmonsac/main.dart';

void main() {
  testWidgets('MyApp smoke test - app builds and renders',
      (WidgetTester tester) async {
    // Use runAsync to allow real async operations (Supabase init, timers)
    // to run without blocking the test framework.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(child: MyApp()),
      );
    });

    // Verify the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
