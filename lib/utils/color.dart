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
      return statusColors[0];
    case "Pending Approval":
      return statusColors[1];
    case "Approved":
      return statusColors[2];
    case "In Progress":
      return statusColors[3];
    case "Pending Review":
      return statusColors[4];
    case "On Hold":
      return statusColors[5];
    case "Completed":
      return statusColors[6];
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

const List<String> statusOptions = [
  "Planning",
  "Pending Approval",
  "Approved",
  "In Progress",
  "Pending Review",
  "On Hold",
  "Completed"
];

const List<Color> statusColors = [
  Color(0xFF90CAF9),
  Color(0xFFFFE0B2),
  Color(0xFFA5D6A7),
  Color(0xFF80CBC4),
  Color(0xFFCE93D8),
  Color(0xFFFFCDD2),
  Color(0xFFC8E6C9)
];

const List<Color> statusColorsText = [
  Colors.blue,
  Colors.orange,
  Colors.green,
  Colors.teal,
  Colors.purple,
  Colors.redAccent,
  Colors.green
];
// Danh sách các mức độ ưu tiên (Priority)
const List<String> priorityOptions = [
  "Low",
  "Normal",
  "High",
];

const List<Color> priorityColors = [Colors.blue, Colors.black, Colors.red];
