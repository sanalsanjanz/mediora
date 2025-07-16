import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/login_screen.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/patients/views/booking_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingCheckpoint extends StatefulWidget {
  const BookingCheckpoint({
    super.key,
    required this.tocken,
    required this.bookingId,
  });
  final String tocken;
  final String bookingId;
  @override
  State<BookingCheckpoint> createState() => _BookingCheckpointState();
}

class _BookingCheckpointState extends State<BookingCheckpoint>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  String _currentStatus = 'Initializing...';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCheckingProcess();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  void _startCheckingProcess() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _checkLogin();
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _currentStatus = status;
      });
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
        _currentStatus = 'Error occurred';
      });
      _pulseController.stop();
    }
  }

  Future<void> _checkLogin() async {
    try {
      _updateStatus('Checking authentication...');
      await Future.delayed(const Duration(milliseconds: 1000));

      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool? isLoggedIn = preferences.getBool('logged');

      if (isLoggedIn == null || !isLoggedIn) {
        _updateStatus('Authentication required');
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MedicalLoginScreen(fcmTocken: widget.tocken),
            ),
            (_) => false,
          );
        }
      } else {
        _updateStatus('Fetching booking details...');
        await Future.delayed(const Duration(milliseconds: 1000));

        List<BookingDetailsModel> items = await BookingApi.getBookings(
          bookingId: widget.bookingId,
        );

        if (items.isNotEmpty) {
          _updateStatus('Booking found! Redirecting...');
          await Future.delayed(const Duration(milliseconds: 800));

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailsPage(
                  booking: items.first,
                  isFromNotification: true,
                  onBookingUpdated: (BookingDetailsModel d) {},
                ),
              ),
              (_) => false,
            );
          }
        } else {
          _setError('No booking found with ID: ${widget.bookingId}');
        }
      }
    } catch (e) {
      _setError('Failed to load booking details: ${e.toString()}');
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _currentStatus = 'Retrying...';
    });
    _pulseController.repeat(reverse: true);
    _startCheckingProcess();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white, Colors.grey[50]!],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // App Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      size: 60,
                      color: Colors.blue[600],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Mediora',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Healthcare Management',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading Animation or Error State
                  if (!_hasError) ...[
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.bookmark_added,
                              size: 40,
                              color: Colors.blue[600],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Status Text
                    Text(
                      _currentStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loading indicator
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[600]!,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Error State
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.red[600],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[700],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Retry Button
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],

                  const Spacer(flex: 3),

                  // Footer
                  Text(
                    'Please wait while we process your booking...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
