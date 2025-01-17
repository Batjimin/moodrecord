import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class MoodColor {
  static Map<String, Color> _defaultColors = {
    'PERFECT': const Color(0xFFFFB7ED),
    'GREAT': const Color(0xFFFFD9B7),
    'GOOD': const Color(0xFFB7FFD8),
    'ANGRY': const Color(0xFFFFB7B7),
    'SAD': const Color(0xFFB7E5FF),
    'TIRED': const Color(0xFFE0E0E0),
    'SURPRISE': const Color(0xFFFFFDB7),
  };

  static Map<String, Color> get moodColors => _defaultColors;

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

  static void updateColors(Map<String, Color> colors) async {
    for (var oldEntry in _defaultColors.entries) {
      final newColor = colors[oldEntry.key];
      if (newColor != null && newColor != oldEntry.value) {
        final storageService = StorageService();
        await storageService.updateColorMapping(oldEntry.value, newColor);
      }
    }

    _defaultColors = colors;
    for (var listener in _listeners) {
      listener();
    }
  }

  static Future<void> initializeColors() async {
    final StorageService storageService = StorageService();
    final savedColors = await storageService.loadCustomColors();
    if (savedColors.isNotEmpty) {
      updateColors(savedColors);
    }
  }
}
