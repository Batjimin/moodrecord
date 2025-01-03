import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String STORAGE_KEY = 'mood_colors.json';

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
          final colorValue = int.parse(value);
          savedColors[key] = Color(colorValue);
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
}
