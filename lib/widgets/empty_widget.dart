import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/preference_controller.dart';

Widget buildEmptyState({
  required String message,
  required void Function()? onPressed,
  String btn = "Refresh",
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 50),

        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[100]!, Colors.blue[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.search_off, size: 60, color: Colors.blue[300]),
        ),
        SizedBox(height: 24),
        Text(
          'No Result found',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Sorry ${PatientController.patientModel?.name}\n$message',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.refresh),
          label: Text(btn),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    ),
  );
}
