import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy, h:mm a').format(dateTime);
  }
}
