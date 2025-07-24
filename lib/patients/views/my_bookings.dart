import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/helper/colors.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/patients/views/booking_details_screen.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with TickerProviderStateMixin {
  List<BookingDetailsModel> _allBookings = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

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
    _loadBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await BookingApi.getBookings();
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<BookingDetailsModel> get _filteredBookings {
    List<BookingDetailsModel> filtered = _allBookings;

    if (selectedFilter != 'all') {
      filtered = filtered
          .where((b) => b.status.toLowerCase() == selectedFilter.toLowerCase())
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (b) =>
                b.doctor.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                b.doctor.specialization.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                b.patientName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                b.reason.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                ? _buildErrorState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildSearchAndFilters(),
                        _buildBookingsList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: Colors.grey.shade700,
              size: 20,
            ),
          ),
          onPressed: () {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
            _animationController.reset();
            _loadBookings();
          },
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.waveDots(color: Color(0xFF6366F1), size: 50),
            SizedBox(height: 24),
            Text(
              'Loading your bookings...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors, appointments...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: TextStyle(fontSize: 16),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
          ),
          SizedBox(height: 20),

          // Filter Pills
          _buildFilterRow(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.grid_view_rounded},
      {
        'key': 'confirmed',
        'label': 'Confirmed',
        'icon': Icons.check_circle_outline_rounded,
      },
      {'key': 'pending', 'label': 'Pending', 'icon': Icons.schedule_rounded},
      {
        'key': 'completed',
        'label': 'Completed',
        'icon': Icons.task_alt_rounded,
      },
      {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter['key'];
          return Padding(
            padding: EdgeInsets.only(right: 12),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedFilter = filter['key'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? colorPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? colorPrimary : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(0xFF6366F1).withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      SizedBox(width: 8),
                      Text(
                        filter['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_filteredBookings.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _filteredBookings.asMap().entries.map((entry) {
          final index = entry.key;
          final booking = entry.value;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            child: _buildModernBookingCard(booking, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernBookingCard(BookingDetailsModel booking, int index) {
    final statusColors = {
      'confirmed': Color(0xFF10B981),
      'pending': Color(0xFFF59E0B),
      'completed': Color(0xFF6366F1),
      'cancelled': Color(0xFFEF4444),
    };

    final statusColor =
        statusColors[booking.status.toLowerCase()] ?? Colors.grey;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    BookingDetailsPage(
                      booking: booking,
                      onBookingUpdated: (updatedBooking) {
                        setState(() {
                          final index = _allBookings.indexWhere(
                            (b) => b.id == updatedBooking.id,
                          );
                          if (index != -1) _allBookings[index] = updatedBooking;
                        });
                      },
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      );
                    },
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorPrimary, secondoryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 24,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.doctor.specialization,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_rounded,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          booking.patientName,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey.shade400,
                        size: 16,
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

  Widget _buildErrorState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 40,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _animationController.reset();
                _loadBookings();
              },
              icon: Icon(Icons.refresh_rounded),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: Colors.grey.shade400,
                size: 48,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your appointment history will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCap on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
