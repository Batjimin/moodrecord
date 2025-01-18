import 'package:flutter/material.dart';
import '../models/mood_color.dart';

class CalendarData {
  final DateTime currentYear;
  Map<String, Color> savedColors;

  CalendarData({
    DateTime? currentYear,
    Map<String, Color>? savedColors,
  })  : currentYear = currentYear ?? DateTime.now(),
        savedColors = savedColors ?? {};

  String getKey(int day, int month) {
    if (month < 1 || month > 12) {
      debugPrint('Invalid month value: $month, adjusting...');
      month = month.clamp(1, 12);
    }
    return '${currentYear.year}-$month-$day';
  }

  Color? getSavedColor(int day, int month) {
    if (month < 1 || month > 12) {
      debugPrint('Invalid month value in getSavedColor: $month');
      month = month.clamp(1, 12);
    }
    final key = getKey(day, month);
    debugPrint('Getting color for key: $key');
    return savedColors[key];
  }

  // 색상 업데이트 메서드 추가
  void updateColors(Map<String, Color> newColors) {
    debugPrint('Updating calendar colors: $newColors');
    savedColors = Map<String, Color>.from(newColors);
  }

  int getDaysInMonth(int month) {
    return DateTime(currentYear.year, month + 1, 0).day;
  }

  bool isToday(int day, int month) {
    final now = DateTime.now();
    return day == now.day && month == now.month - 1;
  }

  Map<String, Color> get moodColors => MoodColor.moodColors;
}
