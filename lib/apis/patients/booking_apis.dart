import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mediora/apis/patients/api_links.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/models/booking_model.dart';

class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;
  const ApiResult({required this.success, required this.message, this.data});

  /// Handy helpers
  bool get isError => !success;
  bool get isOk => success;
}

class BookingApi {
  /*──────────── ADD ─────────────*/
  static Future<ApiResult<void>> addBooking(BookingModel booking) async {
    return _post<void>(
      action: 'add',
      payload: booking.toJson(),
      parser: (_) {}, //BookingModel.fromJson((body['data'] as List).first),
    );
  }

  /*──────────── UPDATE ─────────────*/
  static Future<ApiResult<void>> updateBooking(BookingModel booking) async {
    return _post<void>(
      action: 'update',
      payload: booking.toJson(),
      parser: (_) {},
    );
  }

  /*──────────── DELETE ─────────────*/
  static Future<ApiResult<void>> deleteBooking(String id) async {
    return _post<void>(action: 'delete', payload: {'id': id}, parser: (_) {});
  }

  /*───────────── GET ───────────────*/
  static Future<List<BookingDetailsModel>> getBookings({
    String? doctorId,
    String? clinicId,
    String? bookingId,
  }) async {
    final uri = Uri.parse(bookingUrl).replace(
      queryParameters: {
        if (bookingId != null) 'id': bookingId,
        if (doctorId != null) 'doctor': doctorId,
        if (clinicId != null) 'clinic': clinicId,
        if (PatientController.patientModel?.id != null)
          'patient': PatientController.patientModel?.id,
      },
    );

    final res = await http.get(uri);
    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? 'Unable to fetch bookings');
    }
    return bookingDetailsModelFromJson(jsonEncode(body));
  }

  /*────────── INTERNALS ────────────*/
  static Future<ApiResult<R>> _post<R>({
    required String action,
    required Map<String, dynamic> payload,
    required R Function(Map<String, dynamic> body) parser,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(bookingUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action, 'payload': payload}),
      );

      final body = jsonDecode(res.body);

      // HTTP failure → success = false
      if (res.statusCode >= 300) {
        return ApiResult<R>(
          success: false,
          message: body['error'] ?? 'Unexpected server error',
        );
      }

      // Happy path
      return ApiResult<R>(
        success: true,
        message: body['message'] ?? 'Success',
        data: parser(body),
      );
    } catch (e) {
      // Network / JSON error
      return ApiResult<R>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Map<String, dynamic> _decode(http.Response res) =>
      jsonDecode(res.body)[0] as Map<String, dynamic>;
}
