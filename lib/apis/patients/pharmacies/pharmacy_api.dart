import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mediora/apis/patients/api_links.dart';
import 'package:path/path.dart';

class ApiService {
  /* static Future<List<PharmacyModel>> getPharmacies(String query) async {
    final response = await http.get(Uri.parse("$getAllPharmacies?q=$query"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var listData = pharmacyModelFromJson(jsonEncode(data["data"]));
      return listData;
    } else {
      throw Exception('Failed to load pharmacies');
    }
  } */

  /* static Future<void> addPharmacy(
    Map<String, dynamic> pharmacy,
    File? image,
  ) async {
    try {
      var uri = Uri.parse(addPharmacies);
      var request = http.MultipartRequest('POST', uri);

      // Add JSON body as a field (example: inside a 'payload' key)
      request.fields['payload'] = jsonEncode(pharmacy);

      // Attach image file (if exists)
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: basename(image.path),
          ),
        );
      }

      // Send request
      var response = await request.send();

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('Pharmacy added successfully');
      } else {
        final resBody = await response.stream.bytesToString();
        log('Failed Response: ${response.statusCode}, $resBody');
        throw Exception('Failed to add pharmacy');
      }
    } catch (e) {
      log('Add Pharmacy Error: $e');
      throw Exception('Error adding pharmacy: $e');
    }
  } */

  static Future<void> updatePharmacy(
    Map<String, dynamic> pharmacy,
    File? image,
  ) async {
    try {
      final url = Uri.parse(updatePharmacies);
      var request = http.MultipartRequest('POST', url);

      // Add JSON payload as a form field
      request.fields['payload'] = jsonEncode(pharmacy);

      // Add image if present
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: basename(image.path),
          ),
        );
      }

      // Send request
      final response = await request.send();

      // Handle server response
      if (response.statusCode == 200) {
        log('Pharmacy updated successfully');
      } else {
        final resBody = await response.stream.bytesToString();
        log('Update Failed: ${response.statusCode}, $resBody');
        throw Exception('Failed to update pharmacy');
      }
    } catch (e) {
      log('Update Pharmacy Error: $e');
      throw Exception('Error updating pharmacy: $e');
    }
  }

  static Future<void> deletePharmacy(String id) async {
    try {
      final url = Uri.parse(deletePharmacies);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        log('Pharmacy deleted successfully');
      } else {
        log('Delete Failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete pharmacy');
      }
    } catch (e) {
      log('Delete Pharmacy Error: $e');
      throw Exception('Error deleting pharmacy: $e');
    }
  }
}
