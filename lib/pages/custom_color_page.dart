import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/mood_color.dart';

class CustomColorPage extends StatefulWidget {
  const CustomColorPage({super.key});

  @override
  State<CustomColorPage> createState() => _CustomColorPageState();
}

class _CustomColorPageState extends State<CustomColorPage> {
  late Map<String, Color> tempColors;

  @override
  void initState() {
    super.initState();
    tempColors = Map.from(MoodColor.moodColors);
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
            onPressed: () {
              MoodColor.moodColors = tempColors;
              Navigator.pop(context);
            },
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
