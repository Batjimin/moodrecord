import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  Map<String, int> _savedImagesWithYear = {};
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedImages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedImagesDir = Directory('${directory.path}/saved_calendars');
      debugPrint('Looking for images in: ${savedImagesDir.path}');

      if (await savedImagesDir.exists()) {
        final files = await savedImagesDir.list().toList();
        final Map<String, int> newImages = {};

        for (var file in files.whereType<File>()) {
          if (file.path.endsWith('.png')) {
            final match =
                RegExp(r'calendar_(\d{4})_(\d+)\.png').firstMatch(file.path);
            if (match != null) {
              final year = int.parse(match.group(1)!);
              newImages[file.path] = year;
              debugPrint('Found calendar: ${file.path} for year $year');
            }
          }
        }

        if (mounted) {
          setState(() {
            _savedImagesWithYear = Map.fromEntries(
              newImages.entries.toList()
                ..sort((a, b) {
                  final timestampA = int.parse(
                      RegExp(r'_(\d+)\.png').firstMatch(a.key)?.group(1) ??
                          '0');
                  final timestampB = int.parse(
                      RegExp(r'_(\d+)\.png').firstMatch(b.key)?.group(1) ??
                          '0');
                  return timestampB.compareTo(timestampA);
                }),
            );
          });
        }
      } else {
        debugPrint('Directory does not exist: ${savedImagesDir.path}');
      }
    } catch (e) {
      debugPrint('Error loading saved images: $e');
    }
  }

  void updateImageList(String filePath, {bool isDelete = false}) {
    setState(() {
      if (isDelete) {
        _savedImagesWithYear.remove(filePath);
      } else {
        final match = RegExp(r'calendar_(\d{4})\.png').firstMatch(filePath);
        if (match != null) {
          final year = int.parse(match.group(1)!);
          _savedImagesWithYear[filePath] = year;
        }
      }
    });
  }

  Widget _buildNoteBackground() {
    return CustomPaint(
      painter: NoteLinePainter(),
      size: const Size(double.infinity, double.infinity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'RECORDS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _savedImagesWithYear.isEmpty
          ? const Center(
              child: Text('No saved calendars yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  ..._savedImagesWithYear.entries.map((entry) {
                    final file = File(entry.key);
                    final year = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: FadeTransition(
                        opacity: _animation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 450,
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  _buildNoteBackground(),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.black54,
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                  ],
                                                ),
                                                Image.file(file),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      ElevatedButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color:
                                                                Colors.white),
                                                        label: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: const Text(
                                                                'Delete Image',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              content:
                                                                  const Text(
                                                                'Are you sure you want to delete this image?',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child:
                                                                      const Text(
                                                                    'Cancel',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await file
                                                                        .delete();
                                                                    if (context
                                                                        .mounted) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                    _loadSavedImages();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Delete',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(width: 8),
                                                      ElevatedButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.deepPurple,
                                                        ),
                                                        icon: const Icon(
                                                            Icons.share,
                                                            color:
                                                                Colors.white),
                                                        label: const Text(
                                                          'Share',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          await Share
                                                              .shareXFiles(
                                                            [XFile(file.path)],
                                                            subject:
                                                                'Mood Calendar',
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              year.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 24),
                ],
              ),
            ),
    );
  }
}

class NoteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1.0;

    for (double y = 40; y < size.height; y += 30) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    paint.color = Colors.red[100]!;
    canvas.drawLine(
      const Offset(40, 0),
      Offset(40, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
