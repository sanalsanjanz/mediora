import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/helper/colors.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/models/booking_model.dart';
import 'package:mediora/patients/views/book_appointment.dart';
import 'package:mediora/patients/views/get_prescription_screen.dart';
import 'package:mediora/patients/views/patient_landing_screen.dart';

class BookingDetailsPage extends StatefulWidget {
  final BookingDetailsModel booking;
  final Function(BookingDetailsModel) onBookingUpdated;
  final bool isFromNotification;
  const BookingDetailsPage({
    super.key,
    required this.booking,
    this.isFromNotification = false,
    required this.onBookingUpdated,
  });

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late BookingDetailsModel currentBooking;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentBooking = widget.booking;

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'accepted':
        return Color(0xFF10B981);
      case 'pending':
        return Color(0xFFF59E0B);
      case 'completed':
        return Color(0xFF3B82F6);
      case 'cancelled':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }

  Color getStatusGradientColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'accepted':
        return Color(0xFF34D399);
      case 'pending':
        return Color(0xFFFBBF24);
      case 'completed':
        return Color(0xFF10B981);
      case 'cancelled':
      case 'rejected':
        return Color(0xFFF87171);
      default:
        return Color(0xFF9CA3AF);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'accepted':
        return Icons.check_circle_rounded;
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

  String formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  String formatDateTime(DateTime date) {
    return "${formatDate(date)} at ${formatTime(date)}";
  }

  /*   void _showUpdateBookingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUpdateBookingBottomSheet(),
    );
  }
 */
  /*   void _showCancelBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCancelBookingDialog(),
    );
  } */

  /*   void _showTokenDialog() {
    showDialog(context: context, builder: (context) => _buildTokenDialog());
  } */

  /*  void _showPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildPrescriptionDialog(),
    );
  } */

  /* void _showCancelReasonDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCancelReasonDialog(),
    );
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloatingActionButtons(),
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                // backdrop: BoxDecoration(color: Colors.white.withOpacity(0.1)),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  if (widget.isFromNotification) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PatientLandingScreen()),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      getStatusColor(currentBooking.status),
                      getStatusGradientColor(currentBooking.status),
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Geometric background pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                              Colors.black.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Modern circles decoration
                    Positioned(
                      top: -50,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -40,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 30,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      getStatusIcon(currentBooking.status),
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      currentBooking.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              if (widget.booking.status.toLowerCase() ==
                                  "pending")
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(context);
                                    },
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Appointment Details',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                          ),
                          /*   SizedBox(height: 4),
                          Text(
                            'ID: ${currentBooking.id}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ), */
                          SizedBox(height: 4),
                          Text(
                            formatDate(currentBooking.preferredDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
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

          // Main Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Info Cards Row
                      _buildQuickInfoCards(),
                      SizedBox(height: 10),

                      // SizedBox(height: 24),
                      // Doctor Information Card
                      _buildDoctorInfoCard(),
                      SizedBox(height: 10),

                      // Patient Information Card
                      _buildPatientInfoCard(),
                      SizedBox(height: 10),

                      // Appointment Details Card
                      _buildAppointmentDetailsCard(),
                      SizedBox(height: 10),

                      // Status-specific Information
                      if (currentBooking.status.toLowerCase() == 'cancelled')
                        _buildCancelReasonCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Action Buttons based on status
      // floatingActionButton:
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDoctorInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: colorPrimary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentBooking.doctor.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: secondoryColor,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        currentBooking.doctor.specialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorPrimary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    /*       padding: EdgeInsets.all(8), */
                    decoration: BoxDecoration(
                      color: colorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: colorPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinic Location',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondoryColor.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currentBooking.doctor.locationName ??
                              'Medical Center',
                          style: TextStyle(
                            fontSize: 15,
                            color: secondoryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,

                  decoration: BoxDecoration(
                    color: secondoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: secondoryColor,
                      size: 26,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: secondoryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28),
            _buildPatientInfoRow(
              'Full Name',
              currentBooking.patientName,
              Icons.badge_rounded,
            ),
            Divider(color: Colors.grey.shade200),
            _buildPatientInfoRow(
              'Age',
              '${currentBooking.patientAge} years old',
              Icons.cake_rounded,
            ),
            Divider(color: Colors.grey.shade200),
            _buildPatientInfoRow(
              'Gender',
              currentBooking.patientGender,
              Icons.wc_rounded,
            ),
            Divider(color: Colors.grey.shade200),
            _buildPatientInfoRow(
              'Phone Number',
              currentBooking.patientContact,
              Icons.phone_rounded,
            ),
          ],
        ),
      ),
    );
  }

  /*  Widget _buildPatientInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFF64748B)),
        SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  } */
  Widget _buildPatientInfoRow(String label, String value, IconData icon) {
    return Container(
      /*  padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1),
      ), */
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorPrimary),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondoryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: secondoryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  // padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: colorPrimary,
                    size: 26,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: secondoryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28),
            _buildDetailRow(
              'Scheduled Date & Time',
              formatDateTime(currentBooking.preferredDate),
              Icons.schedule_rounded,
              colorPrimary,
            ),
            Divider(color: Colors.grey.shade200),
            _buildDetailRow(
              'Medical Concern',
              currentBooking.reason,
              Icons.medical_information_rounded,
              Color(0xFF059669),
            ),
            Divider(color: Colors.grey.shade200),
            _buildDetailRow(
              'Booking Created',
              formatDateTime(currentBooking.createdAt),
              Icons.event_available_rounded,
              Color(0xFFF59E0B),
            ),
            Divider(color: Colors.grey.shade200),
            _buildDetailRow(
              'Current Status',
              currentBooking.status.toUpperCase(),
              getStatusIcon(currentBooking.status),
              getStatusColor(currentBooking.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      /*  padding: EdgeInsets.all(18), */
      /*  decoration: BoxDecoration(
        color: Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1),
      ), */
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondoryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: secondoryColor,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelReasonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFDC2626).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFDC2626).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFDC2626),
                    size: 26,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Cancellation Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: secondoryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFFDC2626).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for Cancellation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFDC2626).withOpacity(0.8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Patient requested to reschedule due to personal emergency.',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondoryColor,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  /* Widget _buildAppointmentDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Date & Time',
                    formatDateTime(currentBooking.preferredDate),
                    Icons.schedule_rounded,
                    Color(0xFF667EEA),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    'Reason',
                    currentBooking.reason,
                    Icons.medical_services_rounded,
                    Color(0xFF10B981),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    'Booking Date',
                    formatDateTime(currentBooking.createdAt),
                    Icons.event_rounded,
                    Color(0xFFF59E0B),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    'Status',
                    currentBooking.status.toUpperCase(),
                    getStatusIcon(currentBooking.status),
                    getStatusColor(currentBooking.status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } */

  // Widget _buildDetailRow(
  //   String label,
  //   String value,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         padding: EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: color.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Icon(icon, size: 16, color: color),
  //       ),
  //       SizedBox(width: 12),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: Color(0xFF94A3B8),
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             SizedBox(height: 4),
  //             Text(
  //               value,
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Color(0xFF1E293B),
  //                 fontWeight: FontWeight.w700,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCancelReasonCard() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(24),
  //       border: Border.all(color: Color(0xFFEF4444).withOpacity(0.2)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 20,
  //           offset: Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.all(24),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Color(0xFFEF4444).withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Icon(
  //                   Icons.cancel_outlined,
  //                   color: Color(0xFFEF4444),
  //                   size: 24,
  //                 ),
  //               ),
  //               SizedBox(width: 16),
  //               Text(
  //                 'Cancellation Details',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w800,
  //                   color: Color(0xFF1E293B),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 20),
  //           Container(
  //             padding: EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Color(0xFFFEF2F2),
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Reason for Cancellation',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: Color(0xFF94A3B8),
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 SizedBox(height: 8),
  //                 Text(
  //                   'Patient requested to reschedule due to personal emergency.', // You can add this to your model
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     color: Color(0xFF1E293B),
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFloatingActionButtons() {
    final status = currentBooking.status.toLowerCase();
    final Color colorPrimary = Color(0xFF3CB8B8);
    final Color secondaryColor = Color(0xFF333F48);

    if (status == 'pending') {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Cancel Button
            Expanded(
              child: Container(
                height: 56,
                margin: EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showCancelDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Color(0xFFEF4444).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: Icon(Icons.cancel_outlined, size: 20),
                  label: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            // Update Button
            Expanded(
              child: Container(
                height: 56,
                margin: EdgeInsets.only(left: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          doctorsModel: widget.booking.doctor,
                          booking: BookingModel(
                            id: widget.booking.id,
                            fullName: widget.booking.patientName,
                            gender: widget.booking.patientGender,
                            age: int.tryParse(widget.booking.patientAge) ?? 0,
                            mobile: widget.booking.patientContact,
                            symptoms: widget.booking.reason,
                            preferredDate: widget.booking.preferredDate,
                            patientId: widget.booking.patientId,
                            status: "cancelled",
                            clinicId: widget.booking.clinicId,
                            doctorId: widget.booking.doctorId,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: colorPrimary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: Icon(Icons.edit_rounded, size: 20),
                  label: Text(
                    'Update',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'confirmed' || status == 'accepted') {
      return Container(
        width: double.infinity,
        height: 56,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: Color(0xFF10B981).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long_rounded, size: 22),
          ),
          label: Text(
            'Get Token',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );
    } else if (status == 'completed') {
      return Container(
        width: double.infinity,
        height: 56,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PdfPreviewPage(
                  bookingId: widget.booking.id,
                  detailsModel: widget.booking,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimary,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: colorPrimary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_rounded, size: 22),
          ),
          label: Text(
            'Get Prescription',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );
    } else if (status == 'cancelled') {
      return Container(
        width: double.infinity,
        height: 56,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            // Show cancel reason dialog or navigate to reason page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white70,
            elevation: 2,
            shadowColor: secondaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 22,
              color: Colors.white70,
            ),
          ),
          label: Text(
            'View Cancel Reason',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.5,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  // Add this method to your class
  void _showCancelDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    String selectedReason = '';
    bool isLoading = false;

    final List<String> quickReasons = [
      'Personal emergency',
      'Feeling better',
      'Schedule conflict',
      'Doctor not available',
      'Transportation issues',
      'Financial constraints',
      'Other',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Color(0xFFEF4444),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Cancel Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please select or enter a reason for cancellation',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    SizedBox(height: 24),

                    // Quick Reasons
                    Text(
                      'Quick Reasons',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Reason chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickReasons.map((reason) {
                        bool isSelected = selectedReason == reason;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedReason = reason;
                              if (reason != 'Other') {
                                reasonController.text = reason;
                              } else {
                                reasonController.clear();
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFFEF4444).withOpacity(0.1)
                                  : Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFFEF4444)
                                    : Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Color(0xFFEF4444)
                                    : Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20),

                    // Custom reason text field
                    Text(
                      'Additional Details (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                        color: Color(0xFFFAFAFA),
                      ),
                      child: TextField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: selectedReason == 'Other'
                              ? 'Please specify your reason...'
                              : 'Add any additional details...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                  },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Confirm button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    String reason = reasonController.text
                                        .trim();

                                    // Validation
                                    if (reason.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please select or enter a reason for cancellation',
                                          ),
                                          backgroundColor: Color(0xFFEF4444),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      ApiResult
                                      result = await BookingApi.updateBooking(
                                        BookingModel(
                                          note:
                                              reason, // Use the cancellation reason as note
                                          id: widget.booking.id,
                                          fullName: widget.booking.patientName,
                                          gender: widget.booking.patientGender,
                                          age:
                                              int.tryParse(
                                                widget.booking.patientAge,
                                              ) ??
                                              0,
                                          mobile: widget.booking.patientContact,
                                          symptoms: widget.booking.reason,
                                          preferredDate:
                                              widget.booking.preferredDate,
                                          patientId: widget.booking.patientId,
                                          status: "cancelled",
                                          clinicId: widget.booking.clinicId,
                                          doctorId: widget.booking.doctorId,
                                        ),
                                      );

                                      if (result.isOk) {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close dialog

                                        // Show success message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Appointment cancelled successfully',
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Color(0xFF10B981),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );

                                        // Navigate to home
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PatientLandingScreen(),
                                          ),
                                          (_) => false,
                                        );
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                        });

                                        // Show error message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to cancel appointment. Please try again.',
                                            ),
                                            backgroundColor: Color(0xFFEF4444),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'An error occurred. Please try again.',
                                          ),
                                          backgroundColor: Color(0xFFEF4444),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickInfoCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorPrimary.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: colorPrimary,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  formatDate(currentBooking.preferredDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: secondoryColor,
                  ),
                ),
                Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondoryColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorPrimary.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.access_time_rounded, color: colorPrimary, size: 24),
                SizedBox(height: 8),
                Text(
                  formatTime(currentBooking.preferredDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: secondoryColor,
                  ),
                ),
                Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondoryColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Add this method to your class
  void _showDeleteConfirmationDialog(BuildContext context) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Color(0xFFEF4444).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444),
                        size: 32,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Title
                    Text(
                      'Delete Confirmation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Message
                    Text(
                      'Are you sure you want to delete this item? This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                  },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Delete button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      // Replace this with your actual delete API call
                                      // Example: ApiResult result = await YourApi.deleteItem(itemId);

                                      // Simulate API call - replace with your actual API
                                      ApiResult result =
                                          await BookingApi.deleteBooking(
                                            widget.booking.id,
                                          );

                                      // Simulate successful deletion
                                      /*    bool deleteSuccess =
                                          true; // Replace with actual result check */

                                      if (result.isOk) {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close dialog

                                        // Show success message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Item deleted successfully',
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Color(0xFF10B981),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );

                                        // Navigate to home screen
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PatientLandingScreen(),
                                          ),
                                          (_) => false,
                                        );
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                        });

                                        // Show error message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to delete item. Please try again.',
                                            ),
                                            backgroundColor: Color(0xFFEF4444),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'An error occurred. Please try again.',
                                          ),
                                          backgroundColor: Color(0xFFEF4444),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



/* 
  

 
  Widget _buildPatientInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: secondoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: secondoryColor,
                    size: 26,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: secondoryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildPatientInfoRow(
              'Full Name',
              currentBooking.patientName,
              Icons.badge_rounded,
            ),
            SizedBox(height: 18),
            _buildPatientInfoRow(
              'Age',
              '${currentBooking.patientAge} years old',
              Icons.cake_rounded,
            ),
            SizedBox(height: 18),
            _buildPatientInfoRow(
              'Gender',
              currentBooking.patientGender,
              Icons.wc_rounded,
            ),
            SizedBox(height: 18),
            _buildPatientInfoRow(
              'Phone Number',
              currentBooking.patientContact,
              Icons.phone_rounded,
            ),
          ],
        ),
      ),
    );
  }

  
}/* 

  Widget _buildFloatingActionButtons() {
    final status = currentBooking.status.toLowerCase();

    if (status == 'pending') {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Cancel Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFDC2626).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  heroTag: "cancel",
                  onPressed: () async {
                    _showCancelDialog(context);
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: Icon(Icons.cancel_outlined, color: Colors.white, size: 22),
                  label: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            // Update Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  heroTag: "update",
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          doctorsModel: widget.booking.doctor,
                          booking: BookingModel(
                            id: widget.booking.id,
                            fullName: widget.booking.patientName,
                            gender: widget.booking.patientGender,
                            age: int.tryParse(widget */ */