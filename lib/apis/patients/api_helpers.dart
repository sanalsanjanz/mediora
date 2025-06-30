import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mediora/apis/patients/api_links.dart';
import 'package:mediora/models/pharmacy_model.dart';

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
}
