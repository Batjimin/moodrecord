import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _horizontalController = ScrollController();
  int currentStartColumn = 0;
  final double columnWidth = 50.0;
  final double sideMargin = 45.0;
  final DateTime _currentYear = DateTime.now();
  Color? selectedMoodColor;
  int selectedMonthIndex = 0;
  Map<String, Color> savedColors = {};
  static const String STORAGE_KEY = 'mood_colors.json';

  final List<String> months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];

  final Map<String, Color> moodColors = {
    'perfect': const Color(0xFFFFB7ED),
    'great': const Color(0xFFFFD9B7),
    'good': const Color(0xFFB7FFD8),
    'angry': const Color(0xFFFFB7B7),
    'sad': const Color(0xFFB7E5FF),
    'tired': const Color(0xFFE0E0E0),
    'surprised': const Color(0xFFFFFDB7),
  };

  // 파일 저장 관련 함수들
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$STORAGE_KEY');
  }

  Future<void> saveColor(int day, int month, Color color) async {
    try {
      final file = await _localFile;
      Map<String, dynamic> allColors = {};

      if (await file.exists()) {
        final String contents = await file.readAsString();
        allColors = Map<String, dynamic>.from(json.decode(contents));
      }

      final key = '${_currentYear.year}-$month-$day';
      allColors[key] = color.value.toString();

      await file.writeAsString(json.encode(allColors));

      setState(() {
        savedColors[key] = color;
      });
    } catch (e) {
      print('Error saving color: $e');
    }
  }

  Future<void> loadColors() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final String contents = await file.readAsString();
        final Map<String, dynamic> allColors =
            Map<String, dynamic>.from(json.decode(contents));

        setState(() {
          savedColors.clear();
          allColors.forEach((key, value) {
            final colorValue = int.parse(value);
            savedColors[key] = Color(colorValue);
          });
        });
      }
    } catch (e) {
      print('Error loading colors: $e');
    }
  }

  Color? getSavedColor(int day, int month) {
    final key = '${_currentYear.year}-$month-$day';
    return savedColors[key];
  }

  // 기존 함수들
  int _getDaysInMonth(int month) {
    return DateTime(_currentYear.year, month + 1, 0).day;
  }

  void _scrollHorizontally(bool toRight) {
    int newStartColumn = toRight
        ? (currentStartColumn + 1).clamp(0, 11)
        : (currentStartColumn - 1).clamp(0, 11);

    if (newStartColumn != currentStartColumn) {
      setState(() {
        currentStartColumn = newStartColumn;
      });

      double targetScroll;
      if (newStartColumn == 11) {
        targetScroll = 11.2 * (columnWidth + 2);
      } else {
        targetScroll = newStartColumn * (columnWidth + 2);
      }

      _horizontalController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isToday(int row, int col) {
    final now = DateTime.now();
    return row + 1 == now.day && col == now.month - 1;
  }

  // 초기화 함수 추가
  Future<void> resetAllColors() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        savedColors.clear();
        selectedMoodColor = null;
      });
    } catch (e) {
      print('Error resetting colors: $e');
    }
  }

  // 초기화 확인 다이얼로그를 표시하는 함수 추가
  Future<void> showResetConfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Reset Calendar',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to reset all colors? This action cannot be undone.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                resetAllColors();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadColors(); // 저장된 색상 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              onPressed: () => showResetConfirmation(), // 확인 다이얼로그 표시
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
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
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
                              SingleChildScrollView(
                                child: Column(
                                  children: List.generate(31, (row) {
                                    return Row(
                                      children: List.generate(12, (col) {
                                        int daysInMonth =
                                            _getDaysInMonth(col + 1);
                                        bool isValidDay = row < daysInMonth;

                                        return GestureDetector(
                                          onTap:
                                              isValidDay && _isToday(row, col)
                                                  ? () async {
                                                      if (selectedMoodColor !=
                                                          null) {
                                                        await saveColor(
                                                            row + 1,
                                                            col + 1,
                                                            selectedMoodColor!);
                                                      }
                                                    }
                                                  : null,
                                          child: Container(
                                            width: columnWidth,
                                            height: 50,
                                            margin: const EdgeInsets.all(1),
                                            decoration: isValidDay
                                                ? BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      width: 0.5,
                                                    ),
                                                    color: _isToday(row, col)
                                                        ? (selectedMoodColor ??
                                                            getSavedColor(
                                                                row + 1,
                                                                col + 1) ??
                                                            Colors.white)
                                                        : (months[currentStartColumn] ==
                                                                months[col]
                                                            ? getSavedColor(
                                                                    row + 1,
                                                                    col + 1) ??
                                                                Colors.white
                                                            : Colors.white),
                                                  )
                                                : null,
                                            child: isValidDay &&
                                                    months[currentStartColumn] ==
                                                        months[col]
                                                ? Center(
                                                    child: Text(
                                                      '${row + 1}',
                                                      style: TextStyle(
                                                        color: (_isToday(row,
                                                                        col) &&
                                                                    (selectedMoodColor !=
                                                                            null ||
                                                                        getSavedColor(row + 1, col + 1) !=
                                                                            null)) ||
                                                                getSavedColor(
                                                                        row + 1,
                                                                        col +
                                                                            1) !=
                                                                    null
                                                            ? Colors.white
                                                            : Colors.black87,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        );
                                      }),
                                    );
                                  }),
                                ),
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
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 28, 32, 0),
                  child: Text(
                    months[currentStartColumn],
                    style: GoogleFonts.bungeeHairline(
                      fontSize: 72,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: moodColors.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedMoodColor = entry.value;
                            });
                            // 오늘 날짜에 대해 자동 저장
                            final now = DateTime.now();
                            await saveColor(now.day, now.month, entry.value);
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
                ),
              ],
            ),
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
