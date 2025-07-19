import 'dart:math';

import 'package:flutter/material.dart';

// Define your medical app colors
const Color medicalBlue = Color(0xFF2E7CE4);
const Color calmTeal = Color(0xFF4ECDC4);
const Color lightMedicalBlue = Color(0xFFE8F4FD);

/// A full-screen loading overlay system for medical applications
class MedicalLoadingOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Shows the full-screen loading overlay
  static void show(
    BuildContext context, {
    String? title,
    String? subtitle,
    bool dismissible = false,
    VoidCallback? onCancel,
  }) {
    if (_isShowing) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => MedicalFullScreenLoader(
        title: title ?? 'Processing',
        subtitle:
            subtitle ??
            'Please wait while we process\nyour medical information',
        dismissible: dismissible,
        onCancel: onCancel ?? () => hide(),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;
  }

  /// Hides the full-screen loading overlay
  static void hide() {
    if (!_isShowing || _overlayEntry == null) return;

    _overlayEntry!.remove();
    _overlayEntry = null;
    _isShowing = false;
  }

  /// Checks if loading overlay is currently showing
  static bool get isShowing => _isShowing;
}

/// The actual full-screen loading widget
class MedicalFullScreenLoader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool dismissible;
  final VoidCallback? onCancel;

  const MedicalFullScreenLoader({
    super.key,
    required this.title,
    required this.subtitle,
    this.dismissible = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lightMedicalBlue.withOpacity(0.8),
              Colors.white,
              lightMedicalBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top section with cancel button (if dismissible)
                if (dismissible)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // Balance the layout
                      Text(
                        title,
                        style: const TextStyle(
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
                          onPressed: onCancel,
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
                  )
                else
                  // Just show title when not dismissible
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: medicalBlue,
                      ),
                    ),
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
                            const Positioned.fill(
                              child: RotatingMedicalIcons(
                                color: calmTeal,
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
                                    const Positioned.fill(
                                      child: RotatingCircle(
                                        color: medicalBlue,
                                        strokeWidth: 4,
                                        duration: 2000,
                                      ),
                                    ),
                                    // Inner pulsing circle
                                    const Positioned.fill(
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
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: medicalBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'This may take a few moments',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),

                      const SizedBox(height: 30),

                      // Progress dots
                      const LoadingDots(color: calmTeal, duration: 1200),
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
                        child: const Icon(
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
  }
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
  State<RotatingMedicalIcons> createState() => _RotatingMedicalIconsState();
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
          angle: _controller.value * 2 * pi,
          child: CustomPaint(
            painter: MedicalIconsPainter(color: widget.color.withOpacity(0.3)),
          ),
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
  State<RotatingCircle> createState() => _RotatingCircleState();
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
          angle: _controller.value * 2 * pi,
          child: CustomPaint(
            painter: CircleProgressPainter(
              color: widget.color.withOpacity(0.4),
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
  State<PulsingCircle> createState() => _PulsingCircleState();
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
  State<LoadingDots> createState() => _LoadingDotsState();
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
      final angle = (i * 60) * pi / 180;
      final x = center.dx + radius * 0.8 * cos(angle);
      final y = center.dy + radius * 0.8 * sin(angle);

      // Draw small medical crosses
      const crossSize = 8.0;
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
      -pi / 2, // Start from top
      pi * 1.5, // 3/4 of circle
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

// Example usage class to demonstrate how to use the loading system
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  void _showLoading(BuildContext context) {
    // Show loading with default settings
    MedicalLoadingOverlay.show(context);

    // Auto-hide after 3 seconds for demo
    Future.delayed(const Duration(seconds: 3), () {
      MedicalLoadingOverlay.hide();
    });
  }

  void _showDismissibleLoading(BuildContext context) {
    // Show dismissible loading with custom text
    MedicalLoadingOverlay.show(
      context,
      title: 'Analyzing Results',
      subtitle: 'Please wait while we analyze\nyour medical test results',
      dismissible: true,
      onCancel: () {
        MedicalLoadingOverlay.hide();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Loading cancelled')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Loading System'),
        backgroundColor: medicalBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _showLoading(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: medicalBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Show Loading (Auto-hide)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showDismissibleLoading(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: calmTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Show Dismissible Loading'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => MedicalLoadingOverlay.hide(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Hide Loading'),
            ),
            const SizedBox(height: 40),
            Text(
              'Loading Status: ${MedicalLoadingOverlay.isShowing ? "Showing" : "Hidden"}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
