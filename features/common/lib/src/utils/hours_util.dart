import 'package:intl/intl.dart';

class FormatterDate {

  static formatHour(DateTime time) {
    return DateFormat("H'h'mm").format(time);
  }

  static formatHours(DateTime startTime, DateTime endTime){
    return "${FormatterDate.formatHour(startTime)} - ${FormatterDate.formatHour(endTime)}";
  }
}
