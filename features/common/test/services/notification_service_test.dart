import 'package:flutter_test/flutter_test.dart';
import 'package:common/src/services/notification_service.dart';
import 'package:common/src/database/app_database.dart';
import 'package:schedule/repository/calendar_course_repository.dart';
import 'package:schedule/models/calendar_course_with_supplies.dart';
import 'package:supply/models/supply.dart';
import 'package:dartz/dartz.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:drift/native.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([CalendarCourseRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildTomorrowNotificationContent', () {
    late MockCalendarCourseRepository mockRepository;
    late AppDatabase mockDatabase;

    setUp(() {
      mockRepository = MockCalendarCourseRepository();
      mockDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await mockDatabase.close();
    });

    test('returns null when no courses tomorrow', () async {
      // Mock repository to return empty list
      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => const Right([]));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNull);
    });

    test('returns null when repository fails', () async {
      // Mock repository to return failure
      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Left(NetworkFailure('Network error')));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNull);
    });

    test('lists single subject when 1 course', () async {
      // Mock repository to return 1 course with 5 supplies
      final courses = [
        CalendarCourseWithSupplies(
          courseId: '1',
          courseName: 'Mathématiques',
          startHour: 8,
          startMinute: 0,
          endHour: 9,
          endMinute: 30,
          supplies: List.generate(
              5, (i) => Supply(id: 'supply-$i', name: 'Supply $i')),
        ),
      ];

      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Right(courses));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNotNull);
      expect(content!.title, equals('Prépare ton sac pour demain 🎒'));
      expect(content.body,
          equals('Demain tu as Mathématiques. 5 fournitures à préparer.'));
    });

    test('lists subjects when 2 courses', () async {
      // Mock repository to return 2 courses
      final courses = [
        CalendarCourseWithSupplies(
          courseId: '1',
          courseName: 'Mathématiques',
          startHour: 8,
          startMinute: 0,
          endHour: 9,
          endMinute: 30,
          supplies: [
            Supply(id: '1', name: 'Cahier'),
            Supply(id: '2', name: 'Stylo')
          ],
        ),
        CalendarCourseWithSupplies(
          courseId: '2',
          courseName: 'Français',
          startHour: 9,
          startMinute: 30,
          endHour: 11,
          endMinute: 0,
          supplies: [Supply(id: '3', name: 'Livre')],
        ),
      ];

      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Right(courses));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNotNull);
      expect(
          content!.body,
          equals(
              'Demain tu as Mathématiques et Français. 3 fournitures à préparer.'));
    });

    test('lists subjects when 3-4 courses with "et" before last', () async {
      // Mock repository to return 3 courses
      final courses = [
        CalendarCourseWithSupplies(
          courseId: '1',
          courseName: 'Maths',
          startHour: 8,
          startMinute: 0,
          endHour: 9,
          endMinute: 0,
          supplies: [
            Supply(id: '1', name: 'Cahier'),
            Supply(id: '2', name: 'Stylo'),
            Supply(id: '3', name: 'Règle')
          ],
        ),
        CalendarCourseWithSupplies(
          courseId: '2',
          courseName: 'Français',
          startHour: 9,
          startMinute: 0,
          endHour: 10,
          endMinute: 0,
          supplies: [
            Supply(id: '4', name: 'Livre'),
            Supply(id: '5', name: 'Cahier')
          ],
        ),
        CalendarCourseWithSupplies(
          courseId: '3',
          courseName: 'Histoire-Géo',
          startHour: 10,
          startMinute: 0,
          endHour: 11,
          endMinute: 0,
          supplies: [
            Supply(id: '6', name: 'Atlas'),
            Supply(id: '7', name: 'Cahier'),
            Supply(id: '8', name: 'Stylo'),
            Supply(id: '9', name: 'Trousse')
          ],
        ),
      ];

      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Right(courses));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNotNull);
      expect(
          content!.body,
          equals(
              'Demain tu as Maths, Français et Histoire-Géo. 9 fournitures à préparer.'));
    });

    test('summarizes when 5+ courses', () async {
      // Mock repository to return 6 courses
      final courses = List.generate(
        6,
        (i) => CalendarCourseWithSupplies(
          courseId: 'course-$i',
          courseName: 'Matière ${i + 1}',
          startHour: 8 + i,
          startMinute: 0,
          endHour: 9 + i,
          endMinute: 0,
          supplies: List.generate(
              3, (j) => Supply(id: 'supply-$i-$j', name: 'Supply $i-$j')),
        ),
      );

      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Right(courses));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNotNull);
      expect(content!.body,
          equals('Demain tu as 6 matières. 18 fournitures à préparer.'));
    });

    test('counts supplies correctly across multiple courses', () async {
      // Mock repository with courses having different supply counts
      final courses = [
        CalendarCourseWithSupplies(
          courseId: '1',
          courseName: 'Maths',
          startHour: 8,
          startMinute: 0,
          endHour: 9,
          endMinute: 0,
          supplies: List.generate(
              3, (i) => Supply(id: 'math-$i', name: 'Math Supply $i')),
        ),
        CalendarCourseWithSupplies(
          courseId: '2',
          courseName: 'Français',
          startHour: 9,
          startMinute: 0,
          endHour: 10,
          endMinute: 0,
          supplies: List.generate(
              2, (i) => Supply(id: 'french-$i', name: 'French Supply $i')),
        ),
        CalendarCourseWithSupplies(
          courseId: '3',
          courseName: 'Histoire',
          startHour: 10,
          startMinute: 0,
          endHour: 11,
          endMinute: 0,
          supplies: List.generate(
              4, (i) => Supply(id: 'history-$i', name: 'History Supply $i')),
        ),
      ];

      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Right(courses));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNotNull);
      expect(content!.body, contains('9 fournitures'));
    });

    test('shows completed message when bag ready', () async {
      // Insert bag completion for tomorrow
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      await mockDatabase.into(mockDatabase.bagCompletions).insert(
            BagCompletionsCompanion.insert(
              id: 'test-bag-completion-1',
              date: tomorrowDate,
              completedAt: DateTime.now(),
              deviceId: 'test-device',
              createdAt: DateTime.now(),
            ),
          );

      // Mock repository to return 2 courses
      final courses = [
        CalendarCourseWithSupplies(
          courseId: '1',
          courseName: 'Maths',
          startHour: 8,
          startMinute: 0,
          endHour: 9,
          endMinute: 0,
          supplies: [Supply(id: '1', name: 'Cahier')],
        ),
        CalendarCourseWithSupplies(
          courseId: '2',
          courseName: 'Français',
          startHour: 9,
          startMinute: 0,
          endHour: 10,
          endMinute: 0,
          supplies: [Supply(id: '2', name: 'Livre')],
        ),
      ];

      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Right(courses));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNotNull);
      expect(content!.body, contains('Ton sac est déjà prêt! ✅'));
      expect(content.body, contains('2 fournitures'));
    });

    test('handles zero supplies correctly', () async {
      // Mock repository to return courses with no supplies
      final courses = [
        CalendarCourseWithSupplies(
          courseId: '1',
          courseName: 'Étude',
          startHour: 8,
          startMinute: 0,
          endHour: 9,
          endMinute: 0,
          supplies: [],
        ),
      ];

      when(mockRepository.getTomorrowCourses())
          .thenAnswer((_) async => Right(courses));

      final content =
          await NotificationService.buildTomorrowNotificationContent(
        mockRepository,
        mockDatabase,
      );

      expect(content, isNotNull);
      expect(content!.body,
          equals('Demain tu as Étude. 0 fournitures à préparer.'));
    });
  });
}
