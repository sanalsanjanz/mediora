import 'dart:convert';

class BookingModel {
  final String? id; // null when creating a new booking
  final String? note; // null when creating a new booking
  final String fullName;
  final String gender;
  final int age;
  final String mobile;
  final String symptoms;
  final DateTime preferredDate;
  final String?
  doctorId; // at least one of doctorId / clinicId must be provided
  final String? clinicId;
  final String? patientId;
  final String status; // pending | confirmed | completed | cancelled

  BookingModel({
    this.id,
    this.note,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.mobile,
    required this.symptoms,
    required this.preferredDate,
    this.doctorId,
    this.clinicId,
    required this.patientId,
    this.status = 'pending',
  });

  /*────────────────── COPY ──────────────────*/
  BookingModel copyWith({
    String? id,
    String? fullName,
    String? gender,
    int? age,
    String? mobile,
    String? symptoms,
    DateTime? preferredDate,
    String? doctorId,
    String? clinicId,
    String? patientId,
    String? status,
  }) => BookingModel(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    gender: gender ?? this.gender,
    age: age ?? this.age,
    mobile: mobile ?? this.mobile,
    symptoms: symptoms ?? this.symptoms,
    preferredDate: preferredDate ?? this.preferredDate,
    doctorId: doctorId ?? this.doctorId,
    clinicId: clinicId ?? this.clinicId,
    patientId: patientId ?? this.patientId,
    status: status ?? this.status,
  );

  /*────────────────── JSON ──────────────────*/
  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'] as String?,
    fullName: json['full_name'] as String,
    gender: json['gender'] as String,
    age: (json['age'] as num).toInt(),
    mobile: json['mobile'] as String,
    symptoms: json['symptoms'] as String,
    preferredDate: DateTime.parse(json['preferred_date'] as String),
    doctorId: json['doctor_id'] as String?,
    clinicId: json['clinic_id'] as String?,
    patientId: json['patient_id'] as String?,
    status: json['status'] as String? ?? 'pending',
    note: json['note'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'patient_name': fullName,
    'patient_gender': gender,
    'patient_age': age.toString(),
    'patient_contact': mobile,
    'reason': symptoms,
    'preferred_date': preferredDate.toIso8601String(),
    'doctor_id': doctorId,
    'clinic_id': clinicId,
    'patient_id': patientId,
    'status': status,
    'note': note,
  };
}

/*──────── OPTIONAL BULK HELPERS ────────*/
List<BookingModel> bookingListFromJson(String source) =>
    (json.decode(source) as List)
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();

String bookingListToJson(List<BookingModel> list) =>
    json.encode(list.map((e) => e.toJson()).toList());
