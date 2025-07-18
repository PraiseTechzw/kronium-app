import 'dart:async';
import 'package:flutter/material.dart';

class BackgroundSwitcher extends StatefulWidget {
  final Widget child;
  final Duration switchDuration;

  const BackgroundSwitcher({
    Key? key,
    required this.child,
    this.switchDuration = const Duration(seconds: 8),
  }) : super(key: key);

  @override
  State<BackgroundSwitcher> createState() => _BackgroundSwitcherState();
}

class _BackgroundSwitcherState extends State<BackgroundSwitcher> {
  static const List<String> _backgrounds = [
    'assets/images/background/IMG-20250708-WA0068.jpg',
    'assets/images/background/IMG-20250708-WA0067.jpg',
    'assets/images/background/IMG-20250708-WA0066.jpg',
    'assets/images/background/IMG-20250708-WA0065.jpg',
    'assets/images/background/IMG-20250708-WA0064.jpg',
    'assets/images/background/IMG-20250708-WA0063.jpg',
    'assets/images/background/IMG-20250708-WA0062.jpg',
    'assets/images/background/IMG-20250708-WA0061.jpg',
    'assets/images/background/IMG-20250708-WA0060.jpg',
    'assets/images/background/IMG-20250708-WA0059.jpg',
    'assets/images/background/IMG-20250708-WA0058.jpg',
    'assets/images/background/IMG-20250708-WA0057.jpg',
    'assets/images/background/IMG-20250708-WA0056.jpg',
    'assets/images/background/IMG-20250708-WA0055.jpg',
    'assets/images/background/IMG-20250708-WA0054.jpg',
    'assets/images/background/IMG-20250708-WA0053.jpg',
    'assets/images/background/IMG-20250708-WA0052.jpg',
    'assets/images/background/IMG-20250708-WA0051.jpg',
    'assets/images/background/IMG-20250708-WA0050.jpg',
    'assets/images/background/IMG-20250708-WA0049.jpg',
    'assets/images/background/IMG-20250708-WA0048.jpg',
    'assets/images/background/IMG-20250708-WA0047.jpg',
    'assets/images/background/IMG-20250708-WA0046.jpg',
    'assets/images/background/IMG-20250708-WA0045.jpg',
    'assets/images/background/IMG-20250708-WA0044.jpg',
    'assets/images/background/IMG-20250708-WA0043.jpg',
    'assets/images/background/IMG-20250708-WA0042.jpg',
    'assets/images/background/IMG-20250708-WA0041.jpg',
    'assets/images/background/IMG-20250708-WA0040.jpg',
    'assets/images/background/IMG-20250708-WA0039.jpg',
    'assets/images/background/IMG-20250708-WA0038.jpg',
    'assets/images/background/IMG-20250708-WA0037.jpg',
    'assets/images/background/IMG-20250708-WA0036.jpg',
    'assets/images/background/IMG-20250708-WA0035.jpg',
    'assets/images/background/IMG-20250708-WA0034.jpg',
    'assets/images/background/IMG-20250708-WA0033.jpg',
    'assets/images/background/IMG-20250708-WA0032.jpg',
    'assets/images/background/IMG-20250708-WA0031.jpg',
    'assets/images/background/IMG-20250708-WA0030.jpg',
    'assets/images/background/IMG-20250708-WA0029.jpg',
    'assets/images/background/IMG-20250708-WA0028.jpg',
    'assets/images/background/IMG-20250708-WA0027.jpg',
    'assets/images/background/IMG-20250708-WA0026.jpg',
    'assets/images/background/IMG-20250708-WA0025.jpg',
    'assets/images/background/IMG-20250708-WA0024.jpg',
    'assets/images/background/IMG-20250708-WA0023.jpg',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.switchDuration, (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _backgrounds.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: Image.asset(
            _backgrounds[_currentIndex],
            key: ValueKey(_backgrounds[_currentIndex]),
            fit: BoxFit.cover,
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.3), // Optional overlay for readability
        ),
        widget.child,
      ],
    );
  }
} 