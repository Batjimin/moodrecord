import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood_color.dart';

class MonthHeader extends StatelessWidget {
  final int currentStartColumn;

  const MonthHeader({
    super.key,
    required this.currentStartColumn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 32, 0),
      child: Text(
        MoodColor.months[currentStartColumn],
        style: GoogleFonts.bungeeHairline(
          fontSize: 72,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          height: 1,
          letterSpacing: -2,
        ),
      ),
    );
  }
}
