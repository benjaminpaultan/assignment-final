import 'dart:ui';
import 'package:flutter/material.dart';
import 'diary_detail_page.dart';

class DiaryMoodPage extends StatefulWidget {
  const DiaryMoodPage({super.key});

  @override
  State<DiaryMoodPage> createState() => _DiaryMoodPageState();
}

class _DiaryMoodPageState extends State<DiaryMoodPage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  double _currentPage = 1.0;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😡', 'label': 'Angry', 'color': const Color(0xFFFF5252), 'desc': 'Take a deep breath.'},
    {'emoji': '😊', 'label': 'Happy', 'color': const Color(0xFFFFC107), 'desc': 'What a beautiful day!'},
    {'emoji': '😐', 'label': 'Neutral', 'color': const Color(0xFF90A4AE), 'desc': 'Finding your balance.'},
    {'emoji': '😔', 'label': 'Sad', 'color': const Color(0xFF5C6BC0), 'desc': 'It is okay to feel down.'},
    {'emoji': '🤩', 'label': 'Excited', 'color': const Color(0xFF66BB6A), 'desc': 'Riding the wave!'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int index = _currentPage.round();
    Color bgColor = _moods[index.clamp(0, _moods.length - 1)]['color'];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgColor.withOpacity(0.8), bgColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("LOG MOOD",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Text(
                "How's your vibe?",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _moods.length,
                  itemBuilder: (context, i) {
                    double relativePosition = i - _currentPage;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..scale(1.0 - relativePosition.abs() * 0.2)
                        ..translate(0.0, relativePosition.abs() * 50),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: (1.0 - relativePosition.abs()).clamp(0.2, 1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_moods[i]['emoji'], style: const TextStyle(fontSize: 140)),
                            const SizedBox(height: 20),
                            Text(
                              _moods[i]['label'].toUpperCase(),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _moods[i]['desc'],
                              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailPage(
                              selectedEmoji: _moods[_currentPage.round()]['emoji'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: Colors.white.withOpacity(0.4)),
                        ),
                        elevation: 0,
                      ),
                      child: const Text("CONTINUE",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}