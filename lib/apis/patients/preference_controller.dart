import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mediora/models/patient_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientController {
  static PatientModel? patientModel;
  static getPatientDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? response = preferences.getString("patientData");
    if (response != null) {
      patientModel = patientModelFromJson(response);
    }
  }

  static Future<String?> getCurrentLocationName() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use placemarkFromCoordinates to get the address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        // You can format the location name as needed
        return '${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('Error getting location name: $e');
      return null;
    }
  }
}
