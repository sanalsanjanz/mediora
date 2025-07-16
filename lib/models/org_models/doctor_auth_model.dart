// To parse this JSON data, do
//
//     final doctorAuthModel = doctorAuthModelFromJson(jsonString);

import 'dart:convert';

import 'package:mediora/models/doctors_model.dart';

DoctorAuthModel doctorAuthModelFromJson(String str) =>
    DoctorAuthModel.fromJson(json.decode(str));

String doctorAuthModelToJson(DoctorAuthModel data) =>
    json.encode(data.toJson());

class DoctorAuthModel {
  DoctorsModel user;
  String type;

  DoctorAuthModel({required this.user, required this.type});

  factory DoctorAuthModel.fromJson(Map<String, dynamic> json) =>
      DoctorAuthModel(
        user: DoctorsModel.fromJson(json["user"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {"user": user.toJson(), "type": type};
}
