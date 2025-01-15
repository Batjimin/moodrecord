import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String STORAGE_KEY = 'mood_colors.json';
  static const String CUSTOM_COLORS_KEY = 'custom_mood_colors.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$STORAGE_KEY');
  }

  Future<void> saveColor(String key, Color color) async {
    try {
      final file = await _localFile;
      Map<String, dynamic> allColors = {};

      if (await file.exists()) {
        final String contents = await file.readAsString();
        allColors = Map<String, dynamic>.from(json.decode(contents));
      }

      allColors[key] = color.value.toString();
      await file.writeAsString(json.encode(allColors));
      print('Saved color for $key: ${color.value}');
    } catch (e) {
      print('Error saving color: $e');
    }
  }

  Future<Map<String, Color>> loadColors() async {
    try {
      final file = await _localFile;
      final Map<String, Color> savedColors = {};

      if (await file.exists()) {
        final String contents = await file.readAsString();
        final Map<String, dynamic> allColors =
            Map<String, dynamic>.from(json.decode(contents));

        allColors.forEach((key, value) {
          try {
            final colorValue = int.parse(value);
            savedColors[key] = Color(colorValue);
            print('Loaded color for $key: ${Color(colorValue)}');
          } catch (e) {
            print('Error parsing color for key $key: $e');
          }
        });
      }

      return savedColors;
    } catch (e) {
      print('Error loading colors: $e');
      return {};
    }
  }

  Future<void> resetAllColors() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error resetting colors: $e');
    }
  }

  Future<void> updateColorMapping(Color oldColor, Color newColor) async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final String contents = await file.readAsString();
        final Map<String, dynamic> allColors =
            Map<String, dynamic>.from(json.decode(contents));

        bool hasUpdates = false;
        // 모든 저장된 색상을 확인하고 업데이트
        allColors.forEach((key, value) {
          if (int.parse(value) == oldColor.value) {
            allColors[key] = newColor.value.toString();
            hasUpdates = true;
            print(
                'Updated color for $key: ${oldColor.value} -> ${newColor.value}');
          }
        });

        if (hasUpdates) {
          // 변경된 내용을 파일에 저장
          await file.writeAsString(json.encode(allColors));
          print('Saved updated colors to file');
        }
      }
    } catch (e) {
      print('Error updating color mapping: $e');
    }
  }

  Future<void> saveCustomColors(Map<String, Color> colors) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$CUSTOM_COLORS_KEY');

      final Map<String, String> colorMap = {};
      colors.forEach((key, value) {
        colorMap[key] = value.value.toString();
      });

      await file.writeAsString(json.encode(colorMap));
    } catch (e) {
      print('Error saving custom colors: $e');
    }
  }

  Future<Map<String, Color>> loadCustomColors() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$CUSTOM_COLORS_KEY');

      if (await file.exists()) {
        final String contents = await file.readAsString();
        final Map<String, dynamic> colorMap = json.decode(contents);

        final Map<String, Color> customColors = {};
        colorMap.forEach((key, value) {
          customColors[key] = Color(int.parse(value));
        });

        return customColors;
      }
      return {};
    } catch (e) {
      print('Error loading custom colors: $e');
      return {};
    }
  }
}
