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
  String? image;
  String? locationName;
  double lat;
  double lon;
  String username;
  String password;
  DateTime createdAt;

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
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) => PharmacyModel(
    id: json["id"],
    pharmacistName: json["pharmacist_name"],
    experience: json["experience"],
    about: json["about"],
    image: json["image"],
    locationName: json["location_name"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    username: json["username"],
    password: json["password"],
    createdAt: DateTime.parse(json["created_at"]),
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
  };
}
