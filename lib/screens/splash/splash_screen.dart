import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/shared_prefs.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _zoomController;
  late AnimationController _expandController;
  late AnimationController _blueController;
  late AnimationController _text1Controller;
  late AnimationController _text2Controller;

  late Animation<double> _dropAnimation;
  late Animation<double> _zoomScale;
  late Animation<double> _zoomFade;
  late Animation<double> _expandAnimation;
  late Animation<double> _blueOpacity;
  late Animation<double> _text1Opacity;
  late Animation<double> _text2Opacity;

  bool _showText1 = false;
  bool _showText2 = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimation();
  }

  void _initAnimations() {
    // Drop animation (500ms-900ms)
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dropAnimation = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.easeIn),
    );

    // Zoom in + fade out (900ms-1300ms)
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _zoomScale = Tween<double>(begin: 1.0, end: 3.5).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );
    _zoomFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _zoomController, curve: const Interval(0.7, 1.0)),
    );

    // Blue expansion (1300ms-1700ms)
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOut),
    );

    // Blue fade to white (1700ms-2100ms)
    _blueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _blueOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blueController, curve: Curves.linear),
    );

    // Text ACRETAWET fade in (2100ms-2500ms)
    _text1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _text1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _text1Controller, curve: Curves.easeIn),
    );

    // Text WATERCASH fade in (2500ms-2900ms)
    _text2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _text2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _text2Controller, curve: Curves.easeIn),
    );
  }

  void _startAnimation() async {
    // Initialize owner_token if not exists
    final existing = SharedPrefs.getOwnerToken();
    if (existing == null || existing.isEmpty) {
      await SharedPrefs.saveOwnerToken('262410edff78a411e2f842d509a554850242afb9');
    }

    // Phase 1: White screen (0-500ms)
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 2: Water drop falls (500ms-900ms)
    _dropController.forward();

    // Phase 3: After drop completes, zoom in (900ms-1300ms)
    _dropController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _zoomController.forward();
      }
    });

    // Phase 4: After zoom completes, expand blue (1300ms-1700ms)
    _zoomController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _expandController.forward();
      }
    });

    // Phase 5: After expand completes, fade blue to white (1700ms-2100ms)
    _expandController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _blueController.forward();
      }
    });

    // Phase 6: After blue fade completes, show ACRETAWET (2100ms-2500ms)
    _blueController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showText1 = true);
        _text1Controller.forward();
      }
    });

    // Phase 7: After text1 completes, WATERCASH then navigate
    _text1Controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _text1Controller.reverse().then((_) {
          setState(() => _showText2 = true);
          _text2Controller.forward().then((_) async {
            await Future.delayed(const Duration(milliseconds: 400));
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => const LoginScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _dropController.dispose();
    _zoomController.dispose();
    _expandController.dispose();
    _blueController.dispose();
    _text1Controller.dispose();
    _text2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final maxRadius = sqrt(size.width * size.width + size.height * size.height);

          return Stack(
            children: [
              // Layer 1: Background putih
              Container(color: Colors.white),

              // Layer 2: Blue expanding circle
              AnimatedBuilder(
                animation: _expandAnimation,
                builder: (_, __) {
                  if (_expandAnimation.value <= 0) return const SizedBox.shrink();
                  return CustomPaint(
                    size: size,
                    painter: BluCirclePainter(
                      progress: _expandAnimation.value,
                      screenSize: size,
                      maxRadius: maxRadius,
                    ),
                  );
                },
              ),

              // Layer 3: Blue overlay for fade to white
              Opacity(
                opacity: _blueController.value,
                child: Container(color: const Color(0xFF2196F3)),
              ),

              // Layer 4: Water drop with zoom + fade
              AnimatedBuilder(
                animation: Listenable.merge([_dropAnimation, _zoomScale, _zoomFade]),
                builder: (_, __) {
                  final dropOffset = _dropController.isAnimating || _dropController.isCompleted
                      ? _dropAnimation.value
                      : 0.0;
                  final scale = _zoomController.isAnimating || _zoomController.isCompleted
                      ? _zoomScale.value
                      : 1.0;
                  final opacity = _zoomController.isAnimating || _zoomController.isCompleted
                      ? _zoomFade.value
                      : 1.0;

                  return Positioned(
                    top: size.height / 2 - 60 + dropOffset,
                    left: size.width / 2 - 60,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          'assets/images/water_drop.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Layer 5: Text ACRETAWET
              if (_showText1)
                FadeTransition(
                  opacity: _text1Opacity,
                  child: Center(
                    child: Text(
                      'ACRETAWET',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 8.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Layer 6: Text WATERCASH
              if (_showText2)
                FadeTransition(
                  opacity: _text2Opacity,
                  child: Center(
                    child: Text(
                      'WATERCASH',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 8.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class BluCirclePainter extends CustomPainter {
  final double progress;
  final Size screenSize;
  final double maxRadius;

  BluCirclePainter({
    required this.progress,
    required this.screenSize,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()..color = const Color(0xFF2196F3);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, progress * maxRadius, paint);
  }

  @override
  bool shouldRepaint(covariant BluCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}