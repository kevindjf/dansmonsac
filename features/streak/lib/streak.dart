/// Streak module - Habit tracking and motivation
///
/// Provides widgets and functionality for tracking consecutive days
/// of bag preparation completion.
library;

// Export presentation widgets
export 'presentation/widgets/streak_counter_widget.dart';
export 'presentation/widgets/streak_break_dialog.dart';
export 'presentation/widgets/weekly_streak_row.dart';
export 'presentation/widgets/animated_flame.dart';

// Export presentation pages
export 'presentation/pages/streak_detail_page.dart';

// Export models
export 'models/week_day_status.dart';

// Export providers for external use
export 'di/riverpod_di.dart';
