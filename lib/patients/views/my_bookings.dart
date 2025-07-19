import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/patients/views/booking_details_screen.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
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
    searchController.dispose();
    super.dispose();
  }

  List<BookingDetailsModel> filterBookings(List<BookingDetailsModel> bookings) {
    List<BookingDetailsModel> filtered = bookings;

    if (selectedFilter != 'all') {
      filtered = filtered
          .where(
            (booking) =>
                booking.status.toLowerCase() == selectedFilter.toLowerCase(),
          )
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (booking) =>
                booking.doctor.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                booking.doctor.specialization.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                booking.patientName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                booking.reason.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
    switch (status.toLowerCase()) {
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

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  void _showNewBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'New Booking',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            'This would navigate to the new booking form where you can schedule an appointment with your preferred doctor.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to new booking form
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3CB8B8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'BOOK NOW',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
      body: FutureBuilder<List<BookingDetailsModel>>(
        future: BookingApi.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final bookings = snapshot.data ?? [];
          final filteredBookings = filterBookings(bookings);

          return CustomScrollView(
            slivers: [
              // Enhanced App Bar
              SliverAppBar(
                expandedHeight: 60,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3CB8B8), Color(0xFF333F48)],
                      ),
                    ),
                  ),
                ),
              ),

              // Search and Filter Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Enhanced Search Bar
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(20),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black.withOpacity(0.08),
                          //         blurRadius: 20,
                          //         offset: Offset(0, 8),
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextField(
                          //     controller: searchController,
                          //     decoration: InputDecoration(
                          //       hintText:
                          //           'Search doctors, specialties, or reasons...',
                          //       hintStyle: TextStyle(
                          //         color: Color(0xFF94A3B8),
                          //         fontSize: 16,
                          //       ),
                          //       prefixIcon: Container(
                          //         padding: EdgeInsets.all(12),
                          //         child: Icon(
                          //           Icons.search_rounded,
                          //           color: Color(0xFF64748B),
                          //           size: 24,
                          //         ),
                          //       ),
                          //       suffixIcon: searchQuery.isNotEmpty
                          //           ? IconButton(
                          //               icon: Icon(
                          //                 Icons.clear_rounded,
                          //                 color: Color(0xFF64748B),
                          //               ),
                          //               onPressed: () {
                          //                 searchController.clear();
                          //                 setState(() {
                          //                   searchQuery = '';
                          //                 });
                          //               },
                          //             )
                          //           : null,
                          //       border: InputBorder.none,
                          //       contentPadding: EdgeInsets.symmetric(
                          //         horizontal: 20,
                          //         vertical: 18,
                          //       ),
                          //     ),
                          //     onChanged: (value) {
                          //       setState(() {
                          //         searchQuery = value;
                          //       });
                          //     },
                          //   ),
                          // ),
                          SizedBox(height: 24),

                          // Enhanced Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildEnhancedFilterChip(
                                  'all',
                                  'All',
                                  filteredBookings.length,
                                  Icons.list_rounded,
                                ),
                                SizedBox(width: 12),
                                _buildEnhancedFilterChip(
                                  'confirmed',
                                  'Confirmed',
                                  bookings
                                      .where(
                                        (b) =>
                                            b.status.toLowerCase() ==
                                            'confirmed',
                                      )
                                      .length,
                                  Icons.check_circle_rounded,
                                ),
                                SizedBox(width: 12),
                                _buildEnhancedFilterChip(
                                  'pending',
                                  'Pending',
                                  bookings
                                      .where(
                                        (b) =>
                                            b.status.toLowerCase() == 'pending',
                                      )
                                      .length,
                                  Icons.schedule_rounded,
                                ),
                                SizedBox(width: 12),
                                _buildEnhancedFilterChip(
                                  'completed',
                                  'Completed',
                                  bookings
                                      .where(
                                        (b) =>
                                            b.status.toLowerCase() ==
                                            'completed',
                                      )
                                      .length,
                                  Icons.task_alt_rounded,
                                ),
                                SizedBox(width: 12),
                                _buildEnhancedFilterChip(
                                  'cancelled',
                                  'Cancelled',
                                  bookings
                                      .where(
                                        (b) =>
                                            b.status.toLowerCase() ==
                                            'cancelled',
                                      )
                                      .length,
                                  Icons.cancel_rounded,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bookings List
              filteredBookings.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final booking = filteredBookings[index];
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: _buildEnhancedBookingCard(booking),
                            ),
                          ),
                        );
                      }, childCount: filteredBookings.length),
                    ),
            ],
          );
        },
      ),

      // Enhanced FAB
      /*  floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667EEA).withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showNewBookingDialog,
          backgroundColor: Color(0xFF667EEA),
          elevation: 0,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: Text(
            'New Booking',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ), */
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 60,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              'My Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3CB8B8), Color(0xFF333F48)],
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: LoadingAnimationWidget.flickr(
                    leftDotColor: Color(0xFF3CB8B8),
                    rightDotColor: Color.fromARGB(255, 175, 235, 235),
                    size: 45,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading your bookings...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedInfoItem(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
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
                  letterSpacing: 0.5,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 60,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              'My Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3CB8B8), Color(0xFF333F48)],
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Color(0xFFEF4444),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3CB8B8), Color(0xFF333F48)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 60,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          SizedBox(height: 32),
          Text(
            searchQuery.isNotEmpty || selectedFilter != 'all'
                ? 'No matching bookings'
                : 'No bookings yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty || selectedFilter != 'all'
                ? 'Try adjusting your search or filter'
                : 'Book your first appointment with a doctor',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: searchQuery.isNotEmpty || selectedFilter != 'all'
                ? () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                      selectedFilter = 'all';
                    });
                  }
                : _showNewBookingDialog,
            icon: Icon(
              searchQuery.isNotEmpty || selectedFilter != 'all'
                  ? Icons.clear_all_rounded
                  : Icons.add_rounded,
              color: Colors.white,
            ),
            label: Text(
              searchQuery.isNotEmpty || selectedFilter != 'all'
                  ? 'Clear Filters'
                  : 'Book Now',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3CB8B8),

              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFilterChip(
    String value,
    String label,
    int count,
    IconData icon,
  ) {
    final isSelected = selectedFilter == value;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF3CB8B8) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Color(0xFF3CB8B8) : Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(0xFF3CB8B8).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Color(0xFF64748B),
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBookingCard(BookingDetailsModel booking) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailsPage(
                  booking: booking,
                  onBookingUpdated: (updatedBooking) {
                    setState(() {
                      // Update the booking in your data source
                    });
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3CB8B8), Color(0xFF333F48)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        FontAwesome.stethoscope_solid,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.doctor.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.doctor.specialization,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                              fontWeight: FontWeight.w800,
                              color: getStatusColor(booking.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Enhanced Info Grid
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildEnhancedInfoItem(
                              Icons.calendar_today_rounded,
                              'Date',
                              formatDate(booking.preferredDate),
                              Color(0xFF3CB8B8),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildEnhancedInfoItem(
                              Icons.access_time_rounded,
                              'Time',
                              formatTime(booking.createdAt),
                              Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEnhancedInfoItem(
                              Icons.person_rounded,
                              'Patient',
                              booking.patientName,
                              Color(0xFFF59E0B),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildEnhancedInfoItem(
                              Icons.medical_services_rounded,
                              'Reason',
                              booking.reason,
                              Color(0xFFEF4444),
                            ),
                          ),
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
    );
  }
}
