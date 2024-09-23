

import 'package:intl/intl.dart';

class DateTimeUtil {
  static String dateTimeNowIso() => DateTime.now().toIso8601String();

  static int dateTimeNowMilli() => DateTime.now().millisecondsSinceEpoch;

  static DateFormat format() => DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatDisplay(int timeStamp, String format) {
    return DateFormat(format)
        .format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
  }

  static DateTime getStartOfThisDay([DateTime? picked]) {
    final DateTime now = picked ?? DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    return startOfToday.toUtc();
  }

  static DateTime getEndOfThisDay([DateTime? picked]) {
    final DateTime now = picked ?? DateTime.now();
    final DateTime tomorrow = now.add(Duration(days: 1));
    final DateTime endOfToday =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day)
            .subtract(Duration(seconds: 1));
    return endOfToday.toUtc();
  }

  static int convertHHmmTimeToBusinessHour(String? time) {
    var now = DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    var todayString = '${formatter.format(now)} ${time}:00';
    var tDatetime = DateTime.parse(todayString);
    return (tDatetime.hour * 2) + (tDatetime.minute / 30).ceil();
  }

  static String convertBusinessHourToTimeString(int businessHour) {
    var minute = (businessHour % 2) * 30;
    var hour = (businessHour / 2).floor();
    var hourString = hour >= 10 ? hour.toString() : '0${hour.toString()}';
    var minuteString = minute != 0 ? minute.toString() : '00';
    return '${hourString}:${minuteString}';
  }
}
