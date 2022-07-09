import 'package:intl/intl.dart';

class Utility {
  String convertEpochToUtc(int time) {
    time = time * 1000;
    DateFormat dateFormat = DateFormat('dd LLLL');
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
    return dateFormat.format(date.toLocal());
  }

  String extractDay(int time) {
    time = time * 1000;
    DateFormat dayformat = DateFormat('EEEEE', 'en_US');
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    var currentDate = dateFormat.format(DateTime.now());
    var receivedDate = dateFormat.format(date);
    if (currentDate == receivedDate) {
      return 'Today';
    }
    return dayformat.format(date);
  }
}