import 'dart:convert';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mediora/apis/get_fcm_token.dart';
import 'package:mediora/apis/patients/api_links.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/ambulance_model.dart';
import 'package:mediora/models/clinic_model.dart';
import 'package:mediora/models/doctors_model.dart';
import 'package:mediora/models/pharmacy_model.dart';
import 'package:mediora/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelpers {
  // static Future<String?> getDistance({
  //   required double startLat,
  //   required double startLng,
  //   required double endLat,
  //   required double endLng,
  //   required String apiKey,
  // }) async {
  //   final url =
  //       'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$startLat,$startLng&destinations=$endLat,$endLng&key=$apiKey';

  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final distance = data['rows'][0]['elements'][0]['distance']['text'];
  //     return distance; // e.g., "5.3 km"
  //   } else {
  //     print('Error: ${response.body}');
  //     return null;
  //   }
  // }

  static String calculateDistanceString(
    double endLatitude,
    double endLongitude,
  ) {
    final patient = PatientController.patientModel;

    if (patient == null) {
      return 'Location unknown';
    }

    final startLat = patient.lat;
    final startLon = patient.lon;

    final distanceMeters = Geolocator.distanceBetween(
      startLat,
      startLon,
      endLatitude,
      endLongitude,
    );
    print('📍 Start Latitude: $startLat');
    print('📍 Start Longitude: $startLon');
    print('🏁 End Latitude: $endLatitude');
    print('🏁 End Longitude: $endLongitude');

    if (distanceMeters <= 100) {
      return 'Near';
    } else if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    } else {
      final distanceKm = distanceMeters / 1000;
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  static String apiKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjAxODhlMGE5MWJlYjQzMzNhZjUzODdhY2ZiYmNmZDJlIiwiaCI6Im11cm11cjY0In0=";
  Future<String> getRoadDistanceString(double endLat, double endLon) async {
    final patient = PatientController.patientModel;

    if (patient == null) {
      return 'Location unknown';
    }

    final startLat = patient.lat;
    final startLon = patient.lon;

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?'
      'api_key=$apiKey&start=$startLon,$startLat&end=$endLon,$endLat',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final distanceMeters =
            data['features'][0]['properties']['segments'][0]['distance'];

        if (distanceMeters < 1000) {
          return '${distanceMeters.toStringAsFixed(0)} m';
        } else {
          final distanceKm = distanceMeters / 1000;
          return '${distanceKm.toStringAsFixed(1)} km';
        }
      } else {
        print('❌ API error: ${response.statusCode} ${response.body}');
        return 'Distance unavailable';
      }
    } catch (e) {
      print('❌ Exception: $e');
      return 'Distance error';
    }
  }

  static Future<List<PharmacyModel>> getALlPharmacies({
    String query = "",
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(getAllPharmacies) /* ?lat=$lat&lon=$lon */,
      );
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

  static Future<List<DoctorsModel>> getAllDoctors({
    String query = "",
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$getAllDoctorsUrl?lat=$lat&lon=$lon"),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<DoctorsModel> cities = doctorsModelFromJson(
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

  static Future<List<ClinicModel>> getAllClinics({
    String query = "",
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$getAllClinicsUrl?lat=$lat&lon=$lon"),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<ClinicModel> cities = clinicModelFromJson(
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

  static Future<(bool, String)> loginPatient({
    required String userName,
    required String password,
  }) async {
    final fcmToken = await PushNotificationService.getFcmToken();

    if (fcmToken == null) {
      return (false, "FCM Token Error");
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(patientUrl));

      request.fields['payload'] = jsonEncode({
        'username': userName, // ✅ match backend param (not usernameOrMobile)
        "password": password,
        "fcmToken": fcmToken, // ✅ backend expects camelCase here
      });
      request.fields['action'] = 'login';

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
        log('Login failed: ${response.statusCode}, $responseBody');
        return (false, data["error"].toString());
      }
    } catch (e) {
      log('Login error: $e');
      return (false, "Login failed: $e");
    }
  }

  static Future<(bool, String)> signupPatient({
    required Map<String, dynamic> details,
  }) async {
    try {
      final fcmToken = await PushNotificationService.getFcmToken();
      if (fcmToken == null) {
        return (false, "FCM Token Error");
      }

      // ✅ backend expects snake_case for signup: "fcm_token"
      details['fcm_token'] = fcmToken;

      var request = http.MultipartRequest('POST', Uri.parse(patientUrl));
      request.fields['payload'] = jsonEncode(details);
      request.fields['action'] = 'add';
      request.headers['Accept'] = 'application/json';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      log('Signup response: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        SharedPreferences pre = await SharedPreferences.getInstance();
        await pre.setString("patientData", jsonEncode(data["data"]));
        await pre.setBool("logged", true);
        PatientController.getPatientDetails();
        return (true, "Success");
      } else {
        final data = jsonDecode(responseBody);
        log('Signup failed: ${response.statusCode}, $responseBody');
        return (false, data["error"].toString());
      }
    } catch (e) {
      print('Error signing up patient: $e');
      return (false, "Signup Error: $e");
    }
  }

  static Future<List<AmbulanceModel>> getAllAmbulance({
    String query = "",
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$ambulance?lat=$lat&lon=$lon"),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<AmbulanceModel> cities = ambulanceModelFromJson(
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

  static Future<(bool, String)> updateLocation({
    required Map<String, dynamic> details,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(patientUrl));

      request.fields['payload'] = jsonEncode(details);
      request.fields['action'] = 'update';
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
