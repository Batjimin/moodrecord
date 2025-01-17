import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/mood_color.dart';
import '../services/storage_service.dart';

class CustomColorPage extends StatefulWidget {
  const CustomColorPage({super.key});

  @override
  State<CustomColorPage> createState() => _CustomColorPageState();
}

class _CustomColorPageState extends State<CustomColorPage> {
  late Map<String, Color> tempColors;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    tempColors = Map.from(MoodColor.moodColors);
  }

  void _saveColors() async {
    final Map<String, Color> originalColors = Map.from(MoodColor.moodColors);

    // 변경된 색상에 대해서만 업데이트 수행
    for (var entry in tempColors.entries) {
      if (originalColors[entry.key] != entry.value) {
        await _storageService.updateColorMapping(
          originalColors[entry.key]!,
          entry.value,
        );
      }
    }

    // MoodColor 업데이트
    MoodColor.updateColors(Map.from(tempColors));
    await _storageService.saveCustomColors(tempColors);

    // 저장된 색상 다시 로드하여 캘린더 업데이트
    final colors = await _storageService.loadColors();

    if (mounted) {
      // 홈 페이지로 돌아가서 색상 업데이트
      Navigator.pop(context, colors);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: const Text(
          'Customize Colors',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveColors,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: tempColors.entries.map((entry) {
          return ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entry.value,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onTap: () async {
              final Color? newColor = await showColorPicker(entry.value);
              if (newColor != null) {
                setState(() {
                  tempColors[entry.key] = newColor;
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Future<Color?> showColorPicker(Color initialColor) async {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = initialColor;
        return AlertDialog(
          title: const Text(
            'Pick a color',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
              labelTypes: const [ColorLabelType.rgb],
              labelTextStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              hexInputBar: false,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text(
                'Select',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(context, selectedColor),
            ),
          ],
        );
      },
    );
  }
}
