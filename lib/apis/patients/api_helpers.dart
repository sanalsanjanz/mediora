import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mediora/apis/patients/api_links.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/pharmacy_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelpers {
  static Future<List<PharmacyModel>> getALlPharmacies({
    String query = "",
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.get(Uri.parse(getAllPharmacies));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<PharmacyModel> cities = pharmacyModelFromJson(
          jsonEncode(data["data"]),
        );
        return cities;
      } else if (response.statusCode == 404) {
        throw Exception('Not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error while loading cities');
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cities: $e');
    }
  }

  static Future<(bool, String)> loginPatirent({
    required String userName,
    required String password,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(patientUrl),
      ); // ✅ Make sure manageDoctors has trailing slash

      request.fields['payload'] = jsonEncode({
        'username': userName,
        "password": password,
      });
      request.fields['action'] = 'login';
      // request.headers['Accept'] = 'application/json';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        SharedPreferences pre = await SharedPreferences.getInstance();
        var data = jsonDecode(responseBody);
        await pre.setString("patientData", jsonEncode(data["data"]));
        await pre.setBool("logged", true);
        PatientController.getPatientDetails();
        return (true, "Successfully logged in");
      } else {
        var data = jsonDecode(responseBody);
        log('failed: ${response.statusCode}, $responseBody');
        return (false, data["error"].toString());
      }
    } catch (e) {
      log('Error doctor: $e');
      throw Exception('$e');
    }
  }

  static Future<(bool, String)> signupPatient({
    required Map<String, dynamic> details,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(patientUrl));

      request.fields['payload'] = jsonEncode(details);
      request.fields['action'] = 'add';
      request.headers['Accept'] = 'application/json';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      log('Response body: $responseBody');

      if (response.statusCode == 200) {
        // final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        SharedPreferences pre = await SharedPreferences.getInstance();
        var data = jsonDecode(responseBody);
        await pre.setString("patientData", jsonEncode(data["data"]));
        await pre.setBool("logged", true);
        PatientController.getPatientDetails();
        return (true, "Success");
      } else {
        var data = jsonDecode(responseBody);
        log('failed: ${response.statusCode}, $responseBody');
        return (false, data["error"].toString());
      }
    } catch (e) {
      print('Error signing up patient: $e');
      throw Exception('Error signing up patient: $e');
    }
  }
}
