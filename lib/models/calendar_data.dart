import 'package:flutter/material.dart';
import '../models/mood_color.dart';

class CalendarData {
  final int year;
  Map<String, Color> savedColors;

  CalendarData({
    int? year,
    Map<String, Color>? savedColors,
  })  : year = year ?? DateTime.now().year,
        savedColors = savedColors ?? {};

  String getKey(int day, int month) {
    final adjustedMonth = month - 1;
    return '$year-$adjustedMonth-$day';
  }

  bool shouldResetCalendar({DateTime? testDate}) {
    final now = testDate ?? DateTime.now();
    if (now.year > year) {
      print('Year changed from $year to ${now.year}');
      return true;
    }
    return false;
  }

  Color? getSavedColor(int day, int month) {
    final key = getKey(day, month);
    final savedColor = savedColors[key];

    if (savedColor != null) {
      print('Retrieved color for $key: $savedColor');
      return savedColor;
    }
    return null;
  }

  // 색상 업데이트 메서드 추가
  void updateColors(Map<String, Color> newColors) {
    savedColors = Map.from(newColors);
  }

  int getDaysInMonth(int month) {
    return DateTime(year, month + 1, 0).day;
  }

  bool isToday(int day, int month) {
    final now = DateTime.now();
    return day == now.day && month == now.month - 1;
  }

  Map<String, Color> get moodColors => MoodColor.moodColors;

  // 11월, 12월 데이터 정리
  void cleanupData() {
    final keysToRemove = savedColors.keys.where((key) {
      final parts = key.split('-');
      final month = int.parse(parts[1]);
      return parts.length == 3 && month >= 12;
    }).toList();

    for (var key in keysToRemove) {
      savedColors.remove(key);
    }
  }
}
