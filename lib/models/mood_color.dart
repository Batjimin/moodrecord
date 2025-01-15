import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class MoodColor {
  static Map<String, Color> _moodColors = {
    'perfect': const Color(0xFFFFB7ED),
    'great': const Color(0xFFFFD9B7),
    'good': const Color(0xFFB7FFD8),
    'angry': const Color(0xFFFFB7B7),
    'sad': const Color(0xFFB7E5FF),
    'tired': const Color(0xFFE0E0E0),
    'surprised': const Color(0xFFFFFDB7),
  };

  static Map<String, Color> get moodColors => _moodColors;

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

  static final List<Function> _listeners = [];

  static void addListener(Function listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function listener) {
    _listeners.remove(listener);
  }

  static void updateColors(Map<String, Color> colors) {
    _moodColors = colors;
    for (var listener in _listeners) {
      listener();
    }
  }

  static Future<void> initializeColors() async {
    final StorageService storageService = StorageService();
    final savedColors = await storageService.loadCustomColors();
    if (savedColors.isNotEmpty) {
      _moodColors = savedColors;
      for (var listener in _listeners) {
        listener();
      }
    }
  }
}
