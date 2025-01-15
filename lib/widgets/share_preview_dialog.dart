import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/calendar_data.dart';
import '../models/mood_color.dart';

class SharePreviewDialog extends StatelessWidget {
  final CalendarData calendarData;
  final double cellSize = 12.0;

  const SharePreviewDialog({
    super.key,
    required this.calendarData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomPaint(
                    size: Size(12 * cellSize, 31 * cellSize),
                    painter: CalendarPreviewPainter(
                      calendarData: calendarData,
                      cellSize: cellSize,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateTime.now().year}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildLegend(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await _saveToClipboard(context);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLegend() {
    return MoodColor.moodColors.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              color: entry.value,
            ),
            const SizedBox(width: 8),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _saveToClipboard(BuildContext context) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(12 * cellSize, 31 * cellSize);

    final painter = CalendarPreviewPainter(
      calendarData: calendarData,
      cellSize: cellSize,
    );
    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (12 * cellSize).toInt(),
      (31 * cellSize).toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    // TODO: Implement save functionality
  }
}

class CalendarPreviewPainter extends CustomPainter {
  final CalendarData calendarData;
  final double cellSize;

  CalendarPreviewPainter({
    required this.calendarData,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw grid
    for (int month = 0; month < 12; month++) {
      for (int day = 1; day <= 31; day++) {
        if (day <= calendarData.getDaysInMonth(month)) {
          final rect = Rect.fromLTWH(
            month * cellSize,
            (day - 1) * cellSize,
            cellSize - 1,
            cellSize - 1,
          );

          // Draw cell background
          final color = calendarData.getSavedColor(day, month + 1);
          paint.color = color ?? Colors.white;
          canvas.drawRect(rect, paint);

          // Draw border
          paint.color = Colors.grey[300]!;
          paint.style = PaintingStyle.stroke;
          canvas.drawRect(rect, paint);
          paint.style = PaintingStyle.fill;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
