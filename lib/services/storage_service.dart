import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

class CalendarRecord {
  final File imageFile;
  final int year;

  CalendarRecord({required this.imageFile, required this.year});
}

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

  Future<void> saveCalendarRecord(int year, Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final recordsDir = Directory('${directory.path}/calendar_records');
    if (!await recordsDir.exists()) {
      await recordsDir.create();
    }

    final fileName = 'calendar_$year.png';
    final file = File('${recordsDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);
  }

  Future<List<CalendarRecord>> loadCalendarRecords() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordsDir = Directory('${directory.path}/calendar_records');

    if (!await recordsDir.exists()) {
      return [];
    }

    final records = <CalendarRecord>[];
    final files = await recordsDir.list().toList();

    for (var entity in files) {
      if (entity is File && entity.path.endsWith('.png')) {
        final fileName = entity.path.split('/').last;
        final year = int.parse(fileName.split('_')[1].split('.')[0]);
        records.add(CalendarRecord(imageFile: entity, year: year));
      }
    }

    return records..sort((a, b) => b.year.compareTo(a.year));
  }

  Future<void> addDummyRecords() async {
    // 2022년 데이터
    final dummy2022 = await _createDummyCalendarImage(2022, Colors.blue);
    await saveCalendarRecord(2022, dummy2022);

    // 2023년 데이터
    final dummy2023 = await _createDummyCalendarImage(2023, Colors.green);
    await saveCalendarRecord(2023, dummy2023);
  }

  Future<Uint8List> _createDummyCalendarImage(int year, Color baseColor) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const cellSize = 12.0;
    const width = 12 * cellSize + 100; // 범례를 위한 추가 공간
    const height = 31 * cellSize;

    // 흰색 배경
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);

    // 그리드 그리기
    for (int month = 0; month < 12; month++) {
      for (int day = 1; day <= 31; day++) {
        if (day <= DateTime(year, month + 1, 0).day) {
          final rect = Rect.fromLTWH(
            month * cellSize,
            (day - 1) * cellSize,
            cellSize - 1,
            cellSize - 1,
          );

          // 랜덤하게 셀 색상 지정
          final random = Random();
          final colors = [
            const Color(0xFFFFB7ED), // perfect
            const Color(0xFFFFD9B7), // great
            const Color(0xFFB7FFD8), // good
            const Color(0xFFFFB7B7), // angry
            const Color(0xFFB7E5FF), // sad
            const Color(0xFFE0E0E0), // tired
            const Color(0xFFFFFDB7), // surprised
          ];

          if (random.nextDouble() < 0.3) {
            // 30% 확률로 색상 채우기
            paint.color = colors[random.nextInt(colors.length)];
            canvas.drawRect(rect, paint);
          } else {
            paint.color = Colors.white;
            canvas.drawRect(rect, paint);
          }

          // 테두리 그리기
          paint.color = Colors.grey[300]!;
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 0.5;
          canvas.drawRect(rect, paint);
          paint.style = PaintingStyle.fill;
        }
      }
    }

    // 연도 표시
    final textPainter = TextPainter(
      text: TextSpan(
        text: year.toString(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.normal,
          color: Colors.black,
          fontFamily: 'Bungee',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(12 * cellSize + 16, 16));

    // 범례 그리기
    final legends = [
      {'text': 'PERFECT', 'color': const Color(0xFFFFB7ED)},
      {'text': 'GREAT', 'color': const Color(0xFFFFD9B7)},
      {'text': 'GOOD', 'color': const Color(0xFFB7FFD8)},
      {'text': 'ANGRY', 'color': const Color(0xFFFFB7B7)},
      {'text': 'SAD', 'color': const Color(0xFFB7E5FF)},
      {'text': 'TIRED', 'color': const Color(0xFFE0E0E0)},
      {'text': 'SURPRISE', 'color': const Color(0xFFFFFDB7)},
    ];

    double legendY = 60.0;
    for (var legend in legends) {
      // 색상 상자
      paint.color = legend['color'] as Color;
      canvas.drawRect(
        Rect.fromLTWH(12 * cellSize + 16, legendY, 12, 12),
        paint,
      );

      // 텍스트
      final legendPainter = TextPainter(
        text: TextSpan(
          text: legend['text'] as String,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            fontFamily: 'Bungee',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      legendPainter.layout();
      legendPainter.paint(canvas, Offset(12 * cellSize + 36, legendY));

      legendY += 24; // 다음 범례 위치
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> addDummyCustomColors() async {
    final dummyColors = {
      'Happy': const Color(0xFFFFD700),
      'Excited': const Color(0xFFFF4500),
      'Peaceful': const Color(0xFF98FB98),
    };
    await saveCustomColors(dummyColors);
  }

  Future<void> deleteCalendarRecord(int year) async {
    final directory = await getApplicationDocumentsDirectory();
    final recordsDir = Directory('${directory.path}/calendar_records');
    final fileName = 'calendar_$year.png';
    final file = File('${recordsDir.path}/$fileName');

    if (await file.exists()) {
      await file.delete();
      print('Deleted calendar record for year $year');
    }
  }
}
