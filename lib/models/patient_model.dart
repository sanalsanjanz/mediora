// To parse this JSON data, do
//
//     final patientModel = patientModelFromJson(jsonString);

import 'dart:convert';

PatientModel patientModelFromJson(String str) =>
    PatientModel.fromJson(json.decode(str));

String patientModelToJson(PatientModel data) => json.encode(data.toJson());

class PatientModel {
  String id;
  String name;
  int age;
  String gender;
  String location;
  double lat;
  double lon;
  String username;
  DateTime createdAt;
  String mobile;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.location,
    required this.lat,
    required this.lon,
    required this.username,
    required this.createdAt,
    required this.mobile,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    id: json["id"],
    name: json["name"],
    age: json["age"],
    gender: json["gender"],
    location: json["location"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    username: json["username"],
    createdAt: DateTime.parse(json["created_at"]),
    mobile: json["mobile"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "age": age,
    "gender": gender,
    "location": location,
    "lat": lat,
    "lon": lon,
    "username": username,
    "created_at": createdAt.toIso8601String(),
    "mobile": mobile,
  };
}
