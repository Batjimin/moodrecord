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
        if (contents.isNotEmpty) {
          try {
            allColors = json.decode(contents) as Map<String, dynamic>;

            // 중복 키 정리 (예: 2025-0-17과 2025-1-17)
            final parts = key.split('-');
            if (parts.length == 3) {
              final year = parts[0];
              final day = parts[2];
              // 같은 년도와 일자를 가진 모든 키 제거
              allColors.removeWhere(
                  (k, v) => k.startsWith('$year-') && k.endsWith('-$day'));
            }
          } catch (e) {
            debugPrint('Error decoding JSON: $e');
            allColors = {};
          }
        }
      }

      // 새로운 색상 저장
      allColors[key] = color.value.toString();

      final jsonString = json.encode(allColors);
      await file.writeAsString(jsonString);
      debugPrint('Successfully saved color - Key: $key, JSON: $jsonString');
    } catch (e) {
      debugPrint('Error in saveColor: $e');
    }
  }

  Future<Map<String, Color>> loadColors() async {
    try {
      final file = await _localFile;
      final Map<String, Color> savedColors = {};

      if (await file.exists()) {
        final String contents = await file.readAsString();
        if (contents.isNotEmpty) {
          try {
            final Map<String, dynamic> allColors =
                json.decode(contents) as Map<String, dynamic>;
            allColors.forEach((key, value) {
              try {
                final colorValue = int.parse(value.toString());
                savedColors[key] = Color(colorValue);
              } catch (e) {
                debugPrint('Error parsing color value: $e');
              }
            });
          } catch (e) {
            debugPrint('Error decoding JSON: $e');
            // 파일이 손상된 경우 초기화
            await file.writeAsString('{}');
          }
        }
      }

      return savedColors;
    } catch (e) {
      debugPrint('Error in loadColors: $e');
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
