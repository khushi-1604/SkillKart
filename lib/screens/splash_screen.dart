import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skillkart/screens/home_screen.dart';
import 'package:skillkart/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final String fullText = 'Apki Kala, Apki Kamai...';
  int visibleCharCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    double charSpacing = 11.0; // increased spacing
    double textWidth = fullText.length * charSpacing;

    _animation = Tween<double>(begin: -150, end: textWidth ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          double imageLeadingEdge = _animation.value;
          visibleCharCount = ((imageLeadingEdge - 12.0) / charSpacing).floor().clamp(0, fullText.length);
        });
      });

    _controller.forward().then((_) {
    Future.delayed(const Duration(seconds: 1), () {
      checkLoginStatus(); // ✅ Now dynamically check login status
    });
  });
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

void checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

@override
Widget build(BuildContext context) {
  double charSpacing = 20.0;
  double textWidth = fullText.length * charSpacing;

  return Scaffold(
    backgroundColor: const Color(0xFFFDF8F0),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Center(
              child: SizedBox(
                width: textWidth + 64,
                height: 100, // ensure it holds full image height
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Text with left padding
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 10), // space before text
                        ...List.generate(fullText.length, (index) {
                          return Text(
                            index < visibleCharCount ? fullText[index] : ' ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.brown,
                            ),
                          );
                        }),
                      ],
                    ),

                
                    AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Positioned(
      left: _animation.value + 10,
      top: 0,
      child: Image.asset(
        'assets/my.png',
        width: 100, // specify width and height
        height: 80,
        fit: BoxFit.fill, // force full image
      ),
    );
  },
),

                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // SkillKart title
          Text(
            'SkillKart',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Colors.deepOrange, Colors.amber],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
        ],
      ),
    ),
  );
}
    }