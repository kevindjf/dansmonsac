import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak/presentation/widgets/streak_break_dialog.dart';

void main() {
  group('StreakBreakDialog', () {
    Future<void> showStreakBreakDialog(
        WidgetTester tester, int previousStreak) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            colorScheme: ThemeData.dark().colorScheme.copyWith(
                  secondary: const Color(0xFFB9A0FF),
                ),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      StreakBreakDialog(previousStreak: previousStreak),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
    }

    testWidgets('displays previous streak count correctly',
        (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 15);

      expect(find.textContaining('15'), findsOneWidget);
      expect(find.textContaining('jours'), findsOneWidget);
    });

    testWidgets('displays singular jour when previousStreak = 1',
        (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 1);

      expect(find.textContaining('1 jour'), findsOneWidget);
      // Should not say "jours" (plural)
      expect(find.textContaining('1 jours'), findsNothing);
    });

    testWidgets('displays encouraging message text',
        (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 10);

      expect(
        find.textContaining('Recommence aujourd\'hui et bat ton record'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Pas grave'),
        findsOneWidget,
      );
    });

    testWidgets('dismiss button exists with correct text',
        (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 5);

      expect(find.text('C\'est reparti !'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('dismiss button has minimum 44x44 tap target',
        (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 5);

      // Find the dismiss button (the one inside the dialog, not the "Show" button)
      final dismissButton =
          find.widgetWithText(ElevatedButton, 'C\'est reparti !');
      expect(dismissButton, findsOneWidget);

      final buttonWidget = tester.widget<ElevatedButton>(dismissButton);
      final style = buttonWidget.style;
      expect(style?.minimumSize?.resolve({}), isNotNull);
      final minSize = style!.minimumSize!.resolve({})!;
      expect(minSize.height, greaterThanOrEqualTo(44));
      expect(minSize.width, greaterThanOrEqualTo(44));
    });

    testWidgets('on dismiss, dialog closes', (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 15);

      // Verify dialog is showing
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap dismiss button
      await tester.tap(find.text('C\'est reparti !'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('displays muscle emoji', (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 7);

      // The muscle emoji (U+1F4AA)
      expect(find.text('\u{1F4AA}'), findsOneWidget);
    });

    testWidgets('dialog is not dismissible by tapping outside',
        (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 5);

      // Verify dialog is showing
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap outside the dialog (on the barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be showing (barrierDismissible: false)
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('uses theme accent color for button',
        (WidgetTester tester) async {
      await showStreakBreakDialog(tester, 5);

      final dismissButton =
          find.widgetWithText(ElevatedButton, 'C\'est reparti !');
      final buttonWidget = tester.widget<ElevatedButton>(dismissButton);
      final style = buttonWidget.style;
      final bgColor = style?.backgroundColor?.resolve({});
      expect(bgColor, equals(const Color(0xFFB9A0FF)));
    });
  });
}
