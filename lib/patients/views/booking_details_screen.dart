import 'package:flutter/material.dart';
import 'package:mediora/patients/views/booking_details_screen.dart';
import 'package:mediora/patients/views/my_bookings.dart';

class BookingDetailsPage extends StatefulWidget {
  final Booking booking;
  final Function(Booking) onBookingUpdated;

  BookingDetailsPage({required this.booking, required this.onBookingUpdated});

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage>
    with TickerProviderStateMixin {
  late Booking currentBooking;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    currentBooking = widget.booking;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _cancelBooking() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 20,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Cancel Booking',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Are you sure you want to cancel this appointment? This action cannot be undone.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Keep Booking',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentBooking = Booking(
                      id: currentBooking.id,
                      doctorName: currentBooking.doctorName,
                      specialty: currentBooking.specialty,
                      date: currentBooking.date,
                      time: currentBooking.time,
                      status: 'cancelled',
                      type: currentBooking.type,
                      location: currentBooking.location,
                      phone: currentBooking.phone,
                      email: currentBooking.email,
                      notes: currentBooking.notes,
                      bookingRef: currentBooking.bookingRef,
                    );
                  });
                  widget.onBookingUpdated(currentBooking);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Booking cancelled successfully'),
                        ],
                      ),
                      backgroundColor: Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.all(16),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Color(0xFF4ECDC4); // Calm teal
      case 'pending':
        return Color(0xFFF59E0B);
      case 'completed':
        return Color(0xFF2E86AB); // Medical blue
      case 'cancelled':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.verified_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar with Gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Color(0xFF2E86AB),
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Share functionality would be implemented here',
                        ),
                        backgroundColor: Color(0xFF2E86AB),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Booking Details',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E86AB),
                      Color(0xFF45B7D1),
                      Color(0xFF4ECDC4),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Status Header Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white, Color(0xFFFAFBFC)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: getStatusColor(
                                    currentBooking.status,
                                  ).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        getStatusColor(
                                          currentBooking.status,
                                        ).withOpacity(0.1),
                                        getStatusColor(
                                          currentBooking.status,
                                        ).withOpacity(0.05),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: getStatusColor(
                                          currentBooking.status,
                                        ).withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    getStatusIcon(currentBooking.status),
                                    size: 36,
                                    color: getStatusColor(
                                      currentBooking.status,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        getStatusColor(currentBooking.status),
                                        getStatusColor(
                                          currentBooking.status,
                                        ).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: getStatusColor(
                                          currentBooking.status,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    currentBooking.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF45B7D1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFF45B7D1).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    'Ref: ${currentBooking.bookingRef}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2E86AB),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 28),

                          // Enhanced Doctor Information
                          _buildModernInfoCard(
                            'Doctor Information',
                            Icons.local_hospital_rounded,
                            Color(0xFF2E86AB),
                            [
                              _buildDetailRow(
                                'Doctor',
                                currentBooking.doctorName,
                              ),
                              _buildDetailRow(
                                'Specialty',
                                currentBooking.specialty,
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Enhanced Appointment Details
                          _buildModernInfoCard(
                            'Appointment Details',
                            Icons.event_note_rounded,
                            Color(0xFF4ECDC4),
                            [
                              _buildDetailRow('Date', currentBooking.date),
                              _buildDetailRow('Time', currentBooking.time),
                              _buildDetailRow('Type', currentBooking.type),
                              _buildDetailRow(
                                'Location',
                                currentBooking.location,
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Enhanced Contact Information
                          _buildModernInfoCard(
                            'Contact Information',
                            Icons.contact_support_rounded,
                            Color(0xFF45B7D1),
                            [
                              _buildDetailRow('Phone', currentBooking.phone),
                              _buildDetailRow('Email', currentBooking.email),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Enhanced Notes
                          _buildModernInfoCard(
                            'Additional Notes',
                            Icons.sticky_note_2_rounded,
                            Color(0xFF2E86AB),
                            [
                              Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFF2E86AB).withOpacity(0.1),
                                    ),
                                  ),
                                  child: Text(
                                    currentBooking.notes,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF475569),
                                      height: 1.6,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 36),

                          // Enhanced Action Buttons
                          if (currentBooking.status == 'confirmed' ||
                              currentBooking.status == 'pending')
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF4ECDC4),
                                              Color(0xFF45B7D1),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(
                                                0xFF4ECDC4,
                                              ).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Reschedule functionality would be implemented here',
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Color(
                                                  0xFF4ECDC4,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                margin: EdgeInsets.all(16),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.schedule_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Reschedule',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFEF4444),
                                              Color(0xFFDC2626),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(
                                                0xFFEF4444,
                                              ).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _cancelBooking,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cancel_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard(
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
  ) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: accentColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.1),
                      accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 22, color: accentColor),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE2E8F0), width: 1),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
