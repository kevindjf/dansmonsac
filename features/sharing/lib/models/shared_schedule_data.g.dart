// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_schedule_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedScheduleData _$SharedScheduleDataFromJson(Map<String, dynamic> json) =>
    SharedScheduleData(
      version: (json['version'] as num?)?.toInt() ?? 1,
      courses: (json['courses'] as List<dynamic>)
          .map((e) => SharedCourseData.fromJson(e as Map<String, dynamic>))
          .toList(),
      calendarCourses: (json['calendar_courses'] as List<dynamic>)
          .map((e) =>
              SharedCalendarCourseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SharedScheduleDataToJson(SharedScheduleData instance) =>
    <String, dynamic>{
      'version': instance.version,
      'courses': instance.courses.map((e) => e.toJson()).toList(),
      'calendar_courses':
          instance.calendarCourses.map((e) => e.toJson()).toList(),
    };

SharedCourseData _$SharedCourseDataFromJson(Map<String, dynamic> json) =>
    SharedCourseData(
      name: json['name'] as String,
      supplies:
          (json['supplies'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SharedCourseDataToJson(SharedCourseData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'supplies': instance.supplies,
    };

SharedCalendarCourseData _$SharedCalendarCourseDataFromJson(
        Map<String, dynamic> json) =>
    SharedCalendarCourseData(
      courseName: json['course_name'] as String,
      roomName: json['room_name'] as String,
      startTimeHour: (json['start_time_hour'] as num).toInt(),
      startTimeMinute: (json['start_time_minute'] as num).toInt(),
      endTimeHour: (json['end_time_hour'] as num).toInt(),
      endTimeMinute: (json['end_time_minute'] as num).toInt(),
      weekType: json['week_type'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
    );

Map<String, dynamic> _$SharedCalendarCourseDataToJson(
        SharedCalendarCourseData instance) =>
    <String, dynamic>{
      'course_name': instance.courseName,
      'room_name': instance.roomName,
      'start_time_hour': instance.startTimeHour,
      'start_time_minute': instance.startTimeMinute,
      'end_time_hour': instance.endTimeHour,
      'end_time_minute': instance.endTimeMinute,
      'week_type': instance.weekType,
      'day_of_week': instance.dayOfWeek,
    };
