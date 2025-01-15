import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../models/calendar_data.dart';
import '../models/mood_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class SharePreviewDialog extends StatelessWidget {
  final CalendarData calendarData;
  final double cellSize = 12.0;
  final GlobalKey _boundaryKey = GlobalKey();

  SharePreviewDialog({
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
                    'SHARE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 8.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                          const SizedBox(width: 12),
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
                              const SizedBox(height: 12),
                              ..._buildLegend(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCLE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _saveToClipboard(BuildContext context) async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/mood_calendar.png');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Mood Calendar',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
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
