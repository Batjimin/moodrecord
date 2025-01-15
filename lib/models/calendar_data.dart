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
    final adjustedMonth = month + 1;
    return '${currentYear.year}-$adjustedMonth-$day';
  }

  Color? getSavedColor(int day, int month) {
    final key = getKey(day, month);
    final savedColor = savedColors[key];
    print('Getting color for $key: $savedColor'); // 디버깅용
    return savedColor;
  }

  // 색상 업데이트 메서드 추가
  void updateColors(Map<String, Color> newColors) {
    savedColors = Map.from(newColors);
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
