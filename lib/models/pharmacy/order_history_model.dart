// To parse this JSON data, do
//
//     final orderHistoryModel = orderHistoryModelFromJson(jsonString);

import 'dart:convert';

import 'package:mediora/models/doctors_model.dart';
import 'package:mediora/models/patient_model.dart';

List<OrderHistoryModel> orderHistoryModelFromJson(String str) =>
    List<OrderHistoryModel>.from(
      json.decode(str).map((x) => OrderHistoryModel.fromJson(x)),
    );

String orderHistoryModelToJson(List<OrderHistoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderHistoryModel {
  String id;
  String prescriptionId;
  String doctorId;
  String patientId;
  String pharmacyId;
  List<String> medicines;
  DateTime orderDate;
  String status;
  dynamic message;
  DoctorsModel doctor;
  PatientModel patient;

  OrderHistoryModel({
    required this.id,
    required this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    required this.pharmacyId,
    required this.medicines,
    required this.orderDate,
    required this.status,
    required this.message,
    required this.doctor,
    required this.patient,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) =>
      OrderHistoryModel(
        id: json["id"],
        prescriptionId: json["prescription_id"],
        doctorId: json["doctor_id"],
        patientId: json["patient_id"],
        pharmacyId: json["pharmacy_id"],
        medicines: List<String>.from(json["medicines"].map((x) => x)),
        orderDate: DateTime.parse(json["order_date"]),
        status: json["status"],
        message: json["message"],
        doctor: DoctorsModel.fromJson(json["doctor"]),
        patient: PatientModel.fromJson(json["patient"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "prescription_id": prescriptionId,
    "doctor_id": doctorId,
    "patient_id": patientId,
    "pharmacy_id": pharmacyId,
    "medicines": List<dynamic>.from(medicines.map((x) => x)),
    "order_date": orderDate.toIso8601String(),
    "status": status,
    "message": message,
    "doctor": doctor.toJson(),
    "patient": patient.toJson(),
  };
}
