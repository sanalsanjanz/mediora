import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/widgets/shimmer_box.dart';
import 'package:mediora/widgets/show_loading.dart';

class DoctorsLandingScreen extends StatefulWidget {
  const DoctorsLandingScreen({super.key, this.fcm});
  final String? fcm;
  @override
  State<DoctorsLandingScreen> createState() => _DoctorsLandingScreenState();
}

class _DoctorsLandingScreenState extends State<DoctorsLandingScreen> {
  int _currentIndex = 0;
  int _selectedBookingFilter = 0; // 0: Today, 1: Pending, 2: Completed
  List<BookingDetailsModel> _allBookings = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: _currentIndex == 0 ? _buildHomeScreen() : _buildProfileScreen(),
        /* bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Color(0xFF1E40AF),
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.white,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ), */
      ),
    );
  }

  Widget _buildHomeScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor: Color(0xFF1E40AF),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              ' ${PatientController.doctorModel?.user.name ?? 'Doctor'}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF3B82F6),
                    Color(0xFF60A5FA),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    top: 60,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: FutureBuilder(
              future: BookingApi.getBookings(
                doctorId: PatientController.doctorModel?.user.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(children: [shimmerBox()]);
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                } else if (!snapshot.hasData ||
                    (snapshot.data as List).isEmpty) {
                  return _buildEmptyState();
                }

                _allBookings = snapshot.data as List<BookingDetailsModel>;
                final patients = _allBookings
                    .map(
                      (b) => Patient(
                        name: b.patient.name,
                        age: b.patient.age,
                        phone: b.patientContact,
                        time: DateFormat('hh:mm a').format(b.preferredDate),
                        status: b.status,
                        appointmentDate: b.preferredDate,
                      ),
                    )
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDashboardCards(patients),
                    SizedBox(height: 24),

                    TabBar(
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent,
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: _buildFilterTab(
                            'Today',
                            0,
                            Icons.today_rounded,
                          ),
                        ),
                        Tab(
                          child: _buildFilterTab(
                            'Pending',
                            1,
                            Icons.schedule_rounded,
                          ),
                        ),
                        Tab(
                          child: _buildFilterTab(
                            'Completed',
                            2,
                            Icons.check_circle_rounded,
                          ),
                        ),
                      ],
                    ),
                    // _buildBookingFilterTabs(),
                    SizedBox(height: 16),
                    _buildFilteredBookings(patients),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCards(List<Patient> patients) {
    final today = DateTime.now();
    final todayBookings = patients
        .where(
          (p) =>
              p.status != "cancelled" &&
              p.appointmentDate.day == today.day &&
              p.appointmentDate.month == today.month &&
              p.appointmentDate.year == today.year,
        )
        .length;
    final pendingBookings = patients.where((p) => p.status == 'pending').length;
    final completedBookings = patients
        .where((p) => p.status == 'completed')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
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
                Color(0xFF1E40AF),
                Color(0xFFEBF4FF),
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

  Widget _buildBookingFilterTabs() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterTab('Today', 0, Icons.today_rounded)),
          Expanded(
            child: _buildFilterTab('Pending', 1, Icons.schedule_rounded),
          ),
          Expanded(
            child: _buildFilterTab('Completed', 2, Icons.check_circle_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, int index, IconData icon) {
    bool isSelected = _selectedBookingFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBookingFilter = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1E40AF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredBookings(List<Patient> allPatients) {
    List<Patient> filteredPatients = [];
    String sectionTitle = '';
    Color accentColor = Color(0xFF1E40AF);

    final today = DateTime.now();

    switch (_selectedBookingFilter) {
      case 0: // Today
        filteredPatients = allPatients
            .where(
              (p) =>
                  p.status.toLowerCase() != "cancelled" &&
                  p.appointmentDate.day == today.day &&
                  p.appointmentDate.month == today.month &&
                  p.appointmentDate.year == today.year,
            )
            .toList();
        sectionTitle = 'Today\'s Appointments';
        accentColor = Color(0xFF1E40AF);
        break;
      case 1: // Pending
        filteredPatients = allPatients
            .where((p) => p.status == 'pending')
            .toList();
        sectionTitle = 'Pending Appointments';
        accentColor = Color(0xFFF59E0B);
        break;
      case 2: // Completed
        filteredPatients = allPatients
            .where((p) => p.status == 'completed')
            .toList();
        sectionTitle = 'Completed Appointments';
        accentColor = Color(0xFF10B981);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${filteredPatients.length}',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        filteredPatients.isEmpty
            ? _buildEmptyBookingState(sectionTitle)
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  return _buildEnhancedPatientCard(
                    filteredPatients[index],
                    accentColor,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyBookingState(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: Colors.grey[400],
              size: 48,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No ${title.toLowerCase()}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPatientCard(Patient patient, Color accentColor) {
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
                  patient.name[0].toUpperCase(),
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
                    patient.name,
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
                        'Age ${patient.age}',
                        Colors.grey[600]!,
                      ),
                      SizedBox(width: 12),
                      _buildPatientInfoChip(
                        Icons.access_time_rounded,
                        patient.time,
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
                color: Color(0xFF1E40AF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _makePhoneCall(patient.phone),
                child: Icon(
                  Icons.phone_rounded,
                  color: Color(0xFF1E40AF),
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

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 64),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[400],
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, color: Colors.grey[400], size: 64),
          SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your appointments will appear here',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor: Color(0xFF1E40AF),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF3B82F6),
                    Color(0xFF60A5FA),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildEnhancedProfileHeader(),
                SizedBox(height: 24),
                _buildEnhancedProfileDetails(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E40AF).withOpacity(0.1),
                  Color(0xFF3B82F6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: Color(0xFF1E40AF),
            ),
          ),
          SizedBox(height: 20),
          Text(
            PatientController.doctorModel?.user.name ?? 'Dr. John Smith',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF1E40AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Cardiologist',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProfileDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1E40AF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showEditProfileDialog(),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF1E40AF),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildEnhancedProfileItem(
            Icons.email_rounded,
            'Email Address',
            PatientController.doctorModel?.user.email ??
                'dr.smith@hospital.com',
          ),
          SizedBox(height: 20),
          _buildEnhancedProfileItem(
            Icons.phone_rounded,
            'Phone Number',
            PatientController.doctorModel?.user.contactNumber ??
                '+1 (555) 123-4567',
          ),
          SizedBox(height: 20),
          _buildEnhancedProfileItem(
            Icons.location_on_rounded,
            'Address',
            '123 Medical Center, City, State',
          ),
          SizedBox(height: 20),
          _buildEnhancedProfileItem(
            Icons.school_rounded,
            'Education',
            'MD, Harvard Medical School',
          ),
          SizedBox(height: 20),
          _buildEnhancedProfileItem(
            Icons.work_rounded,
            'Experience',
            '15+ years',
          ),
          SizedBox(height: 20),
          _buildEnhancedProfileItem(
            Icons.verified_rounded,
            'Medical License',
            'MD12345',
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProfileItem(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1E40AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF1E40AF), size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        backgroundColor: Color(0xFF1E40AF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Profile editing feature will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E40AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class Patient {
  final String name;
  final int age;
  final String phone;
  final String time;
  final String status;
  final DateTime appointmentDate;

  Patient({
    required this.name,
    required this.age,
    required this.phone,
    required this.time,
    required this.status,
    required this.appointmentDate,
  });
}
