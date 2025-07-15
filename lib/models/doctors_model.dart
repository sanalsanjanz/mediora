// To parse this JSON data, do
//
//     final doctorsModel = doctorsModelFromJson(jsonString);

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:mediora/models/working_hours_model.dart';

List<DoctorsModel> doctorsModelFromJson(String str) => List<DoctorsModel>.from(
  json.decode(str).map((x) => DoctorsModel.fromJson(x)),
);

String doctorsModelToJson(List<DoctorsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DoctorsModel {
  String id;
  String name;
  dynamic image;
  String experience;
  String about;
  String? organizationId;
  String locationName;
  double lat;
  double lon;
  String username;
  String password;
  DateTime createdAt;
  String specialization;
  List<String> qualifications;
  List<String> languagesSpoken;
  String contactNumber;
  String email;
  int consultationFee;
  String? profileImageUrl;
  bool availableOnlineBooking;
  String address;
  List<String> availableDays;
  String gender;
  int maxPatientsPerSlot;
  dynamic clinicId;
  bool isActive;
  List<WorkingHourModel> workingHours;
  String clinicName;

  DoctorsModel({
    required this.id,
    required this.name,
    required this.image,
    required this.experience,
    required this.about,
    required this.organizationId,
    required this.locationName,
    required this.lat,
    required this.lon,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.specialization,
    required this.qualifications,
    required this.languagesSpoken,
    required this.contactNumber,
    required this.email,
    required this.consultationFee,
    required this.profileImageUrl,
    required this.availableOnlineBooking,
    required this.address,
    required this.availableDays,
    required this.gender,
    required this.maxPatientsPerSlot,
    required this.clinicId,
    required this.isActive,
    required this.workingHours,
    required this.clinicName,
  });

  factory DoctorsModel.fromJson(Map<String, dynamic> json) => DoctorsModel(
    id: json["id"],
    name: "Dr. " + json["name"],
    image: json["image"],
    experience: json["experience"],
    about: json["about"],
    organizationId: json["organization_id"],
    locationName: json["location_name"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    username: json["username"],
    password: json["password"],
    createdAt: DateTime.parse(json["created_at"]),
    specialization: json["specialization"],
    qualifications: List<String>.from(json["qualifications"].map((x) => x)),
    languagesSpoken: List<String>.from(json["languages_spoken"].map((x) => x)),
    contactNumber: json["contact_number"],
    email: json["email"],
    consultationFee: json["consultation_fee"],
    profileImageUrl: json["profile_image_url"],
    availableOnlineBooking: json["available_online_booking"],
    address: json["address"],
    availableDays:
        [] /* List<String>.from(json["available_days"].map((x) => x)) */,
    gender: json["gender"],
    maxPatientsPerSlot: json["max_patients_per_slot"],
    clinicId: json["clinic_id"],
    isActive: json["is_active"],
    workingHours: List<WorkingHourModel>.from(
      json["working_hours"].map((x) => WorkingHourModel.fromJson(x)),
    ),
    clinicName: json["clinic_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "experience": experience,
    "about": about,
    "organization_id": organizationId,
    "location_name": locationName,
    "lat": lat,
    "lon": lon,
    "username": username,
    "password": password,
    "created_at": createdAt.toIso8601String(),
    "specialization": specialization,
    "qualifications": List<dynamic>.from(qualifications.map((x) => x)),
    "languages_spoken": List<dynamic>.from(languagesSpoken.map((x) => x)),
    "contact_number": contactNumber,
    "email": email,
    "consultation_fee": consultationFee,
    "profile_image_url": profileImageUrl,
    "available_online_booking": availableOnlineBooking,
    "address": address,
    "available_days": List<dynamic>.from(availableDays.map((x) => x)),
    "gender": gender,
    "max_patients_per_slot": maxPatientsPerSlot,
    "clinic_id": clinicId,
    "is_active": isActive,
    "working_hours": List<dynamic>.from(workingHours.map((x) => x)),
    "clinic_name": clinicName,
  };
}
