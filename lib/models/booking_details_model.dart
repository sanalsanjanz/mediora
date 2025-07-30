// To parse this JSON data, do
//
//     final bookingDetailsModel = bookingDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:mediora/models/doctors_model.dart';
import 'package:mediora/models/patient_model.dart';

List<BookingDetailsModel> bookingDetailsModelFromJson(String str) =>
    List<BookingDetailsModel>.from(
      json.decode(str).map((x) => BookingDetailsModel.fromJson(x)),
    );

String bookingDetailsModelToJson(List<BookingDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BookingDetailsModel {
  String id;
  String doctorId;
  dynamic clinicId;
  String patientId;
  String status;
  DateTime createdAt;
  String patientName;
  String patientGender;
  String patientAge;
  String patientContact;
  String reason;
  DateTime preferredDate;
  dynamic clinic;
  DoctorsModel doctor;
  PatientModel patient;

  BookingDetailsModel({
    required this.id,
    required this.doctorId,
    required this.clinicId,
    required this.patientId,
    required this.status,
    required this.createdAt,
    required this.patientName,
    required this.patientGender,
    required this.patientAge,
    required this.patientContact,
    required this.reason,
    required this.preferredDate,
    required this.clinic,
    required this.doctor,
    required this.patient,
  });

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) =>
      BookingDetailsModel(
        id: json["id"],
        doctorId: json["doctor_id"],
        clinicId: json["clinic_id"],
        patientId: json["patient_id"],
        status: json["status"],
        createdAt: json.containsKey("created_at")
            ? (DateTime.tryParse(json["created_at"] ?? "") ??
                      DateTime.now().toUtc())
                  .add(const Duration(hours: 5, minutes: 30))
            : DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)),

        patientName: json["patient_name"],
        patientGender: json["patient_gender"],
        patientAge: json["patient_age"] ?? "0",
        patientContact: json["patient_contact"],
        reason: json["reason"],
        preferredDate: DateTime.parse(json["preferred_date"]),
        clinic: json["clinic"],
        doctor: DoctorsModel.fromJson(json["doctor"]),
        patient: PatientModel.fromJson(json["patient"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "doctor_id": doctorId,
    "clinic_id": clinicId,
    "patient_id": patientId,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "patient_name": patientName,
    "patient_gender": patientGender,
    "patient_age": patientAge,
    "patient_contact": patientContact,
    "reason": reason,
    "preferred_date":
        "${preferredDate.year.toString().padLeft(4, '0')}-${preferredDate.month.toString().padLeft(2, '0')}-${preferredDate.day.toString().padLeft(2, '0')}",
    "clinic": clinic,
    "doctor": doctor.toJson(),
    "patient": patient.toJson(),
  };
}
