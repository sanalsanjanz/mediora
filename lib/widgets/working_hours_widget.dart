import 'package:flutter/material.dart';

Widget buildWorkingHour(String day, String time) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 14,
            color: time == 'Closed' ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
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
