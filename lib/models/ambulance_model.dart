// To parse this JSON data, do
//
//     final ambulanceModel = ambulanceModelFromJson(jsonString);

import 'dart:convert';

List<AmbulanceModel> ambulanceModelFromJson(String str) =>
    List<AmbulanceModel>.from(
      json.decode(str).map((x) => AmbulanceModel.fromJson(x)),
    );

String ambulanceModelToJson(List<AmbulanceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AmbulanceModel {
  String id;
  String serviceName;
  String primaryContact;
  String alternateContact;
  String location;
  double latitude;
  double longitude;
  String driverName;
  String driverLicenseNumber;
  DateTime createdAt;

  AmbulanceModel({
    required this.id,
    required this.serviceName,
    required this.primaryContact,
    required this.alternateContact,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.driverName,
    required this.driverLicenseNumber,
    required this.createdAt,
  });

  factory AmbulanceModel.fromJson(Map<String, dynamic> json) => AmbulanceModel(
    id: json["id"],
    serviceName: json["service_name"],
    primaryContact: json["primary_contact"],
    alternateContact: json["alternate_contact"],
    location: json["location"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    driverName: json["driver_name"],
    driverLicenseNumber: json["driver_license_number"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "service_name": serviceName,
    "primary_contact": primaryContact,
    "alternate_contact": alternateContact,
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "driver_name": driverName,
    "driver_license_number": driverLicenseNumber,
    "created_at": createdAt.toIso8601String(),
  };
}
