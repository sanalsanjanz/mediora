import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoctorsListingScreen extends StatefulWidget {
  const DoctorsListingScreen({super.key});

  @override
  _DoctorsListingScreenState createState() => _DoctorsListingScreenState();
}

class _DoctorsListingScreenState extends State<DoctorsListingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    'All',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Dermatology',
    'Pediatrics',
    'Gynecology',
    'Psychiatry',
    'Ophthalmology',
    'ENT',
    'General Medicine',
  ];

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiology',
      'image':
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop&crop=face',
      'rating': 4.9,
      'reviews': 234,
      'experience': '15 years',
      'availableTime': '9:00 AM - 6:00 PM',
      'distance': '2.5 km',
      'nextAvailable': 'Today 3:00 PM',
      'consultationFee': '₹800',
      'isOnline': true,
    },
    {
      'name': 'Dr. Michael Chen',
      'specialty': 'Neurology',
      'image':
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&h=300&fit=crop&crop=face',
      'rating': 4.8,
      'reviews': 189,
      'experience': '12 years',
      'availableTime': '10:00 AM - 8:00 PM',
      'distance': '1.2 km',
      'nextAvailable': 'Tomorrow 10:00 AM',
      'consultationFee': '₹1200',
      'isOnline': false,
    },
    {
      'name': 'Dr. Emily Rodriguez',
      'specialty': 'Dermatology',
      'image':
          'https://images.unsplash.com/photo-1594824506871-a4dbc0c3e942?w=300&h=300&fit=crop&crop=face',
      'rating': 4.7,
      'reviews': 156,
      'experience': '8 years',
      'availableTime': '11:00 AM - 7:00 PM',
      'distance': '3.8 km',
      'nextAvailable': 'Today 5:30 PM',
      'consultationFee': '₹600',
      'isOnline': true,
    },
    {
      'name': 'Dr. James Wilson',
      'specialty': 'Orthopedics',
      'image':
          'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&h=300&fit=crop&crop=face',
      'rating': 4.9,
      'reviews': 298,
      'experience': '20 years',
      'availableTime': '8:00 AM - 5:00 PM',
      'distance': '4.2 km',
      'nextAvailable': 'Tomorrow 2:00 PM',
      'consultationFee': '₹1000',
      'isOnline': false,
    },
    {
      'name': 'Dr. Priya Sharma',
      'specialty': 'Pediatrics',
      'image':
          'https://images.unsplash.com/photo-1551884831-bbf3cdc6469e?w=300&h=300&fit=crop&crop=face',
      'rating': 4.8,
      'reviews': 167,
      'experience': '10 years',
      'availableTime': '9:00 AM - 6:00 PM',
      'distance': '2.1 km',
      'nextAvailable': 'Today 4:15 PM',
      'consultationFee': '₹700',
      'isOnline': true,
    },
    {
      'name': 'Dr. Robert Kim',
      'specialty': 'Psychiatry',
      'image':
          'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=300&h=300&fit=crop&crop=face',
      'rating': 4.6,
      'reviews': 134,
      'experience': '14 years',
      'availableTime': '12:00 PM - 9:00 PM',
      'distance': '5.5 km',
      'nextAvailable': 'Tomorrow 1:00 PM',
      'consultationFee': '₹1500',
      'isOnline': true,
    },
    {
      'name': 'Dr. Lisa Thompson',
      'specialty': 'Gynecology',
      'image':
          'https://images.unsplash.com/photo-1638202993928-7267aad84c31?w=300&h=300&fit=crop&crop=face',
      'rating': 4.9,
      'reviews': 203,
      'experience': '16 years',
      'availableTime': '10:00 AM - 6:00 PM',
      'distance': '3.2 km',
      'nextAvailable': 'Today 6:00 PM',
      'consultationFee': '₹900',
      'isOnline': false,
    },
  ];

  List<Map<String, dynamic>> get filteredDoctors {
    List<Map<String, dynamic>> filtered = doctors;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where(
            (doctor) => doctor['specialty'].toLowerCase().contains(
              _selectedCategory.toLowerCase(),
            ),
          )
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (doctor) =>
                doctor['name'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                doctor['specialty'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(flexibleSpace: Container(),
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF3CB8B8),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ), */
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E86AB), // Medical blue
                Color(0xFF4ECDC4), // Calm teal
                Color(0xFF45B7D1), // Light blue
              ], // Adjust colors as needed
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            toolbarHeight: 0,
            foregroundColor: Colors.white,
            /* leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
            ), */
            /*  actions: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ], */
            // toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildMedicalBanner(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCategoryFilter(), _buildDoctorsList(),
                  // Expanded(child: ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          /* begin: Alignment.topLeft,
          end: Alignment.bottomRight, */
          colors: [
            Color(0xFF2E86AB), // Medical blue
            Color(0xFF4ECDC4), // Calm teal
            Color(0xFF45B7D1), // Light blue
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
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
            top: 30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 50,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Medical cross pattern
          Positioned(
            top: 20,
            right: 30,
            child: Icon(
              Icons.medical_services,
              color: Colors.white.withOpacity(0.2),
              size: 40,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 30,
            child: Icon(
              Icons.health_and_safety,
              color: Colors.white.withOpacity(0.15),
              size: 35,
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*  Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), */
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find Your Doctor',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '"The best doctor gives the least medicines"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Trusted Healthcare Partners',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search doctors, specialties...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: 8, right: 8, bottom: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                height: 30,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsList() {
    final filtered = filteredDoctors;

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(20),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildDoctorCard(filtered[index], index);
        },
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to doctor details
            },
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'doctor_${doctor['name']}',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blue[300]!, Colors.blue[600]!],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                doctor['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    doctor['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                if (doctor['isOnline'])
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              doctor['specialty'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '${doctor['rating']} (${doctor['reviews']})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${doctor['experience']} exp',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  /* ss */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                colors: [Colors.blue[100]!, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 60, color: Colors.blue[300]),
          ),
          SizedBox(height: 24),
          Text(
            'No doctors found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'We couldn\'t find any doctors matching your criteria. Try adjusting your search or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _searchController.clear();
                _searchQuery = '';
              });
            },
            icon: Icon(Icons.refresh),
            label: Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
