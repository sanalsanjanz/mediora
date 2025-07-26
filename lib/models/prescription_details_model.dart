// To parse this JSON data, do
//
//     final prescriptionDetailsModel = prescriptionDetailsModelFromJson(jsonString);

import 'dart:convert';

PrescriptionDetailsModel prescriptionDetailsModelFromJson(String str) =>
    PrescriptionDetailsModel.fromJson(json.decode(str));

String prescriptionDetailsModelToJson(PrescriptionDetailsModel data) =>
    json.encode(data.toJson());

class PrescriptionDetailsModel {
  List<Prescription> prescriptions;

  PrescriptionDetailsModel({required this.prescriptions});

  factory PrescriptionDetailsModel.fromJson(Map<String, dynamic> json) =>
      PrescriptionDetailsModel(
        prescriptions: List<Prescription>.from(
          json["prescriptions"].map((x) => Prescription.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "prescriptions": List<dynamic>.from(prescriptions.map((x) => x.toJson())),
  };
}

class Prescription {
  String id;
  String doctorId;
  String patientId;
  String bookingId;
  DateTime date;
  String notes;
  String diagnosis;
  String signatureBase64;
  dynamic pdfUrl;
  DateTime createdAt;
  int days;
  DateTime updatedAt;
  List<String> medicines;

  Prescription({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.bookingId,
    required this.date,
    required this.notes,
    required this.diagnosis,
    required this.signatureBase64,
    required this.pdfUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
    required this.medicines,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    id: json["id"],
    doctorId: json["doctor_id"],
    patientId: json["patient_id"],
    bookingId: json["booking_id"],
    date: DateTime.parse(json["date"]),
    notes: json["notes"],
    diagnosis: json["diagnosis"],
    signatureBase64: json["signature_base64"],
    pdfUrl: json["pdf_url"],
    days: json["days"] ?? 0,
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    medicines: List<String>.from(json["medicines"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "days": days,
    "doctor_id": doctorId,
    "patient_id": patientId,
    "booking_id": bookingId,
    "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "notes": notes,
    "diagnosis": diagnosis,
    "signature_base64": signatureBase64,
    "pdf_url": pdfUrl,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "medicines": List<dynamic>.from(medicines.map((x) => x)),
  };
}
