import 'package:json_annotation/json_annotation.dart';

part 'shared_schedule_data.g.dart';

/// Data structure for the JSONB data stored in shared_schedules table
@JsonSerializable(explicitToJson: true)
class SharedScheduleData {
  final int version;
  final List<SharedCourseData> courses;
  @JsonKey(name: 'calendar_courses')
  final List<SharedCalendarCourseData> calendarCourses;

  SharedScheduleData({
    this.version = 1,
    required this.courses,
    required this.calendarCourses,
  });

  factory SharedScheduleData.fromJson(Map<String, dynamic> json) =>
      _$SharedScheduleDataFromJson(json);

  Map<String, dynamic> toJson() => _$SharedScheduleDataToJson(this);

  int get totalSupplies =>
      courses.fold(0, (sum, course) => sum + course.supplies.length);
}

@JsonSerializable()
class SharedCourseData {
  final String name;
  final List<String> supplies;

  SharedCourseData({
    required this.name,
    required this.supplies,
  });

  factory SharedCourseData.fromJson(Map<String, dynamic> json) =>
      _$SharedCourseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SharedCourseDataToJson(this);
}

@JsonSerializable()
class SharedCalendarCourseData {
  @JsonKey(name: 'course_name')
  final String courseName;
  @JsonKey(name: 'room_name')
  final String roomName;
  @JsonKey(name: 'start_time_hour')
  final int startTimeHour;
  @JsonKey(name: 'start_time_minute')
  final int startTimeMinute;
  @JsonKey(name: 'end_time_hour')
  final int endTimeHour;
  @JsonKey(name: 'end_time_minute')
  final int endTimeMinute;
  @JsonKey(name: 'week_type')
  final String weekType;
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;

  SharedCalendarCourseData({
    required this.courseName,
    required this.roomName,
    required this.startTimeHour,
    required this.startTimeMinute,
    required this.endTimeHour,
    required this.endTimeMinute,
    required this.weekType,
    required this.dayOfWeek,
  });

  factory SharedCalendarCourseData.fromJson(Map<String, dynamic> json) =>
      _$SharedCalendarCourseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SharedCalendarCourseDataToJson(this);
}
