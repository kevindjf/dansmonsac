import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak/presentation/pages/streak_detail_page.dart';
import 'package:streak/di/riverpod_di.dart';
import 'package:streak/models/week_day_status.dart';

void main() {
  // Mock weekly data for tests (Mon-Sun)
  const mockWeeklyData = [
    WeekDayStatus.completed,
    WeekDayStatus.missed,
    WeekDayStatus.future,
    WeekDayStatus.future,
    WeekDayStatus.future,
    WeekDayStatus.inactive,
    WeekDayStatus.inactive,
  ];

  group('StreakDetailPage', () {
    testWidgets('displays fire emoji', (WidgetTester tester) async {
      // Build widget with mocked providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 5),
            previousStreakProvider.overrideWith((ref) async => 0),
            weeklyStreakDataProvider
                .overrideWith((ref) async => mockWeeklyData),
          ],
          child: const MaterialApp(
            home: StreakDetailPage(),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Should display fire icon
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('displays motivational message when streak > 0',
        (WidgetTester tester) async {
      // Build widget with streak = 5
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 5),
            previousStreakProvider.overrideWith((ref) async => 0),
            weeklyStreakDataProvider
                .overrideWith((ref) async => mockWeeklyData),
          ],
          child: const MaterialApp(
            home: StreakDetailPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display motivational message
      expect(find.textContaining('Tu as un streak de'), findsOneWidget);
      expect(find.textContaining('5 jours'), findsOneWidget);
      expect(
          find.textContaining('Prepare ton sac chaque jour'), findsOneWidget);
    });

    testWidgets('displays encouraging message when streak = 0 (never started)',
        (WidgetTester tester) async {
      // Build widget with streak = 0 and no previous streak
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 0),
            previousStreakProvider.overrideWith((ref) async => 0),
            weeklyStreakDataProvider
                .overrideWith((ref) async => mockWeeklyData),
          ],
          child: const MaterialApp(
            home: StreakDetailPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display encouraging message for first-time user
      expect(find.textContaining('Commence ton streak aujourd\'hui'),
          findsOneWidget);
      expect(find.textContaining('Prepare ton sac chaque jour'), findsOneWidget);
    });

    testWidgets(
        'displays "after break" message when streak = 0 and previousStreak > 0',
        (WidgetTester tester) async {
      // Build widget with streak = 0 but previous streak = 7
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 0),
            previousStreakProvider.overrideWith((ref) async => 7),
            weeklyStreakDataProvider
                .overrideWith((ref) async => mockWeeklyData),
          ],
          child: const MaterialApp(
            home: StreakDetailPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display "after break" message
      expect(find.textContaining('Recommence ton streak'), findsOneWidget);
      expect(find.textContaining('7 jours'), findsOneWidget);
      expect(find.textContaining('bat ton record'), findsOneWidget);
    });

    testWidgets('back navigation works', (WidgetTester tester) async {
      // Build widget with Navigator
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 5),
            previousStreakProvider.overrideWith((ref) async => 0),
            weeklyStreakDataProvider
                .overrideWith((ref) async => mockWeeklyData),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StreakDetailPage()),
                  ),
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to navigate to detail page
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Should be on detail page
      expect(find.byType(StreakDetailPage), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back on home page
      expect(find.byType(StreakDetailPage), findsNothing);
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('has proper AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStreakProvider.overrideWith((ref) async => 5),
            previousStreakProvider.overrideWith((ref) async => 0),
            weeklyStreakDataProvider
                .overrideWith((ref) async => mockWeeklyData),
          ],
          child: const MaterialApp(
            home: StreakDetailPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have title
      expect(find.text('Ton streak'), findsOneWidget);

      // Should have back button
      expect(find.byType(BackButton), findsOneWidget);
    });
  });
}
