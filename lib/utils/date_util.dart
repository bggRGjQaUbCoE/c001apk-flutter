// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

class DateUtil {
  static const int ONE_MINUTE = 60;
  static const int ONE_HOUR = 3600;
  static const int ONE_DAY = 86400;
  static const int ONE_MONTH = 2592000;
  static const int ONE_YEAR = 31104000;

  static String fromToday(dynamic rawTime) {
    if (rawTime == null) {
      return '';
    }

    int time = rawTime is int ? rawTime : int.parse(rawTime);

    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int ago = now - time;

    if (ago == 0) {
      return "刚刚";
    } else if (ago < 60) {
      return "$ago秒前";
    } else if (ago <= ONE_HOUR) {
      return "${ago ~/ ONE_MINUTE}分钟前";
    } else if (ago <= ONE_DAY) {
      return "${ago ~/ ONE_HOUR}小时前";
    } else if (ago <= ONE_DAY * 2) {
      return "1天前";
    } else if (ago <= ONE_DAY * 3) {
      return "2天前";
    } else if (ago <= ONE_MONTH) {
      final int day = ago ~/ ONE_DAY;
      return "$day天前";
    } else {
      final date = DateTime.fromMillisecondsSinceEpoch(time * 1000);
      final DateFormat sdf = date.year == DateTime.now().year
          ? DateFormat('M月d日')
          : DateFormat('yyyy年M月d日');
      return sdf.format(date);
    }
  }
}
