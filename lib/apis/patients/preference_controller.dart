import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mediora/helper/check_opened.dart';
import 'package:mediora/models/patient_model.dart';
import 'package:mediora/models/working_hours_model.dart';
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

  static Future<void> clearPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    patientModel = null;
    return;
  }

  static checkShopStatus(List<WorkingHourModel> hours) {
    final status = getShopStatus(hours);
    switch (status) {
      case ShopStatus.open:
        print("✅ Shop is currently **OPEN**");
        // break;
        return "Open";

      case ShopStatus.closesSoon:
        print("⚠️ Shop is **CLOSING SOON**");
        // break;
        return "Close Soon";
      case ShopStatus.closed:
        print("❌ Shop is **CLOSED**");
        // break;
        return "Closed";
      case ShopStatus.opensSoon:
        print("🕑 Shop is **OPENING SOON**");
        // break;
        return "Opening Soon";
    }
  }
}
