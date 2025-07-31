// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/login_screen.dart';
import 'package:mediora/organizations/doctors_landing_screen.dart';
import 'package:mediora/pharmacy/pharmacy_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedioraSplashScreen extends StatefulWidget {
  const MedioraSplashScreen({super.key, this.fcm});
  final String? fcm;
  @override
  State<MedioraSplashScreen> createState() => _MedioraSplashScreenState();
}

class _MedioraSplashScreenState extends State<MedioraSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations with delays
    _startAnimations();

    Future.delayed(Duration(seconds: 5), () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool isLogged = preferences.getBool("logged") ?? false;
      String type = await preferences.getString("type") ?? "";

      if (isLogged) {
        await PatientController.getPharmacyDetails();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (c) =>
                PharmacyHome(pharmacy: PatientController.pharmacyModel!),
          ),
          (_) => false,
        );
      } else if (isLogged && type == "clinic") {
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (c) => MedicalLoginScreen(fcmTocken: widget.fcm ?? ""),
          ),
          (_) => false,
        );
      }
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  static const Color medicalBlue = Color.fromARGB(255, 35, 33, 158);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 0.0,

        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 35, 33, 158),
        ), // Light status bar
        backgroundColor: medicalBlue.withOpacity(0.1), // Transparent AppBar
        elevation: 0, // No shadow
        automaticallyImplyLeading: false, // Hide back button
        centerTitle: true, // Center title
        title: const Text(
          'Mediora',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ), // Hide AppBar

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 35, 33, 158), Color(0xFF333F48)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer to push content to center
            const Spacer(flex: 2),

            // Logo/Icon Section
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset("assets/pharmacy_logo.png") /*  Container(
                  width: isTablet ? 140 : 100,
                  height: isTablet ? 140 : 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child:
                ), */,
              ),
            ),

            SizedBox(height: isTablet ? 40 : 30),

            // App Name
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Mediora Pharmacy',
                  style: TextStyle(
                    fontSize: isTablet ? 48 : 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Tagline
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Care that connects',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Spacer
            const Spacer(flex: 2),

            // Loading indicator
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: EdgeInsets.only(bottom: isTablet ? 60 : 40),
                child: SizedBox(
                  width: isTablet ? 40 : 30,
                  height: isTablet ? 40 : 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative version with pulse animation
class MedioraSplashScreenPulse extends StatefulWidget {
  const MedioraSplashScreenPulse({super.key});

  @override
  State<MedioraSplashScreenPulse> createState() =>
      _MedioraSplashScreenPulseState();
}

class _MedioraSplashScreenPulseState extends State<MedioraSplashScreenPulse>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _startAnimations();
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF3CB8B8), Color(0xFF333F48)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo with pulse effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: isTablet ? 120 : 90,
                      height: isTablet ? 120 : 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        size: isTablet ? 60 : 45,
                        color: const Color(0xFF3CB8B8),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: isTablet ? 50 : 40),

              // App name with modern typography
              Text(
                'MEDIORA',
                style: TextStyle(
                  fontSize: isTablet ? 44 : 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 8.0,
                ),
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // Tagline
              Text(
                'Care that connects',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
