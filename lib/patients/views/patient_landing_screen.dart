// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mediora/patients/views/patient_home_screen.dart';
import 'package:mediora/patients/views/view_all_doctors_screen.dart';
import 'package:mediora/patients/views/view_all_organizations.dart';
import 'package:mediora/patients/views/view_all_pharmacies.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PatientLandingScreen extends StatefulWidget {
  PatientLandingScreen({super.key, this.currentIndex = 0});
  int currentIndex;

  @override
  State<PatientLandingScreen> createState() => _PatientLandingScreenState();
}

class _PatientLandingScreenState extends State<PatientLandingScreen> {
  final List<Widget> _pages = [
    PatientHomeScreen(),
    DoctorsListingScreen(),
    ViewAllOrganizations(),
    ViewAllPharmacies(),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  List<TabItem> getTabItems(int selectedIndex) {
    return [
      TabItem(icon: selectedIndex == 0 ? EvaIcons.home : EvaIcons.home_outline),
      TabItem(
        icon: selectedIndex == 1
            ? FontAwesome.stethoscope_solid
            : FontAwesome.stethoscope_solid,
      ),
      TabItem(
        icon: selectedIndex == 2
            ? FontAwesome.hospital_solid
            : FontAwesome.hospital,
      ),
      TabItem(
        icon: selectedIndex == 3
            ? FontAwesome.user_nurse_solid
            : FontAwesome.user_nurse_solid,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_currentIndex == 0) {
            bool? exitApp = await QuickAlert.show(
              context: context,
              type: QuickAlertType.confirm,
              text: 'Do you want to exit?',
              confirmBtnText: 'Yes',
              cancelBtnText: 'No',
              confirmBtnColor: Colors.grey,
              onCancelBtnTap: () => Navigator.of(context).pop(false),
              onConfirmBtnTap: () => Navigator.of(context).pop(true),
            );

            if (exitApp == true) {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            }
          } else {
            setState(() {
              _currentIndex = 0;
            });
          }
        }
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomBarInspiredFancy(
          styleIconFooter: StyleIconFooter.dot,
          items: getTabItems(_currentIndex),
          backgroundColor: Colors.white,
          color: Colors.grey,
          colorSelected: const Color(0xFF45B7D1),
          indexSelected: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
