import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak/presentation/widgets/streak_counter_widget.dart';
import 'package:streak/di/riverpod_di.dart';
import 'package:streak/presentation/pages/streak_detail_page.dart';
import 'package:streak/models/week_day_status.dart';

void main() {
  group('StreakCounterWidget', () {
    testWidgets('displays loading indicator while fetching streak',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StreakCounterWidget(),
            ),
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays fire emoji and streak count when streak > 0',
        (WidgetTester tester) async {
      // Override provider to return a fixed streak
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 5),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StreakCounterWidget(),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Should display fire icon (not emoji)
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);

      // Should display streak count
      expect(find.textContaining('5'), findsOneWidget);
      expect(find.textContaining('Jours'), findsOneWidget);
    });

    testWidgets('displays singular "jour" when streak = 1',
        (WidgetTester tester) async {
      // Override provider to return streak of 1
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 1),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StreakCounterWidget(),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Should display "jour" (singular) not "jours"
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.textContaining('1 Jour'), findsOneWidget);
    });

    testWidgets('displays encouraging message when streak = 0',
        (WidgetTester tester) async {
      // Override provider to return 0 streak
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StreakCounterWidget(),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Should not display fire icon when streak = 0
      expect(find.byIcon(Icons.local_fire_department), findsNothing);

      // Should display encouraging message
      expect(find.textContaining('Prêt pour ta série'), findsOneWidget);
    });

    testWidgets('is tappable and navigates to StreakDetailPage',
        (WidgetTester tester) async {
      // Override providers (including weeklyStreakDataProvider for navigation target)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 3),
            previousStreakProvider.overrideWith((ref) async => 0),
            weeklyStreakDataProvider.overrideWith((ref) async => [
                  WeekDayStatus.completed,
                  WeekDayStatus.missed,
                  WeekDayStatus.future,
                  WeekDayStatus.future,
                  WeekDayStatus.future,
                  WeekDayStatus.inactive,
                  WeekDayStatus.inactive,
                ]),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StreakCounterWidget(),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify not on detail page yet
      expect(find.byType(StreakDetailPage), findsNothing);

      // Tap the widget
      await tester.tap(find.byType(StreakCounterWidget));
      await tester.pumpAndSettle();

      // Should navigate to detail page
      expect(find.byType(StreakDetailPage), findsOneWidget);
    });

    testWidgets('widget has minimum tap target size of 44x44',
        (WidgetTester tester) async {
      // Override provider
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StreakCounterWidget(),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Find the Container with constraints
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(GestureDetector),
              matching: find.byType(Container),
            )
            .first,
      );

      // Verify minimum constraints
      expect(container.constraints?.minHeight, greaterThanOrEqualTo(44));
      expect(container.constraints?.minWidth, greaterThanOrEqualTo(44));
    });

    testWidgets('displays error message when provider fails',
        (WidgetTester tester) async {
      // Override provider to throw an error
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async {
              throw Exception('Test error');
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StreakCounterWidget(),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Should display error message
      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
