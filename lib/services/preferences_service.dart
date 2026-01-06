import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyPackTimeHour = 'pack_time_hour';
  static const String _keyPackTimeMinute = 'pack_time_minute';
  static const String _keySchoolYearStart = 'school_year_start';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyAccentColor = 'accent_color';

  static Future<void> setPackTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPackTimeHour, time.hour);
    await prefs.setInt(_keyPackTimeMinute, time.minute);
  }

  static Future<TimeOfDay> getPackTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyPackTimeHour) ?? 19;
    final minute = prefs.getInt(_keyPackTimeMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<void> setSchoolYearStart(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySchoolYearStart, date.toIso8601String());
  }

  static Future<DateTime> getSchoolYearStart() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keySchoolYearStart);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    // Default: September 1st of current school year
    final now = DateTime.now();
    final year = now.month >= 9 ? now.year : now.year - 1;
    return DateTime(year, 9, 1);
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? false;
  }

  static Future<void> setAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAccentColor, color.value);
  }

  static Future<Color> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyAccentColor);
    if (colorValue != null) {
      return Color(colorValue);
    }
    // Default color (purple)
    return const Color(0xFF9C27B0);
  }
}
