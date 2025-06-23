import 'package:flutter/material.dart';
import 'package:mediora/patients/views/booking_details_screen.dart';

class Booking {
  final int id;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String status;
  final String type;
  final String location;
  final String phone;
  final String email;
  final String notes;
  final String bookingRef;

  Booking({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.location,
    required this.phone,
    required this.email,
    required this.notes,
    required this.bookingRef,
  });
}

class MyBookingsPage extends StatefulWidget {
  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with TickerProviderStateMixin {
  String selectedFilter = 'all';
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<Booking> bookings = [
    Booking(
      id: 1,
      doctorName: "Dr. Sarah Johnson",
      specialty: "Cardiologist",
      date: "2025-06-25",
      time: "10:30 AM",
      status: "confirmed",
      type: "Consultation",
      location: "Heart Care Center, Room 205",
      phone: "+1 (555) 123-4567",
      email: "appointments@heartcare.com",
      notes: "Regular checkup and blood pressure monitoring",
      bookingRef: "HC2025001",
    ),
    Booking(
      id: 2,
      doctorName: "Dr. Michael Chen",
      specialty: "Dermatologist",
      date: "2025-06-28",
      time: "2:15 PM",
      status: "pending",
      type: "Follow-up",
      location: "Skin Care Clinic, Floor 3",
      phone: "+1 (555) 987-6543",
      email: "info@skincareclinic.com",
      notes: "Skin condition follow-up appointment",
      bookingRef: "SC2025002",
    ),
    Booking(
      id: 3,
      doctorName: "Dr. Emily Rodriguez",
      specialty: "Pediatrician",
      date: "2025-06-30",
      time: "11:00 AM",
      status: "completed",
      type: "Vaccination",
      location: "Children's Health Center",
      phone: "+1 (555) 456-7890",
      email: "vaccines@childrenshealth.com",
      notes: "Annual vaccination schedule",
      bookingRef: "CH2025003",
    ),
    Booking(
      id: 4,
      doctorName: "Dr. James Wilson",
      specialty: "Orthopedic",
      date: "2025-07-02",
      time: "9:45 AM",
      status: "cancelled",
      type: "Surgery Consultation",
      location: "Orthopedic Specialists",
      phone: "+1 (555) 321-0987",
      email: "consultations@orthospec.com",
      notes: "Knee surgery consultation",
      bookingRef: "OS2025004",
    ),
  ];

  List<Booking> get filteredBookings {
    List<Booking> filtered = bookings;

    if (selectedFilter != 'all') {
      filtered = filtered
          .where((booking) => booking.status == selectedFilter)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (booking) =>
                booking.doctorName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                booking.specialty.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                booking.type.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
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
    switch (status) {
      case 'confirmed':
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

  void _showNewBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'New Booking',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text('This would navigate to the new booking form.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: Color(0xFF3B82F6))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Color(0xFF2E86AB),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Bookings',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E86AB), // Medical blue
                      Color(0xFF4ECDC4), // Calm teal
                      Color(0xFF45B7D1),
                    ], // Light blue],
                  ),
                ),
              ),
            ),
          ),

          // Search and Filter Section
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Modern Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search doctors, specialties...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Modern Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModernFilterChip(
                          'all',
                          'All',
                          filteredBookings.length,
                        ),
                        SizedBox(width: 12),
                        _buildModernFilterChip(
                          'confirmed',
                          'Confirmed',
                          bookings.where((b) => b.status == 'confirmed').length,
                        ),
                        SizedBox(width: 12),
                        _buildModernFilterChip(
                          'pending',
                          'Pending',
                          bookings.where((b) => b.status == 'pending').length,
                        ),
                        SizedBox(width: 12),
                        _buildModernFilterChip(
                          'completed',
                          'Completed',
                          bookings.where((b) => b.status == 'completed').length,
                        ),
                        SizedBox(width: 12),
                        _buildModernFilterChip(
                          'cancelled',
                          'Cancelled',
                          bookings.where((b) => b.status == 'cancelled').length,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bookings List
          filteredBookings.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 48,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'No bookings found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filter',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final booking = filteredBookings[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: _buildModernBookingCard(booking),
                      ),
                    );
                  }, childCount: filteredBookings.length),
                ),
        ],
      ),

      // Modern FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showNewBookingDialog,
          backgroundColor: Color(0xFF3B82F6),
          elevation: 0,
          icon: Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'New Booking',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(String value, String label, int count) {
    final isSelected = selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF3B82F6) : Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF3B82F6).withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF475569),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBookingCard(Booking booking) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailsPage(
                  booking: booking,
                  onBookingUpdated: (updatedBooking) {
                    setState(() {
                      int index = bookings.indexWhere(
                        (b) => b.id == updatedBooking.id,
                      );
                      if (index != -1) {
                        bookings[index] = updatedBooking;
                      }
                    });
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.doctorName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.specialty,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(booking.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(booking.status),
                            size: 16,
                            color: getStatusColor(booking.status),
                          ),
                          SizedBox(width: 6),
                          Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: getStatusColor(booking.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_rounded,
                        'Date',
                        booking.date,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time_rounded,
                        'Time',
                        booking.time,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                /*   Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.medical_services_rounded,
                        'Type',
                        booking.type,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.location_on_rounded,
                        'Location',
                        booking.location,
                        isLocation: true,
                      ),
                    ),
                  ],
                ), */
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    bool isLocation = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Color(0xFF64748B)),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: isLocation ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
