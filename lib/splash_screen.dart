// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/login_screen.dart';
import 'package:mediora/patients/views/patient_landing_screen.dart';
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

    _startAnimations();

    Future.delayed(Duration(seconds: 4), () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool isLogged = preferences.getBool("logged") ?? false;
      if (isLogged) {
        await PatientController.getPatientDetails();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => PatientLandingScreen()),
          (_) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MedicalLoginScreen(fcmTocken: widget.fcm ?? ""),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    // Match status bar with gradient background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3CB8B8), Color(0xFF333F48)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Logo
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: isTablet ? 140 : 100,
                  height: isTablet ? 140 : 100,
                  child: Image.asset("assets/logo.png"),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 40 : 10),

            // App Name
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'MEDIORA',
                  style: TextStyle(
                    fontSize: isTablet ? 48 : 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 16 : 5),

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

            const Spacer(flex: 2),

            // Loading Indicator
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
