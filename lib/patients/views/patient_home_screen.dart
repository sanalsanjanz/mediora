import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mediora/patients/views/ambulance_services.dart';
import 'package:mediora/patients/views/doctor_booking_screen.dart';
import 'package:mediora/patients/views/my_bookings.dart';
import 'package:mediora/patients/views/organization_screen.dart';
import 'package:mediora/patients/views/pharmacy_home_screen.dart';
import 'package:mediora/patients/views/view_all_doctors_screen.dart';
import 'package:mediora/patients/views/view_all_organizations.dart';
import 'package:mediora/patients/views/view_all_pharmacies.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 320,
            automaticallyImplyLeading: false,
            // expandedHeight: 300.0,
            floating: false,

            // pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(context)),
            toolbarHeight: 0,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSection(
                  type: "doctor",
                  count: 2,
                  title: "Top Doctors Near You",
                  icon: FontAwesome.stethoscope_solid,
                  items: _getDoctors(),
                  onViewMore: () => _navigateToViewMore('doctors', context),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  type: "hospital",
                  count: 1,
                  title: "Nearest Clinics/Hospitals",
                  icon: FontAwesome.hospital_solid,
                  items: _getClinics(),
                  onViewMore: () => _navigateToViewMore('clinics', context),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  type: "pharmacy",
                  count: 2,
                  title: "Nearest Pharmacies",
                  icon: FontAwesome.suitcase_medical_solid,
                  items: _getPharmacies(),
                  onViewMore: () => _navigateToViewMore('pharmacies', context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      clipper: DirectionalWaveClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(100, 10),
            bottomRight: Radius.elliptical(100, 10),
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E86AB), // Medical blue
              Color(0xFF4ECDC4), // Calm teal
              Color(0xFF45B7D1), // Light blue
            ],
            // begin: Alignment.topLeft,
            // end: Alignment.bottomRight,
            // stops: [0.0, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E86AB).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            // User Profile Section
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=120&h=120&fit=crop&crop=face',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      // const SizedBox(height: 2),
                      const Text(
                        'Sanal Pk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      // const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Downtown Medical District',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Medical Banner - Health Checkup Reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Annual Health Checkup Due',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Book your appointment today',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Offer Wall - New Doctors & Pharmacy Deals
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MyBookingsPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.medical_services_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'My Bookings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          /*    const Text(
                            '1 ',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ), */
                        ],
                      ),
                    ),
                  ),
                ),

                // const SizedBox(width: 12),

                // Expanded(
                //   child: Container(
                //     padding: const EdgeInsets.all(14),
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.12),
                //       borderRadius: BorderRadius.circular(14),
                //       border: Border.all(color: Colors.white.withOpacity(0.2)),
                //     ),
                //     child: Column(
                //       children: [
                //         Container(
                //           padding: const EdgeInsets.all(8),
                //           decoration: BoxDecoration(
                //             color: const Color(0xFF45B7D1).withOpacity(0.8),
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: const Icon(
                //             Icons.local_pharmacy_outlined,
                //             color: Colors.white,
                //             size: 16,
                //           ),
                //         ),
                //         const SizedBox(height: 8),
                //         const Text(
                //           'Pharmacy Deals',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 13,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //         // const Text(
                //         //   'Up to 30% off',
                //         //   style: TextStyle(color: Colors.white70, fontSize: 10),
                //         // ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NearestAmbulanceScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E86AB).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.emoji_objects_sharp,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // const Text(
                          //   '3 near you',
                          //   style: TextStyle(color: Colors.white70, fontSize: 10),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Emergency Contact Banner
            // Container(
            //   padding: const EdgeInsets.all(14),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFFF6B6B).withOpacity(0.15),
            //     borderRadius: BorderRadius.circular(14),
            //     border: Border.all(
            //       color: const Color(0xFFFF6B6B).withOpacity(0.3),
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.all(8),
            //         decoration: BoxDecoration(
            //           color: const Color(0xFFFF6B6B),
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         child: const Icon(
            //           Icons.emergency,
            //           color: Colors.white,
            //           size: 16,
            //         ),
            //       ),
            //       const SizedBox(width: 12),
            //       const Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               'Emergency Services',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.w600,
            //               ),
            //             ),
            //             Text(
            //               '24/7 medical assistance available',
            //               style: TextStyle(color: Colors.white70, fontSize: 11),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Container(
            //         padding: const EdgeInsets.all(8),
            //         decoration: BoxDecoration(
            //           color: Colors.white.withOpacity(0.2),
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         child: const Icon(Icons.phone, color: Colors.white, size: 16),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String type,
    required int count,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required VoidCallback onViewMore,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewMore,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View More',
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF667EEA),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          // height: 240,
          child: GridView.builder(
            padding: EdgeInsets.all(12),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (type == "doctor") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DoctorBookingScreen(),
                      ),
                    );
                  } else if (type == "hospital") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrganizationScreen(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PharmacyHomeScreen(),
                      ),
                    );
                  }
                },
                child: _buildCard(items[index]),
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              mainAxisExtent: count == 2 ? 250 : 220,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      // width: 280,
      // margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(item['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['distance'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    if (item['rating'] != null) ...[
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFEAB308),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['rating'].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['openTime']} - ${item['closeTime']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                if (item['specialization'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['specialization'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getClinics() {
    return [
      {
        'name': 'Seattle Medical Center',
        'image':
            'https://images.unsplash.com/photo-1551601651-2a8555f1a136?w=300&h=200&fit=crop',
        'distance': '0.5 km',
        'openTime': '08:00 AM',
        'closeTime': '10:00 PM',
        'rating': 4.8,
      },
      {
        'name': 'Downtown Health Clinic',
        'image':
            'https://images.unsplash.com/photo-1519494026892-80bbd2d6ede8?w=300&h=200&fit=crop',
        'distance': '1.2 km',
        'openTime': '09:00 AM',
        'closeTime': '09:00 PM',
        'rating': 4.6,
      },
      {
        'name': 'City General Hospital',
        'image':
            'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=300&h=200&fit=crop',
        'distance': '2.1 km',
        'openTime': '24/7',
        'closeTime': 'Open',
        'rating': 4.9,
      },
      {
        'name': 'Wellness Medical Center',
        'image':
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=200&fit=crop',
        'distance': '2.8 km',
        'openTime': '07:00 AM',
        'closeTime': '11:00 PM',
        'rating': 4.7,
      },
      {
        'name': 'Harbor View Clinic',
        'image':
            'https://images.unsplash.com/photo-1582560475093-ba66accbc424?w=300&h=200&fit=crop',
        'distance': '3.2 km',
        'openTime': '08:30 AM',
        'closeTime': '08:30 PM',
        'rating': 4.5,
      },
      {
        'name': 'Pacific Health Institute',
        'image':
            'https://images.unsplash.com/photo-1504813184591-01572f98c85f?w=300&h=200&fit=crop',
        'distance': '3.7 km',
        'openTime': '06:00 AM',
        'closeTime': '10:00 PM',
        'rating': 4.8,
      },
    ];
  }

  List<Map<String, dynamic>> _getDoctors() {
    return [
      {
        'name': 'Dr. Emily Rodriguez',
        'image':
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=200&fit=crop&crop=face',
        'distance': '0.8 km',
        'openTime': '09:00 AM',
        'closeTime': '05:00 PM',
        'rating': 4.9,
        'specialization': 'Cardiologist',
      },
      {
        'name': 'Dr. Michael Chen',
        'image':
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&h=200&fit=crop&crop=face',
        'distance': '1.1 km',
        'openTime': '10:00 AM',
        'closeTime': '06:00 PM',
        'rating': 4.8,
        'specialization': 'Neurologist',
      },
      {
        'name': 'Dr. Sarah Williams',
        'image':
            'https://images.unsplash.com/photo-1594824242347-d3ca5b0dd295?w=300&h=200&fit=crop&crop=face',
        'distance': '1.5 km',
        'openTime': '08:00 AM',
        'closeTime': '04:00 PM',
        'rating': 4.7,
        'specialization': 'Pediatrician',
      },
      {
        'name': 'Dr. James Thompson',
        'image':
            'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&h=200&fit=crop&crop=face',
        'distance': '2.0 km',
        'openTime': '11:00 AM',
        'closeTime': '07:00 PM',
        'rating': 4.6,
        'specialization': 'Orthopedic',
      },
      {
        'name': 'Dr. Lisa Anderson',
        'image':
            'https://images.unsplash.com/photo-1551601651-2a8555f1a136?w=300&h=200&fit=crop&crop=face',
        'distance': '2.3 km',
        'openTime': '09:30 AM',
        'closeTime': '05:30 PM',
        'rating': 4.8,
        'specialization': 'Dermatologist',
      },
      {
        'name': 'Dr. Robert Garcia',
        'image':
            'https://images.unsplash.com/photo-1612531386530-97286d97c2d2?w=300&h=200&fit=crop&crop=face',
        'distance': '2.7 km',
        'openTime': '08:30 AM',
        'closeTime': '04:30 PM',
        'rating': 4.9,
        'specialization': 'Psychiatrist',
      },
    ];
  }

  List<Map<String, dynamic>> _getPharmacies() {
    return [
      {
        'name': 'HealthPlus Pharmacy',
        'image':
            'https://images.unsplash.com/photo-1550572017-edd951aa8ca3?w=300&h=200&fit=crop',
        'distance': '0.3 km',
        'openTime': '08:00 AM',
        'closeTime': '10:00 PM',
        'rating': 4.7,
      },
      {
        'name': 'MediCare Drug Store',
        'image':
            'https://images.unsplash.com/photo-1576671081837-49000212a370?w=300&h=200&fit=crop',
        'distance': '0.7 km',
        'openTime': '09:00 AM',
        'closeTime': '09:00 PM',
        'rating': 4.5,
      },
      {
        'name': 'Quick Pharmacy',
        'image':
            'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=300&h=200&fit=crop',
        'distance': '1.2 km',
        'openTime': '24/7',
        'closeTime': 'Open',
        'rating': 4.6,
      },
      {
        'name': 'Downtown Chemist',
        'image':
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=200&fit=crop',
        'distance': '1.8 km',
        'openTime': '07:00 AM',
        'closeTime': '11:00 PM',
        'rating': 4.8,
      },
      {
        'name': 'City Medical Supplies',
        'image':
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=200&fit=crop',
        'distance': '2.1 km',
        'openTime': '08:30 AM',
        'closeTime': '08:30 PM',
        'rating': 4.4,
      },
      {
        'name': 'Northwest Pharmacy',
        'image':
            'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=300&h=200&fit=crop',
        'distance': '2.5 km',
        'openTime': '09:00 AM',
        'closeTime': '10:00 PM',
        'rating': 4.7,
      },
    ];
  }

  void _navigateToViewMore(String type, BuildContext context) {
    // Navigate to respective view more pages
    print('Navigate to view more $type');
    if (type.toLowerCase() == "doctors") {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => DoctorsListingScreen()));
    } else if (type.toLowerCase() == "clinics") {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ViewAllOrganizations()));
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ViewAllPharmacies()));
    }
  }
}
