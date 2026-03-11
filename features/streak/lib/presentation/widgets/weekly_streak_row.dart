import 'package:flutter/material.dart';
import 'package:streak/models/week_day_status.dart';

/// Weekly streak row widget showing 7 days with visual status indicators
///
/// Displays Monday through Sunday with:
/// - Green filled circle + checkmark for completed days
/// - Empty circle with border for missed/future days
/// - Greyed-out circle for inactive days (weekends, holidays)
/// - Day label below each circle (Lun, Mar, Mer, Jeu, Ven, Sam, Dim)
/// - Current day is visually distinguished with a thicker border
///
/// Meets accessibility standards:
/// - Minimum 44x44pt touch targets
/// - WCAG AA contrast ratios
/// - Semantic labels for screen readers
class WeeklyStreakRow extends StatelessWidget {
  /// List of 7 day statuses (Monday to Sunday)
  final List<WeekDayStatus> statuses;

  const WeeklyStreakRow({
    super.key,
    required this.statuses,
  }) : assert(statuses.length == 7, 'Must provide exactly 7 day statuses');

  /// French day labels (Monday to Sunday)
  static const List<String> _dayLabels = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate which day is today (0 = Monday, 6 = Sunday)
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // weekday is 1-7 (Mon-Sun), we need 0-6

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isToday = index == todayIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildDayColumn(
              context,
              statuses[index],
              _dayLabels[index],
              isToday,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayColumn(
    BuildContext context,
    WeekDayStatus status,
    String label,
    bool isToday,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label:
          '$label, ${_getStatusLabel(status)}${isToday ? ", aujourd'hui" : ""}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day circle with today indicator
          Stack(
            alignment: Alignment.center,
            children: [
              // Day circle
              _buildDayCircle(context, status),
            ],
          ),

          const SizedBox(height: 6),

          // Day label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: status == WeekDayStatus.inactive
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : (isToday ? colorScheme.secondary : Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(WeekDayStatus status) {
    switch (status) {
      case WeekDayStatus.completed:
        return 'sac préparé';
      case WeekDayStatus.missed:
        return 'jour manqué';
      case WeekDayStatus.inactive:
        return 'pas de cours';
      case WeekDayStatus.future:
        return 'à venir';
    }
  }

  Widget _buildDayCircle(BuildContext context, WeekDayStatus status) {
    const double circleSize = 44.0; // Min 44x44pt for accessibility
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case WeekDayStatus.completed:
        // Completed circle with checkmark (uses theme color)
        return Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: const Color(
                0xFF4CAF50), // Green for completed (universal color)
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 24,
          ),
        );

      case WeekDayStatus.missed:
      case WeekDayStatus.future:
        // Empty circle with border (neutral)
        return Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        );

      case WeekDayStatus.inactive:
        // Greyed-out filled circle (non-school days)
        return Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        );
    }
  }
}
