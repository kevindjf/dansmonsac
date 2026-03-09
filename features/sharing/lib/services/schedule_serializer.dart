import 'package:common/src/database/app_database.dart';
import 'package:common/src/services/log_service.dart';
import 'package:sharing/models/shared_schedule_data.dart';

/// Service to serialize local Drift database data into SharedScheduleData for sharing
class ScheduleSerializer {
  final AppDatabase database;

  ScheduleSerializer(this.database);

  /// Read all data from Drift and serialize into SharedScheduleData
  Future<SharedScheduleData> serialize() async {
    LogService.d('ScheduleSerializer.serialize: Reading from Drift');

    // Fetch all data from Drift
    final allCourses = await database.select(database.courses).get();
    final allSupplies = await database.select(database.supplies).get();
    final allCalendarCourses =
        await database.select(database.calendarCourses).get();

    LogService.d(
        'ScheduleSerializer.serialize: Found ${allCourses.length} courses, ${allSupplies.length} supplies, ${allCalendarCourses.length} calendar courses');

    // Group supplies by courseId
    final suppliesByCourse = <String, List<String>>{};
    for (final supply in allSupplies) {
      suppliesByCourse.putIfAbsent(supply.courseId, () => []).add(supply.name);
    }

    // Build courses list
    final courses = allCourses.map((course) {
      final supplies = suppliesByCourse[course.id] ?? [];
      return SharedCourseData(
        name: course.name,
        supplies: supplies,
      );
    }).toList();

    // Build map: courseId -> courseName for calendar course mapping
    final courseIdToName = <String, String>{};
    for (final course in allCourses) {
      courseIdToName[course.id] = course.name;
    }

    // Build calendar courses list
    final calendarCourses = allCalendarCourses.map((cc) {
      final courseName = courseIdToName[cc.courseId] ?? 'Cours';
      return SharedCalendarCourseData(
        courseName: courseName,
        roomName: cc.roomName,
        startTimeHour: cc.startHour,
        startTimeMinute: cc.startMinute,
        endTimeHour: cc.endHour,
        endTimeMinute: cc.endMinute,
        weekType: cc.weekType,
        dayOfWeek: cc.dayOfWeek,
      );
    }).toList();

    LogService.d(
        'ScheduleSerializer.serialize: Serialized ${courses.length} courses and ${calendarCourses.length} calendar entries');

    return SharedScheduleData(
      version: 1,
      courses: courses,
      calendarCourses: calendarCourses,
    );
  }
}
