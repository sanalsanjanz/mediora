import 'dart:math';

import 'package:flutter/material.dart';

// Define your medical app colors
const Color medicalBlue = Color(0xFF2E7CE4);
const Color calmTeal = Color(0xFF4ECDC4);
const Color lightMedicalBlue = Color(0xFFE8F4FD);

loadingDialogue(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lightMedicalBlue.withOpacity(0.3),
                Colors.white,
                lightMedicalBlue.withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Top section with cancel button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // Balance the layout
                      Text(
                        'Processing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: medicalBlue,
                        ),
                      ),
                      // Cancel button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: medicalBlue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Main content area
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Medical illustration background
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: medicalBlue.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Outer rotating medical symbols
                              Positioned.fill(
                                child: RotatingMedicalIcons(
                                  color: calmTeal.withOpacity(0.3),
                                  duration: 4000,
                                ),
                              ),
                              // Main loading animation
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Stack(
                                    children: [
                                      // Outer rotating ring
                                      Positioned.fill(
                                        child: RotatingCircle(
                                          color: medicalBlue.withOpacity(0.4),
                                          strokeWidth: 4,
                                          duration: 2000,
                                        ),
                                      ),
                                      // Inner pulsing circle
                                      Positioned.fill(
                                        child: PulsingCircle(
                                          color: calmTeal,
                                          duration: 1500,
                                        ),
                                      ),
                                      // Center medical cross
                                      Positioned.fill(
                                        child: Center(
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CustomPaint(
                                              painter: MedicalCrossPainter(
                                                color: medicalBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Loading text
                        Text(
                          'Please wait while we process\nyour medical information',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: medicalBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'This may take a few moments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Progress dots
                        LoadingDots(color: calmTeal, duration: 1200),
                      ],
                    ),
                  ),

                  // Bottom section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lightMedicalBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: calmTeal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.security,
                            color: calmTeal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your data is being processed securely and privately',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Custom animated widgets
class RotatingMedicalIcons extends StatefulWidget {
  final Color color;
  final int duration;

  const RotatingMedicalIcons({
    super.key,
    required this.color,
    required this.duration,
  });

  @override
  _RotatingMedicalIconsState createState() => _RotatingMedicalIconsState();
}

class _RotatingMedicalIconsState extends State<RotatingMedicalIcons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: CustomPaint(painter: MedicalIconsPainter(color: widget.color)),
        );
      },
    );
  }
}

class RotatingCircle extends StatefulWidget {
  final Color color;
  final double strokeWidth;
  final int duration;

  const RotatingCircle({
    super.key,
    required this.color,
    required this.strokeWidth,
    required this.duration,
  });

  @override
  _RotatingCircleState createState() => _RotatingCircleState();
}

class _RotatingCircleState extends State<RotatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: CustomPaint(
            painter: CircleProgressPainter(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        );
      },
    );
  }
}

class PulsingCircle extends StatefulWidget {
  final Color color;
  final int duration;

  const PulsingCircle({super.key, required this.color, required this.duration});

  @override
  _PulsingCircleState createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.15),
              border: Border.all(
                color: widget.color.withOpacity(0.4),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadingDots extends StatefulWidget {
  final Color color;
  final int duration;

  const LoadingDots({super.key, required this.color, required this.duration});

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (_controller.value + delay) % 1.0;
            final opacity = (0.4 + (0.6 * (1 - (animValue - 0.5).abs() * 2)))
                .clamp(0.3, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// Custom painters
class MedicalIconsPainter extends CustomPainter {
  final Color color;

  MedicalIconsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw medical symbols around the circle
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * 3.14159 / 180;
      final x = center.dx + radius * 0.8 * cos(angle);
      final y = center.dy + radius * 0.8 * sin(angle);

      // Draw small medical crosses
      final crossSize = 8.0;
      final crossCenter = Offset(x, y);

      // Vertical bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: crossCenter,
            width: crossSize * 0.3,
            height: crossSize,
          ),
          const Radius.circular(1),
        ),
        paint,
      );

      // Horizontal bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: crossCenter,
            width: crossSize,
            height: crossSize * 0.3,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircleProgressPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw partial circle (3/4 of the circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      3.14159 * 1.5, // 3/4 of circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MedicalCrossPainter extends CustomPainter {
  final Color color;

  MedicalCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final crossWidth = size.width * 0.25;
    final crossHeight = size.height * 0.8;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: crossWidth,
          height: crossHeight,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: crossHeight,
          height: crossWidth,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function for cos calculation
double cos(double radians) {
  // Simple approximation for cos function
  return 1 -
      (radians * radians) / 2 +
      (radians * radians * radians * radians) / 24;
}
