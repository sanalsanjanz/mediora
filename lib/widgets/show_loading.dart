import 'package:flutter/material.dart';

class MedioraLoadingScreen {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  // Show loading screen
  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return;

    _isShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingScreenWidget(message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Hide loading screen
  static void hide() {
    if (!_isShowing) return;

    _isShowing = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Check if loading is currently showing
  static bool get isShowing => _isShowing;
}

class LoadingScreenWidget extends StatefulWidget {
  final String? message;

  const LoadingScreenWidget({super.key, this.message});

  @override
  State<LoadingScreenWidget> createState() => _LoadingScreenWidgetState();
}

class _LoadingScreenWidgetState extends State<LoadingScreenWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _dotsController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Rotation animation for the outer ring
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Pulse animation for the logo
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade animation for the entire screen
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Dots animation for loading text
    _dotsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _dotsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: Curves.easeInOut),
    );

    // Start animations
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4169E1), // Royal Blue
                const Color(0xFF6A5ACD), // Slate Blue
                const Color(0xFF483D8B), // Dark Slate Blue
                const Color(0xFF2F4F4F), // Dark Slate Gray
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated background particles
              ...List.generate(20, (index) => _buildParticle(index)),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading animation with logo
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating ring
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value * 2 * 3.14159,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: LoadingRingPainter(),
                                ),
                              ),
                            );
                          },
                        ),

                        // Inner pulsing logo
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_hospital,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // App name
                    const Text(
                      'Mediora',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Healthcare Management',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Loading message with animated dots
                    AnimatedBuilder(
                      animation: _dotsAnimation,
                      builder: (context, child) {
                        String dots = '';
                        int dotCount = (_dotsAnimation.value * 3).floor() + 1;
                        dots = '.' * dotCount;

                        return Text(
                          '${widget.message ?? 'Loading'}$dots',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Progress indicator
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        double angle = (index * 18.0) + (_rotationController.value * 360);
        double radians = angle * (3.14159 / 180);
        double radius = 150 + (index % 3) * 50;

        return Positioned(
          left:
              MediaQuery.of(context).size.width / 2 +
              (radius * 0.8) *
                  (1 + 0.5 * (index % 2)) *
                  (0.3 +
                      0.7 *
                          ((index + _rotationController.value * 10) % 10) /
                          10) *
                  (0.5 + 0.5 * ((angle / 360) % 1)) +
              100 * (2 * ((index % 5) / 5) - 1),
          top:
              MediaQuery.of(context).size.height / 2 +
              (radius * 0.6) *
                  (1 + 0.3 * ((index + 1) % 2)) *
                  (0.4 +
                      0.6 * ((index + _rotationController.value * 8) % 8) / 8) *
                  (0.6 + 0.4 * ((angle / 360) % 1)) +
              80 * (2 * ((index % 7) / 7) - 1),
          child: Container(
            width: 4 + (index % 3) * 2,
            height: 4 + (index % 3) * 2,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1 + (index % 4) * 0.1),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class LoadingRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw segments
    for (int i = 0; i < 8; i++) {
      final startAngle = (i * 45 * 3.14159) / 180;
      final sweepAngle = (30 * 3.14159) / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
