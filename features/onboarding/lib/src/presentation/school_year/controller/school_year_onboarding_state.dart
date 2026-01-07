import 'package:flutter/material.dart';

class SchoolYearOnboardingState {
  final DateTime schoolYearStart;
  final bool isLoading;

  SchoolYearOnboardingState({
    required this.schoolYearStart,
    this.isLoading = false,
  });

  SchoolYearOnboardingState copyWith({
    DateTime? schoolYearStart,
    bool? isLoading,
  }) {
    return SchoolYearOnboardingState(
      schoolYearStart: schoolYearStart ?? this.schoolYearStart,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get first Monday of September for current school year
  static DateTime getDefaultSchoolYearStart() {
    final now = DateTime.now();
    // If we're before September, use last year's September
    // If we're after or in September, use this year's September
    final year = now.month >= 9 ? now.year : now.year - 1;

    // Start from September 1st
    var date = DateTime(year, 9, 1);

    // Find first Monday (weekday 1 = Monday)
    while (date.weekday != DateTime.monday) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }
}
