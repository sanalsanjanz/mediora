import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/booking_details_model.dart';

class DoctorsLandingScreen extends StatefulWidget {
  const DoctorsLandingScreen({super.key, this.fcm});
  final String? fcm;
  @override
  State<DoctorsLandingScreen> createState() => _DoctorsLandingScreenState();
}

class _DoctorsLandingScreenState extends State<DoctorsLandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildProfileScreen(),
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
