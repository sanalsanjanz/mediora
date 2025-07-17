import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/organizations/booking_status_screen.dart';
import 'package:mediora/widgets/shimmer_box.dart';

class AllAppointmentsScreen extends StatefulWidget {
  const AllAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AllAppointmentsScreen> createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDateFilter = 0; // 0: Today, 1: This Week, 2: This Month
  List<BookingDetailsModel> _allBookings = [];
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        color: Color(0xFF667EEA),
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'All Appointments',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      backgroundColor: Color(0xFF667EEA),
      foregroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          color: Color(0xFF667EEA),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildDateFilters(),
              SizedBox(height: 10),
              _buildTabBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildDateFilterTab('Today', 0)),
          Expanded(child: _buildDateFilterTab('This Week', 1)),
          Expanded(child: _buildDateFilterTab('This Month', 2)),
        ],
      ),
    );
  }

  Widget _buildDateFilterTab(String title, int index) {
    bool isSelected = _selectedDateFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedDateFilter = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Color(0xFF667EEA) : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      dividerColor: Colors.transparent,
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.7),
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      tabs: [
        Tab(text: 'Confirmed'),
        Tab(text: 'Requests'),
        Tab(text: 'Completed'),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          5,
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
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBookingsList('confirmed'),
        _buildBookingsList('pending'),
        _buildBookingsList('completed'),
      ],
    );
  }

  Widget _buildBookingsList(String status) {
    final filteredBookings = _getFilteredBookings(status);

    if (filteredBookings.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(filteredBookings[index]);
      },
    );
  }

  List<BookingDetailsModel> _getFilteredBookings(String status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final thisWeekEnd = thisWeekStart.add(Duration(days: 6));
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(Duration(days: 1));

    List<BookingDetailsModel> statusFiltered = [];

    // Filter by status
    if (status == 'confirmed') {
      statusFiltered = _allBookings
          .where((booking) => booking.status.toLowerCase() == 'confirmed')
          .toList();
    } else if (status == 'pending') {
      statusFiltered = _allBookings
          .where((booking) => booking.status.toLowerCase() == 'pending')
          .toList();
    } else if (status == 'completed') {
      statusFiltered = _allBookings
          .where((booking) => booking.status.toLowerCase() == 'completed')
          .toList();
    }

    // Filter by date
    List<BookingDetailsModel> dateFiltered = [];
    switch (_selectedDateFilter) {
      case 0: // Today
        dateFiltered = statusFiltered.where((booking) {
          final bookingDate = DateTime(
            booking.preferredDate.year,
            booking.preferredDate.month,
            booking.preferredDate.day,
          );
          return bookingDate.isAtSameMomentAs(today);
        }).toList();
        break;
      case 1: // This Week
        dateFiltered = statusFiltered.where((booking) {
          final bookingDate = DateTime(
            booking.preferredDate.year,
            booking.preferredDate.month,
            booking.preferredDate.day,
          );
          return bookingDate.isAfter(
                thisWeekStart.subtract(Duration(days: 1)),
              ) &&
              bookingDate.isBefore(thisWeekEnd.add(Duration(days: 1)));
        }).toList();
        break;
      case 2: // This Month
        dateFiltered = statusFiltered.where((booking) {
          final bookingDate = DateTime(
            booking.preferredDate.year,
            booking.preferredDate.month,
            booking.preferredDate.day,
          );
          return bookingDate.isAfter(
                thisMonthStart.subtract(Duration(days: 1)),
              ) &&
              bookingDate.isBefore(thisMonthEnd.add(Duration(days: 1)));
        }).toList();
        break;
    }

    // Sort by date (newest first)
    dateFiltered.sort((a, b) => b.preferredDate.compareTo(a.preferredDate));

    return dateFiltered;
  }

  Widget _buildBookingCard(BookingDetailsModel booking) {
    Color statusColor = _getStatusColor(booking.status);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookingStatusScreen(booking: booking),
          ),
        );
      },
      child: Container(
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
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          statusColor.withOpacity(0.1),
                          statusColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM').format(booking.preferredDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateFormat('dd').format(booking.preferredDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ) /* Center(
                      child: Text(
                        booking.patientName[0].toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ), */,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          booking.patientName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Age ${booking.patientAge}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        /*   Text(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(booking.preferredDate),
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ), */
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status, statusColor),
                ],
              ),
              // SizedBox(height: 16),
              /* Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_rounded,
                        'Date',
                        DateFormat('MMM dd, yyyy').format(booking.preferredDate),
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    /*  Expanded(
                      child: _buildInfoItem(
                        Icons.access_time_rounded,
                        'Time',
                        DateFormat('hh:mm a').format(booking.preferredDate),
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]), */
                    Expanded(
                      child: _buildInfoItem(
                        Icons.phone_rounded,
                        'Contact',
                        booking.patientContact,
                      ),
                    ),
                  ],
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        /*    Icon(icon, color: Color(0xFF667EEA), size: 20),
        SizedBox(height: 4), */
        /*  Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ), */
        // SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Color(0xFF667EEA);
      case 'pending':
        return Color(0xFFF59E0B);
      case 'completed':
        return Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String status) {
    IconData icon;
    String title;
    String subtitle;
    Color color = _getStatusColor(status);

    switch (status) {
      case 'confirmed':
        icon = Icons.event_available_rounded;
        title = 'No confirmed appointments';
        subtitle = 'Confirmed appointments will appear here';
        break;
      case 'pending':
        icon = Icons.schedule_rounded;
        title = 'No pending requests';
        subtitle = 'New appointment requests will appear here';
        break;
      case 'completed':
        icon = Icons.check_circle_rounded;
        title = 'No completed appointments';
        subtitle = 'Completed appointments will appear here';
        break;
      default:
        icon = Icons.event_busy_rounded;
        title = 'No appointments';
        subtitle = 'Appointments will appear here';
    }

    String dateFilterText = '';
    switch (_selectedDateFilter) {
      case 0:
        dateFilterText = 'today';
        break;
      case 1:
        dateFilterText = 'this week';
        break;
      case 2:
        dateFilterText = 'this month';
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            SizedBox(height: 24),
            Text(
              '$title $dateFilterText',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
