import 'package:flutter/material.dart';
import '../models/calendar_data.dart';
import '../services/storage_service.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/mood_selector.dart';
import '../widgets/month_header.dart';
import '../widgets/reset_dialog.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalController.jumpTo(0);
    });
  }

  Future<void> _loadColors() async {
    final colors = await _storageService.loadColors();
    setState(() {
      _calendarData.savedColors.clear();
      _calendarData.savedColors.addAll(colors);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarSection(),
          _buildMoodSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Calendar',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ResetDialog(onReset: _resetAllColors),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }
}
