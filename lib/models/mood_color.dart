import 'package:flutter/material.dart';

class MoodColor {
  static const Map<String, Color> moodColors = {
    'perfect': Color(0xFFFFB7ED),
    'great': Color(0xFFFFD9B7),
    'good': Color(0xFFB7FFD8),
    'angry': Color(0xFFFFB7B7),
    'sad': Color(0xFFB7E5FF),
    'tired': Color(0xFFE0E0E0),
    'surprised': Color(0xFFFFFDB7),
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
