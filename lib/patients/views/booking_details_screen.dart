import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/models/booking_model.dart';
import 'package:mediora/patients/views/book_appointment.dart';
import 'package:mediora/patients/views/patient_home_screen.dart';

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
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
                onPressed: () {
                  if (widget.isFromNotification) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PatientHomeScreen()),
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
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                      Color(0xFF6B73FF),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/medical_pattern.png'),
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Details',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        getStatusIcon(currentBooking.status),
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        currentBooking.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              if (widget.booking.status.toLowerCase() ==
                                  "pending")
                                IconButton(
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context);
                                  },
                                  icon: Icon(Icons.delete, color: Colors.white),
                                ),
                              /* Text(
                                'ID: ${currentBooking.id}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ), */
                            ],
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
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Information Card
                      _buildDoctorInfoCard(),
                      SizedBox(height: 20),

                      // Patient Information Card
                      _buildPatientInfoCard(),
                      SizedBox(height: 20),

                      // Appointment Details Card
                      _buildAppointmentDetailsCard(),
                      SizedBox(height: 20),

                      // Status-specific Information
                      if (currentBooking.status.toLowerCase() == 'cancelled')
                        _buildCancelReasonCard(),
                      SizedBox(height: 20),
                      _buildFloatingActionButtons(),
                      SizedBox(height: 20),

                      // Space for floating buttons
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${currentBooking.doctor.name}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentBooking.doctor.specialization,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      /* Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4.8', // You can add rating to your model
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(120 reviews)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ), */
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinic Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currentBooking.doctor.locationName ??
                              'Medical Center',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
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
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildPatientInfoRow(
              'Name',
              currentBooking.patientName,
              Icons.person_rounded,
            ),
            SizedBox(height: 16),
            _buildPatientInfoRow(
              'Age',
              '${currentBooking.patientAge} years',
              Icons.cake_rounded,
            ),
            SizedBox(height: 16),
            _buildPatientInfoRow(
              'Gender',
              currentBooking.patientGender,
              Icons.wc_rounded,
            ),
            SizedBox(height: 16),
            _buildPatientInfoRow(
              'Contact',
              currentBooking.patientContact,
              Icons.phone_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoRow(String label, String value, IconData icon) {
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
  }

  Widget _buildAppointmentDetailsCard() {
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
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelReasonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFEF4444).withOpacity(0.2)),
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
                    color: Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Cancellation Details',
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
                color: Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for Cancellation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Patient requested to reschedule due to personal emergency.', // You can add this to your model
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
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

  Widget _buildFloatingActionButtons() {
    final status = currentBooking.status.toLowerCase();

    if (status == 'pending') {
      return Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel Button
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: "cancel",
              onPressed: () async {
                _showCancelDialog(context);
              },
              backgroundColor: Color(0xFFEF4444),
              icon: Icon(Icons.cancel_outlined, color: Colors.white),
              label: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Update Button
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: "update",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(
                      doctorsModel: widget.booking.doctor,
                      booking: BookingModel(
                        // Use the cancellation reason as note
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
              backgroundColor: Color(0xFF667EEA),
              icon: Icon(Icons.edit_rounded, color: Colors.white),
              label: Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'confirmed' || status == 'accepted') {
      return FloatingActionButton.extended(
        heroTag: "token",
        onPressed: () {},
        backgroundColor: Color(0xFF10B981),
        icon: Icon(Icons.receipt_long_rounded, color: Colors.white),
        label: Text(
          'Get Token',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else if (status == 'completed') {
      return FloatingActionButton.extended(
        heroTag: "prescription",
        onPressed: () {},
        backgroundColor: Color(0xFF3B82F6),
        icon: Icon(Icons.receipt_rounded, color: Colors.white),
        label: Text(
          'Get Prescription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else if (status == 'cancelled') {
      // return FloatingActionButton.extended(
      //   heroTag: "reason",
      //   onPressed: () {},
      //   backgroundColor: Color(0xFF64748B),
      //   icon: Icon(Icons.info_outline_rounded, color: Colors.white),
      //   label: Text(
      //     'Cancel Reason',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      //   ),
      // );
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
                                            builder: (_) => PatientHomeScreen(),
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
                                            builder: (_) => PatientHomeScreen(),
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
