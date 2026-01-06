import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyPackTimeHour = 'pack_time_hour';
  static const String _keyPackTimeMinute = 'pack_time_minute';
  static const String _keySchoolYearStart = 'school_year_start';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyAccentColor = 'accent_color';
  static const String _keySupplyCheckedState = 'supply_checked_state_';

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

  /// Save supply checked state for a specific date
  static Future<void> saveSupplyCheckedState(DateTime date, Map<String, bool> checkedState) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDateKey(date);
    final jsonString = json.encode(checkedState);
    await prefs.setString('$_keySupplyCheckedState$dateKey', jsonString);
  }

  /// Load supply checked state for a specific date
  static Future<Map<String, bool>> loadSupplyCheckedState(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDateKey(date);
    final jsonString = prefs.getString('$_keySupplyCheckedState$dateKey');

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value as bool));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  /// Clear old supply checked states (keep only last 7 days)
  static Future<void> clearOldSupplyStates() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_keySupplyCheckedState)) {
        // Extract date from key and check if it's older than 7 days
        try {
          final dateStr = key.substring(_keySupplyCheckedState.length);
          final date = DateTime.parse(dateStr);
          if (now.difference(date).inDays > 7) {
            await prefs.remove(key);
          }
        } catch (e) {
          // Invalid key format, skip
        }
      }
    }
  }

  /// Format date as key (yyyy-MM-dd)
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
