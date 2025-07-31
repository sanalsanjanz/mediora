import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/organization/organization_api_links.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:mediora/widgets/get_fcm_token.dart';
import 'package:mediora/widgets/show_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizationHelper {
  static Future<(bool, String)> loginPharmacy({
    required String userName,
    required String password,
    required String fcm,
    required bool isDoctor,
    required BuildContext context,
  }) async {
    MedioraLoadingScreen.show(context, message: 'Loading data');
    String url = pharmacyLogin;
    final fcmnew = await PushNotificationService.getFcmToken();
    if (fcmnew == null) {
      return (false, "Device Id Failed");
    } else {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("$url/login"),
        ); // ✅ Make sure manageDoctors has trailing slash

        request.fields['username'] = userName;
        request.fields['password'] = password;
        request.fields['fcm_token'] = fcmnew ?? "";

        /*    jsonEncode({
        'username': userName,
        "password": password,
        "fcm_token": fcmnew,
      }); */
        // request.fields['action'] = 'login';
        // request.headers['Accept'] = 'application/json';

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          SharedPreferences pre = await SharedPreferences.getInstance();
          var data = jsonDecode(responseBody);
          await pre.setString("pharmacyData", jsonEncode(data));
          await pre.setBool("logged", true);
          await PatientController.getPharmacyDetails();
          MedioraLoadingScreen.hide();
          return (true, "Successfully logged in");
        } else {
          MedioraLoadingScreen.hide();
          var data = jsonDecode(responseBody);
          log('failed: ${response.statusCode}, $responseBody');
          return (false, data["error"].toString());
        }
      } catch (e) {
        MedioraLoadingScreen.hide();
        log('Error doctor: $e');
        throw Exception('$e');
      }
    }
  }
}
