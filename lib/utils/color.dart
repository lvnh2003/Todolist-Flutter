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
      return Colors.blue;
    case "Pending Approval":
      return Colors.orange;
    case "Approved":
      return Colors.green;
    case "In Progress":
      return Colors.teal;
    case "Pending Review":
      return Colors.purple;
    case "On Hold":
      return Colors.redAccent;
    case "Completed":
      return Colors.green;
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

const List<Color> priorityColors = [
  Colors.blue,
  Colors.black,
  Colors.red
];