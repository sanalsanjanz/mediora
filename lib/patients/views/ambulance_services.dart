import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmbulanceService {
  final String name;
  final String imageUrl;
  final String phoneNumber;
  final double distance;
  final String address;
  final bool isAvailable;
  final double rating;

  AmbulanceService({
    required this.name,
    required this.imageUrl,
    required this.phoneNumber,
    required this.distance,
    required this.address,
    required this.isAvailable,
    required this.rating,
  });
}

class NearestAmbulanceScreen extends StatefulWidget {
  const NearestAmbulanceScreen({super.key});

  @override
  _NearestAmbulanceScreenState createState() => _NearestAmbulanceScreenState();
}

class _NearestAmbulanceScreenState extends State<NearestAmbulanceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<AmbulanceService> ambulanceServices = [
    AmbulanceService(
      name: "City Medical Emergency",
      imageUrl:
          "https://images.unsplash.com/photo-1571772996211-2f02c9727629?w=300&h=200&fit=crop",
      phoneNumber: "+1-555-0123",
      distance: 0.8,
      address: "123 Main St, Downtown",
      isAvailable: true,
      rating: 4.8,
    ),
    AmbulanceService(
      name: "QuickCare Ambulance",
      imageUrl:
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=200&fit=crop",
      phoneNumber: "+1-555-0456",
      distance: 1.2,
      address: "456 Oak Ave, Midtown",
      isAvailable: true,
      rating: 4.6,
    ),
    AmbulanceService(
      name: "Metro Health Services",
      imageUrl:
          "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&h=200&fit=crop",
      phoneNumber: "+1-555-0789",
      distance: 1.5,
      address: "789 Pine Rd, Uptown",
      isAvailable: false,
      rating: 4.4,
    ),
    AmbulanceService(
      name: "Rapid Response EMS",
      imageUrl:
          "https://images.unsplash.com/photo-1516549655169-df83a0774514?w=300&h=200&fit=crop",
      phoneNumber: "+1-555-0321",
      distance: 2.1,
      address: "321 Elm St, Eastside",
      isAvailable: true,
      rating: 4.7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
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
    super.dispose();
  }

  void _makePhoneCall(String phoneNumber) {
    // In a real app, you would use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2E86AB),
        elevation: 0,
        /*  expandedHeight: 320, */
        automaticallyImplyLeading: false,
        // expandedHeight: 300.0,
        /*  floating: false, */

        // pinned: true,
        // flexibleSpace: FlexibleSpaceBar(background: _buildHeader(context)),
        toolbarHeight: 0,
      ),

      backgroundColor: Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildEmergencyButton(),
            Expanded(child: _buildAmbulanceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E86AB), // Medical blue
            Color(0xFF4ECDC4), // Calm teal
            Color(0xFF45B7D1), // Light blue
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Emergency Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Nearest ambulance services to your location',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Current Location',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => _makePhoneCall('108'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE53E3E),
          foregroundColor: Colors.white,
          fixedSize: Size(double.maxFinite, 50),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 8,
          shadowColor: Color(0xFFE53E3E).withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emergency, size: 20),
            SizedBox(width: 12),
            Text(
              'EMERGENCY CALL 108',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbulanceList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: ambulanceServices.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildAmbulanceCard(ambulanceServices[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAmbulanceCard(AmbulanceService service) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.local_hospital,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: service.isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.isAvailable ? 'Available' : 'Busy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '${service.distance} km',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          service.rating.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF718096),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        service.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _makePhoneCall(service.phoneNumber),
                        icon: Icon(Icons.phone, size: 18),
                        label: Text('Call Now'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF667EEA),
                          side: BorderSide(color: Color(0xFF667EEA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: service.isAvailable
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Requesting ${service.name}...',
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: Icon(Icons.send, size: 18),
                        label: Text('Request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
