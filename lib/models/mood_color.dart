import 'package:flutter/material.dart';

class MoodColor {
  static Map<String, Color> moodColors = {
    'perfect': const Color(0xFFFFB7ED),
    'great': const Color(0xFFFFD9B7),
    'good': const Color(0xFFB7FFD8),
    'angry': const Color(0xFFFFB7B7),
    'sad': const Color(0xFFB7E5FF),
    'tired': const Color(0xFFE0E0E0),
    'surprised': const Color(0xFFFFFDB7),
  };

  static const List<String> months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];
}
