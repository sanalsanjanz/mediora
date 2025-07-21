import 'package:custom_clippers/custom_clippers.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mediora/apis/patients/api_helpers.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/patients/games/breathin_game.dart';
import 'package:mediora/patients/views/ambulance_services.dart';
import 'package:mediora/patients/views/breath_in_banner.dart';
import 'package:mediora/patients/views/clinic_list.dart';
import 'package:mediora/patients/views/doctors_list.dart';
import 'package:mediora/patients/views/my_bookings.dart';
import 'package:mediora/patients/views/pharmacy_list.dart';
import 'package:mediora/splash_screen.dart';
import 'package:mediora/widgets/custom_indicator.dart';
import 'package:mediora/widgets/location_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        setState(() {});
      }, // Your refresh logic
      builder: (context, child, controller) {
        // Place your custom indicator here.
        // Need inspiration? Look at the example app!
        return MyIndicator(controller: controller, child: child);
      },
      child: Scaffold(
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
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(context),
              ),
              toolbarHeight: 0,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  doctorsGrid(),
                  const SizedBox(height: 24),
                  BreathingExerciseBanner(),
                  clinicGrid(),
                  const SizedBox(height: 24),
                  pharmacyGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      clipper: DirectionalWaveClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 20),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PatientController.patientModel?.name.toString() ??
                            "Unkown User",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          LocationResult location = await Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => LocationPicker(),
                                ),
                              );

                          (bool, String) re = await ApiHelpers.updateLocation(
                            details: {
                              "id": PatientController.patientModel?.id ?? "",
                              "lat": location.latitude,
                              "lon": location.longitude,
                              "location": location.locationName.trim(),
                            },
                          );
                          if (re.$1) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MedioraSplashScreen(),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              PatientController.patientModel?.location
                                      .toString() ??
                                  "Add Location",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      text: 'Are you sure you want to logout?',
                      confirmBtnText: 'Logout',
                      cancelBtnText: 'Cancel',
                      confirmBtnColor: Colors.grey,
                      onCancelBtnTap: () => Navigator.of(context).pop(false),
                      onConfirmBtnTap: () async {
                        Navigator.of(context).pop(true);
                        await PatientController.clearPreferences();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedioraSplashScreen(),
                          ),
                          (_) => false,
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      FontAwesome.power_off_solid,
                      color: Colors.white,
                      size: 18,
                    ),
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
}
