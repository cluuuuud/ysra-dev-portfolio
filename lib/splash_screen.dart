import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _loadingController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 🔵 Glow Animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 📊 Loading Animation (3s)
    _loadingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    // ⏱️ Navigation بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔵 Logo + Glow
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF4D96FF,
                        ).withOpacity(_glowAnimation.value),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: const Text(
                'ATTENDIX',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D96FF),
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🏫 Subtitle
            const Text(
              "M'sila University - IT Department",
              style: TextStyle(color: Color(0xFFF0F4FF), fontSize: 14),
            ),

            const SizedBox(height: 40),

            /// 📊 Loading Bar
            Container(
              width: 200,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _loadingController.value,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D96FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            /// 📌 Version
            const Text(
              "v1.0.0 - Academic Year 2024",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
