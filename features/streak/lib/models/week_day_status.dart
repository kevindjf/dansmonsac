/// Status of a day in the weekly streak view
///
/// Used to determine the visual representation of each day in the week.
enum WeekDayStatus {
  /// Day where bag was completed (green checkmark)
  completed,

  /// School day that was missed (empty circle)
  missed,

  /// Non-school day like weekend or holiday (greyed out)
  inactive,

  /// Future day that hasn't happened yet (empty circle)
  future,
}
