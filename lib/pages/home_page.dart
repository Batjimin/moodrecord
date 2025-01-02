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
            fontWeight: FontWeight.w500,
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
                                        return GestureDetector(
                                          onTap: () {
                                            print(
                                                'Clicked: Row ${row + 1}, Column ${col + 1}');
                                          },
                                          child: Container(
                                            width: columnWidth,
                                            height: 50,
                                            margin: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                width: 0.5,
                                              ),
                                              color: Colors.white,
                                            ),
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
            child: Padding(
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
