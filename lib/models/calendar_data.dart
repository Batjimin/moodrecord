import 'package:flutter/material.dart';

class CalendarData {
  final DateTime currentYear;
  final Map<String, Color> savedColors;

  CalendarData({
    DateTime? currentYear,
    Map<String, Color>? savedColors,
  })  : currentYear = currentYear ?? DateTime.now(),
        savedColors = savedColors ?? {};

  String getKey(int day, int month) => '${currentYear.year}-$month-$day';

  Color? getSavedColor(int day, int month) {
    final key = getKey(day, month);
    return savedColors[key];
  }

  int getDaysInMonth(int month) {
    return DateTime(currentYear.year, month + 1, 0).day;
  }

  bool isToday(int day, int month) {
    final now = DateTime.now();
    return day == now.day && month == now.month - 1;
  }
}
