// To parse this JSON data, do
//
//     final Model = ModelFromJson(jsonString);

import 'dart:convert';

Task TaskFromJson(String str) => Task.fromJson(json.decode(str));

String TaskToJson(Task data) => json.encode(data.toJson());

class Task {
    String id;
    String name;
    String status;
    String priority;
    DateTime dueDate;
    String owner;
    final String? ownerImage;

    Task({
      required this.id,
      required this.name,
      required this.status,
      required this.priority,
      required this.dueDate,
      required this.owner,
      this.ownerImage,
    });

    factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["_id"],
        name: json["name"],
        status: json["status"],
        priority: json["priority"],
        dueDate: DateTime.parse(json["due_date"]),
        owner: json["owner"] is Map<String, dynamic> ? json["owner"]["name"] : json["owner"],
        ownerImage: json["owner"] is Map<String, dynamic> ? json["owner"]["image_base64"] : null,
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "status": status,
        "priority": priority,
        "due_date": "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
        "owner": {
          "name": owner,
          "image_base64": ownerImage,
        },
    };
}
