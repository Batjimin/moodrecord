import 'package:flutter/material.dart';
import '../models/mood_color.dart';

class MoodSelector extends StatelessWidget {
  final Function(Color) onMoodSelected;
  final Function(int, int, Color) onSaveColor;

  const MoodSelector({
    super.key,
    required this.onMoodSelected,
    required this.onSaveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: MoodColor.moodColors.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onTap: () async {
                onMoodSelected(entry.value);
                final now = DateTime.now();
                onSaveColor(now.day, now.month, entry.value);
              },
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
