import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mediora/apis/patients/api_links.dart';

class PrescriptionAPI {
  static String baseUrlPath = '${baseUrl}prescription'; // 👈 No trailing slash
  static String getUrlPath = '${baseUrl}prescription?';

  /// ➕ Add a prescription
  static Future<Map<String, dynamic>> addPrescription(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(baseUrlPath);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      log('POST response: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _error(e);
    }
  }

  /// 🔄 Update a prescription
  static Future<Map<String, dynamic>> updatePrescription(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(baseUrlPath);
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      log('PUT response: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _error(e);
    }
  }

  /// 📄 Get prescriptions filtered by doctorId, patientId, bookingId, clinicId
  static Future<Map<String, dynamic>> getPrescriptions({
    String? doctorId,
    String? patientId,
    String? bookingId,
    String? clinicId,
  }) async {
    final queryParams = {
      if (doctorId != null) 'doctor_id': doctorId,
      if (patientId != null) 'patient_id': patientId,
      if (bookingId != null) 'booking_id': bookingId,
      if (clinicId != null) 'clinic_id': clinicId,
    };

    final uri = Uri.parse(getUrlPath).replace(queryParameters: queryParams);
    try {
      final response = await http.get(uri);
      log('GET response: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _error(e);
    }
  }

  /// ✅ Success Response Handling
  static Map<String, dynamic> _handleResponse(http.Response res) {
    try {
      final json = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'data': json};
      } else {
        return {
          'success': false,
          'error': json['error'] ?? 'Unknown error',
          'status': res.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Invalid JSON response'};
    }
  }

  /// ❌ Error Fallback
  static Map<String, dynamic> _error(Object e) {
    return {'success': false, 'error': e.toString()};
  }
}
