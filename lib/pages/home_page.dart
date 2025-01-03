import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    'perfect': const Color(0xFFFFB7ED), // 파스텔 핑크
    'great': const Color(0xFFFFD9B7), // 파스텔 오렌지
    'good': const Color(0xFFB7FFD8), // 파스텔 그린
    'angry': const Color(0xFFFFB7B7), // 파스텔 레드
    'sad': const Color(0xFFB7E5FF), // 파스텔 블루
    'tired': const Color(0xFFE0E0E0), // 파스텔 그레이
    'surprised': const Color(0xFFFFFDB7), // 파스텔 옐로우
  };

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalController.jumpTo(0);
    });
  }

  Widget _buildColorPalette() {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: moodColors.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedMoodColor = entry.value;
                });
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
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
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

  bool _isToday(int row, int col) {
    final now = DateTime.now();
    return row + 1 == now.day && col == now.month - 1;
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
                                          onTap: isValidDay
                                              ? () {
                                                  print(
                                                      'Clicked: Row ${row + 1}, Column ${col + 1}');
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
                                                    color: _isToday(row, col) &&
                                                            selectedMoodColor !=
                                                                null
                                                        ? selectedMoodColor
                                                        : Colors.white,
                                                  )
                                                : null,
                                            child: isValidDay &&
                                                    months[currentStartColumn] ==
                                                        months[col]
                                                ? Center(
                                                    child: Text(
                                                      '${row + 1}',
                                                      style: TextStyle(
                                                        color: _isToday(
                                                                    row, col) &&
                                                                selectedMoodColor !=
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
                          onTap: () {
                            setState(() {
                              selectedMoodColor = entry.value;
                            });
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
