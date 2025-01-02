import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _horizontalController = ScrollController();
  int currentStartColumn = 0;
  final double columnWidth = 50.0;

  void _scrollHorizontally(bool toRight) {
    int newStartColumn = toRight
        ? (currentStartColumn + 1).clamp(0, 10)
        : (currentStartColumn - 1).clamp(0, 10);

    if (newStartColumn != currentStartColumn) {
      setState(() {
        currentStartColumn = newStartColumn;
      });

      _horizontalController.animateTo(
        currentStartColumn * (columnWidth + 2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
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
                              SizedBox(width: columnWidth * 3),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: currentStartColumn < 10
                            ? () => _scrollHorizontally(true)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
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
