import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mediora/apis/patients/api_links.dart';
import 'package:mediora/models/order_history_model.dart';

class OrderService {
  /* static const String orderBaseUrl =
      'http://localhost:3000/api/orders' ;*/ // Change port if needed

  static Future<Map<String, dynamic>?> addOrder(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse(orderBaseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': 'add', 'payload': payload}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Add failed: ${response.body}');
      return null;
    }
  }

  static Future<bool> updateOrder(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(orderBaseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': 'update', 'payload': payload}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteOrder(String id) async {
    final response = await http.post(
      Uri.parse(orderBaseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'delete',
        'payload': {'id': id},
      }),
    );

    return response.statusCode == 200;
  }

  static Future<List<OrderHistoryModel>> getOrders({
    String? patientId,
    String? pharmacyId,
    String? doctorId,
    String? id,
  }) async {
    final params = <String, String>{};
    if (patientId != null) params['patient'] = patientId;
    if (pharmacyId != null) params['pharmacy'] = pharmacyId;
    if (doctorId != null) params['doctor'] = doctorId;
    if (id != null) params['id'] = id;

    final uri = Uri.parse(orderBaseUrl).replace(queryParameters: params);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return orderHistoryModelFromJson(response.body);
      }
    }

    print('Fetch failed: ${response.body}');
    return [];
  }
}
