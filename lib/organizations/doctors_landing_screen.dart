import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/helper/call_navigation_helper.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/organizations/booking_status_screen.dart';
import 'package:mediora/organizations/manage_appointments.dart';
import 'package:mediora/organizations/org_doc_screen.dart';
import 'package:mediora/widgets/shimmer_box.dart';

class DoctorsLandingScreen extends StatefulWidget {
  const DoctorsLandingScreen({super.key, this.fcm});
  final String? fcm;
  @override
  State<DoctorsLandingScreen> createState() => _DoctorsLandingScreenState();
}

class _DoctorsLandingScreenState extends State<DoctorsLandingScreen> {
  List<BookingDetailsModel> _allBookings = [];
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final bookings = await BookingApi.getBookings(
        doctorId: PatientController.doctorModel?.user.id,
      );

      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        color: Color(0xFF1E40AF),
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildModernHeader(),
            SliverToBoxAdapter(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ],
        ),
      ),
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time and Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'EEEE, dd MMM',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('hh:mm a').format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Profile Avatar
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (c) => OrgDocScreen(),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'doctor_avatar',
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: CachedNetworkImageProvider(
                                    PatientController.doctorModel?.user.image ??
                                        '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Doctor Name and Greeting
                      Text(
                        'Good ${_getGreeting()},\n${PatientController.doctorModel?.user.name ?? 'Doctor'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ready to help your patients today?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildShimmerCards(),
          SizedBox(height: 24),
          _buildShimmerList(),
        ],
      ),
    );
  }

  Widget _buildShimmerCards() {
    return Row(
      children: [
        Expanded(child: _buildShimmerCard()),
        SizedBox(width: 12),
        Expanded(child: _buildShimmerCard()),
        SizedBox(width: 12),
        Expanded(child: _buildShimmerCard()),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shimmerBox(width: 40, height: 40),
            SizedBox(height: 8),
            shimmerBox(width: 30, height: 20),
            SizedBox(height: 4),
            shimmerBox(width: 60, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              shimmerBox(width: 56, height: 56),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerBox(width: 120, height: 16),
                    SizedBox(height: 8),
                    shimmerBox(width: 80, height: 12),
                    SizedBox(height: 8),
                    shimmerBox(width: 60, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardCards(),
          SizedBox(height: 32),
          _buildTodaysAppointments(),
        ],
      ),
    );
  }

  Widget _buildDashboardCards() {
    final today = DateTime.now();
    final todayBookings = _allBookings
        .where(
          (p) =>
              p.status != "cancelled" &&
              p.preferredDate.day == today.day &&
              p.preferredDate.month == today.month &&
              p.preferredDate.year == today.year,
        )
        .length;
    final pendingBookings = _allBookings
        .where((p) => p.status == 'pending')
        .length;
    final completedBookings = _allBookings
        .where((p) => p.status == 'completed')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEnhancedDashboardCard(
                'Today\'s Appointments',
                todayBookings.toString(),
                Icons.today_rounded,
                Color(0xFF667EEA),
                Color(0xFFEEF2FF),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedDashboardCard(
                'Pending',
                pendingBookings.toString(),
                Icons.schedule_rounded,
                Color(0xFFF59E0B),
                Color(0xFFFEF3C7),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedDashboardCard(
                'Completed',
                completedBookings.toString(),
                Icons.check_circle_rounded,
                Color(0xFF10B981),
                Color(0xFFD1FAE5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedDashboardCard(
    String title,
    String count,
    IconData icon,
    Color primaryColor,
    Color backgroundColor,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysAppointments() {
    final today = DateTime.now();
    final todayBookings = _allBookings
        .where(
          (p) =>
              p.status.toLowerCase() != "cancelled" &&
              p.preferredDate.day == today.day &&
              p.preferredDate.month == today.month &&
              p.preferredDate.year == today.year,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Appointments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to view all appointments
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllAppointmentsScreen(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF667EEA),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        todayBookings.isEmpty
            ? _buildEmptyTodayState()
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: todayBookings.length > 3 ? 3 : todayBookings.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingStatusScreen(
                            booking: todayBookings[index],
                          ),
                        ),
                      );
                    },
                    child: _buildEnhancedPatientCard(
                      todayBookings[index],
                      Color(0xFF667EEA),
                    ),
                  );
                },
              ),
        if (todayBookings.length > 3)
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllAppointmentsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Show ${todayBookings.length - 3} more appointments',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyTodayState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: Color(0xFF667EEA),
              size: 48,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No appointments today',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enjoy your free time!',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPatientCard(
    BookingDetailsModel patient,
    Color accentColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withOpacity(0.1),
                    accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  patient.patientName[0].toUpperCase(),
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.patientName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      _buildPatientInfoChip(
                        Icons.person_outline_rounded,
                        'Age ${patient.patientAge}',
                        Colors.grey[600]!,
                      ),
                      SizedBox(width: 12),
                      _buildPatientInfoChip(
                        Icons.access_time_rounded,
                        DateFormat("hh:mm a").format(patient.preferredDate),
                        Colors.grey[600]!,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildStatusChip(patient.status, accentColor),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () =>
                    makeCall(phone: patient.patientContact, context: context),
                child: Icon(
                  Icons.phone_rounded,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /*  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to register booking screen
        _showRegisterBookingDialog();
      },
      backgroundColor: Color(0xFF667EEA),
      icon: Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'New Booking',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  } */

  void _showRegisterBookingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Register New Booking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 20),
              // Add your booking form here
              Text(
                'Booking form will be implemented here',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.phone_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Calling $phoneNumber...'),
          ],
        ),
        backgroundColor: Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
