// To parse this JSON data, do
//
//     final pharmacyModel = pharmacyModelFromJson(jsonString);

import 'dart:convert';

List<PharmacyModel> pharmacyModelFromJson(String str) =>
    List<PharmacyModel>.from(
      json.decode(str).map((x) => PharmacyModel.fromJson(x)),
    );

String pharmacyModelToJson(List<PharmacyModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PharmacyModel {
  String id;
  String pharmacistName;
  int experience;
  String about;
  String image;
  String locationName;
  double lat;
  double lon;
  String username;
  String password;
  DateTime createdAt;
  String pharmacyName;
  String contactNumber;
  String email;
  String workingHours;
  List<String> services;
  dynamic ratings;
  dynamic reviewsCount;
  String licenseNumber;
  List<String> paymentMethods;
  bool status;

  PharmacyModel({
    required this.id,
    required this.pharmacistName,
    required this.experience,
    required this.about,
    required this.image,
    required this.locationName,
    required this.lat,
    required this.lon,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.pharmacyName,
    required this.contactNumber,
    required this.email,
    required this.workingHours,
    required this.services,
    required this.ratings,
    required this.reviewsCount,
    required this.licenseNumber,
    required this.paymentMethods,
    required this.status,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) => PharmacyModel(
    id: json["id"],
    pharmacistName: json["pharmacist_name"],
    experience: json["experience"],
    about: json["about"],
    image: json["image"] ?? "",
    locationName: json["location_name"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    username: json["username"],
    password: json["password"],
    createdAt: DateTime.parse(json["created_at"]),
    pharmacyName: json["pharmacy_name"],
    contactNumber: json["contact_number"],
    email: json["email"],
    workingHours: json["working_hours"],
    services: List<String>.from(json["services"].map((x) => x)),
    ratings: json["ratings"],
    reviewsCount: json["reviews_count"],
    licenseNumber: json["license_number"],
    paymentMethods: List<String>.from(json["payment_methods"].map((x) => x)),
    status: json["status"] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pharmacist_name": pharmacistName,
    "experience": experience,
    "about": about,
    "image": image,
    "location_name": locationName,
    "lat": lat,
    "lon": lon,
    "username": username,
    "password": password,
    "created_at": createdAt.toIso8601String(),
    "pharmacy_name": pharmacyName,
    "contact_number": contactNumber,
    "email": email,
    "working_hours": workingHours,
    "services": List<dynamic>.from(services.map((x) => x)),
    "ratings": ratings,
    "reviews_count": reviewsCount,
    "license_number": licenseNumber,
    "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x)),
    "status": status,
  };
}
