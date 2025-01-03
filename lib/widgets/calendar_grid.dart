import 'package:flutter/material.dart';
import '../models/calendar_data.dart';
import '../models/mood_color.dart';

class CalendarGrid extends StatelessWidget {
  final CalendarData calendarData;
  final int currentStartColumn;
  final double columnWidth;
  final Color? selectedMoodColor;
  final Function(int day, int month, Color color) onColorSelected;

  const CalendarGrid({
    super.key,
    required this.calendarData,
    required this.currentStartColumn,
    required this.columnWidth,
    required this.selectedMoodColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(31, (row) {
          return Row(
            children: List.generate(12, (col) {
              int daysInMonth = calendarData.getDaysInMonth(col + 1);
              bool isValidDay = row < daysInMonth;
              bool isToday = calendarData.isToday(row + 1, col);

              return GestureDetector(
                onTap: isValidDay && isToday
                    ? () {
                        if (selectedMoodColor != null) {
                          onColorSelected(row + 1, col + 1, selectedMoodColor!);
                        }
                      }
                    : null,
                child: _buildCalendarCell(row, col, isValidDay, isToday),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarCell(int row, int col, bool isValidDay, bool isToday) {
    return Container(
      width: columnWidth,
      height: 50,
      margin: const EdgeInsets.all(1),
      decoration: isValidDay
          ? BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 0.5,
              ),
              color: _getCellColor(row, col, isToday),
            )
          : null,
      child: _buildCellContent(row, col, isValidDay),
    );
  }

  Color _getCellColor(int row, int col, bool isToday) {
    if (isToday) {
      return selectedMoodColor ??
          calendarData.getSavedColor(row + 1, col + 1) ??
          Colors.white;
    }
    return MoodColor.months[currentStartColumn] == MoodColor.months[col]
        ? calendarData.getSavedColor(row + 1, col + 1) ?? Colors.white
        : Colors.white;
  }

  Widget? _buildCellContent(int row, int col, bool isValidDay) {
    if (!isValidDay ||
        MoodColor.months[currentStartColumn] != MoodColor.months[col]) {
      return null;
    }

    bool hasColor = calendarData.getSavedColor(row + 1, col + 1) != null;
    bool isTodayWithColor = calendarData.isToday(row + 1, col) &&
        (selectedMoodColor != null || hasColor);

    return Center(
      child: Text(
        '${row + 1}',
        style: TextStyle(
          color: (isTodayWithColor || hasColor) ? Colors.white : Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
