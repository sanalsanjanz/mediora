import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mediora/apis/patients/api_helpers.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/helper/call_navigation_helper.dart';
import 'package:mediora/models/ambulance_model.dart';
import 'package:mediora/widgets/empty_widget.dart';

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

    makeCall(phone: phoneNumber, context: context);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind status bar
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildEmergencyButton(),
          Expanded(
            child: FutureBuilder<List<AmbulanceModel>>(
              future: ApiHelpers.getAllAmbulance(
                lat: PatientController.patientModel?.lat ?? 0,
                lon: PatientController.patientModel?.lon ?? 0,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Color(0xFF3CB8B8),
                      rightDotColor: Color.fromARGB(255, 175, 235, 235),
                      size: 45,
                    ),
                  );
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildAmbulanceCard(snapshot.data![index]);
                    },
                  );
                } else {
                  return buildEmptyState(
                    message:
                        "We couldn\'t find any emergency services near you.",
                    onPressed: () {
                      setState(() {});
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 20),
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
          // bottomLeft: Radius.circular(16),
          // bottomRight: Radius.circular(16),
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
              Icon(
                FontAwesome.hand_holding_medical_solid,
                color: Colors.white,
                size: 32,
              ),
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

  Widget _buildAmbulanceCard(AmbulanceModel service) {
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.driverName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
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
                        service.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            ApiHelpers.calculateDistanceString(
                              service.latitude,
                              service.longitude,
                            ),
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
                Row(
                  children: [
                    Spacer(),
                    IconButton.outlined(
                      onPressed: () => _makePhoneCall(service.primaryContact),
                      icon: Icon(BoxIcons.bx_phone_outgoing),
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
