// To parse this JSON data, do
//
//     final Model = ModelFromJson(jsonString);

import 'dart:convert';

MongoDbModel MongoDbModelFromJson(String str) => MongoDbModel.fromJson(json.decode(str));

String MongoDbModelToJson(MongoDbModel data) => json.encode(data.toJson());

class MongoDbModel {
    String id;
    String name;
    String status;
    String priority;
    String pick;
    DateTime dueDate;
    String owner;
    String notes;

    MongoDbModel({
      required this.id,
      required this.name,
      required this.status,
      required this.priority,
      required this.pick,
      required this.dueDate,
      required this.owner,
      required this.notes,
    });

    factory MongoDbModel.fromJson(Map<String, dynamic> json) => MongoDbModel(
        id: json["_id"],
        name: json["name"],
        status: json["status"],
        priority: json["priority"],
        pick: json["PICK"],
        dueDate: DateTime.parse(json["due_date"]),
        owner: json["owner"],
        notes: json["notes"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "status": status,
        "priority": priority,
        "PICK": pick,
        "due_date": "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
        "owner": owner,
        "notes": notes,
    };
}
