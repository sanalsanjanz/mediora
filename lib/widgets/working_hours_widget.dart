import 'package:flutter/material.dart';

Widget buildWorkingHour(String day, String time) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            color: time == 'Closed' ? Colors.red : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
