// To parse this JSON data, do
//
//     final clinicModel = clinicModelFromJson(jsonString);

import 'dart:convert';

import 'package:mediora/models/doctors_model.dart';
import 'package:mediora/models/working_hours_model.dart';

List<ClinicModel> clinicModelFromJson(String str) => List<ClinicModel>.from(
  json.decode(str).map((x) => ClinicModel.fromJson(x)),
);

String clinicModelToJson(List<ClinicModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicModel {
  String id;
  String name;
  String? image;
  dynamic coverImage;
  List<WorkingHourModel> workingHours;
  String locationName;
  String contact;
  String? about;
  double lat;
  double lon;
  List<String> services;
  String username;
  String password;
  DateTime createdAt;
  List<DoctorsModel> doctors;

  ClinicModel({
    required this.id,
    required this.name,
    required this.image,
    required this.coverImage,
    required this.workingHours,
    required this.locationName,
    required this.lat,
    required this.lon,
    required this.services,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.doctors,
    required this.contact,
    this.about,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) => ClinicModel(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    coverImage: json["cover_image"],
    workingHours: List<WorkingHourModel>.from(
      json["working_hours"].map((x) => WorkingHourModel.fromJson(x)),
    ),
    locationName: json["location_name"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    services: List<String>.from(json["services"].map((x) => x)),
    username: json["username"],
    password: json["password"],
    about: json["about"],
    contact: json["contact"] ?? "",
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : DateTime.now(),
    doctors: List<DoctorsModel>.from(
      json["doctors"].map((x) => DoctorsModel.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "cover_image": coverImage,
    "working_hours": List<dynamic>.from(workingHours.map((x) => x)),
    "location_name": locationName,
    "lat": lat,
    "lon": lon,
    "contact": contact,
    "services": List<dynamic>.from(services.map((x) => x)),
    "username": username,
    "about": about,
    "password": password,
    "created_at": createdAt.toIso8601String(),
    "doctors": List<dynamic>.from(doctors.map((x) => x.toJson())),
  };
}
/* 
class Doctor {
  String id;
  String name;
  dynamic image;
  int experience;
  int months;
  String about;
  String organizationId;
  String locationName;
  int lat;
  int lon;
  String username;
  String password;
  DateTime createdAt;
  String specialization;
  List<String> qualifications;
  List<String> languagesSpoken;
  String contactNumber;
  String email;
  int consultationFee;
  dynamic profileImageUrl;
  bool availableOnlineBooking;
  String address;
  List<String> availableDays;
  String gender;
  int maxPatientsPerSlot;
  dynamic clinicId;
  bool isActive;
  List<String> workingHours;
  String clinicName;

  Doctor({
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
    required this.months,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    experience: json["experience"],
    months: json["months"] ?? 0,
    about: json["about"],
    organizationId: json["organization_id"],
    locationName: json["location_name"],
    lat: json["lat"],
    lon: json["lon"],
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
    availableDays: List<String>.from(json["available_days"].map((x) => x)),
    gender: json["gender"],
    maxPatientsPerSlot: json["max_patients_per_slot"],
    clinicId: json["clinic_id"],
    isActive: json["is_active"],
    workingHours: List<String>.from(json["working_hours"].map((x) => x)),
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
 */