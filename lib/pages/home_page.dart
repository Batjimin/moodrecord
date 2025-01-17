import 'package:flutter/material.dart';
import '../models/calendar_data.dart';
import '../services/storage_service.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/mood_selector.dart';
import '../widgets/month_header.dart';
import '../widgets/share_preview_dialog.dart';
import '../models/mood_color.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import './gallery_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _horizontalController = ScrollController();
  final StorageService _storageService = StorageService();
  final CalendarData _calendarData = CalendarData();

  int currentStartColumn = 0;
  Color? selectedMoodColor;
  final double columnWidth = 50.0;
  final double sideMargin = 45.0;

  @override
  void initState() {
    super.initState();
    _loadColors();
    _initializeCustomColors();
    MoodColor.addListener(_onMoodColorsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalController.jumpTo(0);
      _checkNewYear();
    });
  }

  Future<void> _loadColors() async {
    final colors = await _storageService.loadColors();
    if (mounted) {
      setState(() {
        _calendarData.updateColors(colors);
      });
    }
  }

  Future<void> _saveColor(int day, int month, Color color) async {
    final key = _calendarData.getKey(day, month);
    await _storageService.saveColor(key, color);
    setState(() {
      _calendarData.savedColors[key] = color;
    });
  }

  void _scrollHorizontally(bool toRight) {
    int newStartColumn = toRight
        ? (currentStartColumn + 1).clamp(0, 11)
        : (currentStartColumn - 1).clamp(0, 11);

    if (newStartColumn != currentStartColumn) {
      setState(() {
        currentStartColumn = newStartColumn;
      });

      double targetScroll = newStartColumn == 11
          ? 11.2 * (columnWidth + 2)
          : newStartColumn * (columnWidth + 2);

      _horizontalController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _resetAllColors() async {
    await _storageService.resetAllColors();
    setState(() {
      _calendarData.savedColors.clear();
      selectedMoodColor = null;
    });
  }

  Future<void> _initializeCustomColors() async {
    await MoodColor.initializeColors();
    setState(() {}); // UI 업데이트를 위해 setState 호출
  }

  void _onMoodColorsChanged() async {
    final colors = await _storageService.loadColors();
    setState(() {
      _calendarData.updateColors(colors);
    });
  }

  Future<void> _checkNewYear() async {
    final now = DateTime.now();
    if (now.month == 1 && now.day == 1) {
      // 작년 달력 저장
      await _saveCalendarImage(yearOffset: -1);
      // 달력 초기화
      await _resetAllColors();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Happy New Year! Previous calendar has been saved.')),
        );
      }
    }
  }

  Future<void> _saveCalendarImage({int yearOffset = 0}) async {
    try {
      final targetYear = DateTime.now().year + yearOffset;
      final directory = await getApplicationDocumentsDirectory();
      final savedImagesDir = Directory('${directory.path}/saved_calendars');

      if (await savedImagesDir.exists()) {
        final files = await savedImagesDir.list().toList();
        final existingFile = files
            .whereType<File>()
            .where((file) => file.path.contains('calendar_$targetYear'))
            .firstOrNull;

        if (existingFile != null && mounted) {
          final shouldReplace = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Replace Existing Calendar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Calendar for $targetYear already exists. Do you want to replace it?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Replace',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          );

          if (shouldReplace != true) return;
          await existingFile.delete();
        }
      } else {
        await savedImagesDir.create(recursive: true);
      }

      final boundary = GlobalKey();
      final previewWidget = RepaintBoundary(
        key: boundary,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 24.0,
            horizontal: 8.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPaint(
                size: const Size(144, 372),
                painter: CalendarPreviewPainter(
                  calendarData: _calendarData,
                  cellSize: 12.0,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateTime.now().year + yearOffset}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...MoodColor.moodColors.entries.map((entry) => Padding(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      );

      final overlay = OverlayEntry(
        builder: (context) => Positioned(
          left: -99999,
          child: previewWidget,
        ),
      );

      Overlay.of(context).insert(overlay);
      await Future.delayed(const Duration(milliseconds: 100));

      final renderObject =
          boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (renderObject == null) {
        overlay.remove();
        return;
      }

      final image = await renderObject.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      overlay.remove();

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final file = File('${savedImagesDir.path}/calendar_$targetYear.png');
        await file.writeAsBytes(bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calendar saved successfully')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GalleryPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save calendar: $e')),
        );
      }
    }
  }

  Widget _buildCalendarSection() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: currentStartColumn > 0
                      ? () => _scrollHorizontally(false)
                      : null,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        SizedBox(width: sideMargin),
                        CalendarGrid(
                          calendarData: _calendarData,
                          currentStartColumn: currentStartColumn,
                          columnWidth: columnWidth,
                          selectedMoodColor: selectedMoodColor,
                          onColorSelected: _saveColor,
                        ),
                        SizedBox(width: sideMargin * 1.8),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: currentStartColumn < 11
                      ? () => _scrollHorizontally(true)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthHeader(currentStartColumn: currentStartColumn),
          const SizedBox(height: 24),
          MoodSelector(
            onMoodSelected: (color) =>
                setState(() => selectedMoodColor = color),
            onSaveColor: _saveColor,
            onReset: _resetAllColors,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    MoodColor.removeListener(_onMoodColorsChanged);
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${DateTime.now().year}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SharePreviewDialog(
                  calendarData: _calendarData,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.black54),
            onPressed: () async {
              await _saveCalendarImage();
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarSection(),
          _buildMoodSection(),
        ],
      ),
    );
  }
}
