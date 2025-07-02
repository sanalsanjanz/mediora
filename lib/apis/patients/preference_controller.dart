import 'package:mediora/models/patient_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientController {
  static PatientModel? patientModel;
  static getPatientDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? response = preferences.getString("patientData");
    if (response != null) {
      patientModel = patientModelFromJson(response);
    }
  }
}
