import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:icons_plus/icons_plus.dart';

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rippleController;
  late AnimationController _progressController;

  late Animation<double> _breathingAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _progressAnimation;

  bool isBreathingIn = true;
  int currentCycle = 0;

  // Audio player
  late AudioPlayer _audioPlayer;
  bool isMusicPlaying = false;

  // Colors
  final Color colorPrimary = Color(0xFF3CB8B8);
  final Color secondaryColor = Color(0xFF333F48);

  // Breathing parameters
  final int inhaleDuration = 4000; // milliseconds
  final int exhaleDuration = 4000;
  final int holdDuration = 1000; // brief pause between breaths

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAnimations();
    _startBreathingCycle();
    _playBackgroundMusic();
  }

  void _setupAnimations() {
    // Main breathing animation
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: inhaleDuration),
    );

    _breathingAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Ripple effect animation
    _rippleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Progress animation for the full cycle
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: inhaleDuration + exhaleDuration + holdDuration,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );
  }

  Future<void> _playBackgroundMusic() async {
    try {
      // You can replace this with your own meditation music file
      // For now, using a placeholder URL - replace with your asset or URL
      await _audioPlayer.setSource(AssetSource('audio/meditation-music.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.3); // Set volume to 30%
      await _audioPlayer.resume();
      setState(() {
        isMusicPlaying = true;
      });
    } catch (e) {
      print('Error playing background music: $e');
      // If local asset fails, you could try a URL source:
      // await _audioPlayer.play(UrlSource('https://example.com/meditation-music.mp3'));
    }
  }

  Future<void> _toggleMusic() async {
    if (isMusicPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isMusicPlaying = false;
      });
    } else {
      await _audioPlayer.resume();
      setState(() {
        isMusicPlaying = true;
      });
    }
  }

  void _startBreathingCycle() {
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Inhale completed - start exhale
        setState(() {
          isBreathingIn = false;
        });
        _breathingController.duration = Duration(milliseconds: exhaleDuration);
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Exhale completed - brief pause then start inhale
        Future.delayed(Duration(milliseconds: holdDuration ~/ 2), () {
          if (mounted) {
            setState(() {
              isBreathingIn = true;
              currentCycle++;
            });
            _breathingController.duration = Duration(
              milliseconds: inhaleDuration,
            );
            _breathingController.forward();
            _progressController.forward();
          }
        });
      }
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _progressController.reset();
      }
    });

    // Start the animations
    _breathingController.forward();
    _progressController.forward();
    _rippleController.repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rippleController.dispose();
    _progressController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_rippleAnimation.value - delay).clamp(
              0.0,
              1.0,
            );

            return Container(
              width: 300 * animationValue,
              height: 300 * animationValue,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorPrimary.withOpacity(0.3 * (1 - animationValue)),
                  width: 2,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBreathingCircle() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Container(
          width: 200 * _breathingAnimation.value,
          height: 200 * _breathingAnimation.value,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                colorPrimary.withOpacity(0.8),
                colorPrimary.withOpacity(0.4),
                colorPrimary.withOpacity(0.1),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorPrimary.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(-5, -5),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(5, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                FontAwesome.heart_circle_plus_solid,
                // : Icons.keyboard_arrow_down,
                color: secondaryColor.withAlpha(100),
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: 280,
          height: 6,
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 100),
                width: 280 * _progressAnimation.value,
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorPrimary, colorPrimary.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(
            isBreathingIn ? 'Breathe In' : 'Breathe Out',
            key: ValueKey(isBreathingIn),
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          isBreathingIn
              ? 'Inhale slowly through your nose'
              : 'Exhale gently through your mouth',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.spa, color: colorPrimary, size: 18),
          SizedBox(width: 8),
          Text(
            'Cycle: ${currentCycle + 1}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Breathing Exercise',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              // Session info
              _buildSessionInfo(),

              SizedBox(height: 60),

              // Main breathing visualization
              Container(
                height: 300,
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple effects
                    _buildRippleEffect(),

                    // Main breathing circle
                    _buildBreathingCircle(),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Instructions
              _buildInstructions(),

              SizedBox(height: 40),

              // Progress indicator
              _buildProgressIndicator(),

              SizedBox(height: 40),

              // Bottom tip
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Focus on your breath and let your mind relax',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
