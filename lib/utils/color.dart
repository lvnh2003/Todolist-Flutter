import 'package:flutter/material.dart';

class MyColors {
  static const Color primaryColor = Color(0xff4568dc);
  static const List<Color> primaryGradientColor = [
    Color(0xff4568dc),
    Color(0xffb06ab3),
  ];
}

Color getStatusColor(String status) {
  switch (status) {
    case "Planning":
      return Colors.orange;
    case "Approved":
      return Colors.green;
    case "Pending Review":
      return Colors.redAccent;
    case "Completed":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Color getPriorityColor(String status) {
  switch (status) {
    case "High":
      return Colors.red;
    case "Normal":
      return Colors.black;
    case "Low":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
