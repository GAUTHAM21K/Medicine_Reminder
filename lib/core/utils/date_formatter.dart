import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }
}
