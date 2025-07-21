import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:mediora/helper/colors.dart';

class MyIndicator extends StatelessWidget {
  final Widget child;
  final IndicatorController controller;

  const MyIndicator({super.key, required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    const double indicatorSize = 40.0;
    const double pullDistance = 80.0;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        child,
        if (!controller.isIdle)
          Positioned(
            top: 20 + (controller.value * 30).clamp(0.0, 30.0),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final progress = controller.value.clamp(0.0, 1.0);
                final rotationProgress = controller.isLoading
                    ? controller.value
                    : progress * 0.75;
                final angle = math.pi * 2 * rotationProgress;
                final scale = math.min(1.0, progress * 1.2);
                final opacity = controller.isLoading
                    ? 1.0
                    : (progress * 1.5).clamp(0.0, 1.0);

                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: indicatorSize,
                        height: indicatorSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Colors.white, Colors.blue.shade50],
                            stops: const [0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colorPrimary, secondoryColor],
                            ),
                          ),
                          child: Center(
                            child: controller.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
