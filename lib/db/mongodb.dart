import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/Model.dart';
import 'package:test/db/constant.dart';

class MongodbDatabase{
  static var db, userCollection;

  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }

  static Future<List<Map<String, dynamic>>> getData() async{
    final arrData = await userCollection.find().toList();
    return arrData;
  }

  static Future<String> insert(MongoDbModel data) async{
    try {
      var result = await userCollection.insertOne(data.toJson());
      if(result.isSuccess){
        return "Data inserted successfully";
      }
      else{
        return "Failed to insert data";
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }


 static Future<void> update(MongoDbModel data) async {
  try {
    var response = await userCollection.updateOne(
      where.eq("_id", data.id),
      modify
          .set("name", data.name)
          .set("status", data.status)
          .set("priority", data.priority)
          .set("PICK", data.pick)
          .set("due_date", data.dueDate.toIso8601String())
          .set("owner", data.owner)
          .set("notes", data.notes),
    );
    inspect(response);
    } catch (e) {
      inspect(e);
      print(e.toString());
    }
  }

  static Future<void> delete(String id) async {
    try {
      var response = await userCollection.deleteOne(where.eq("_id", id));
      inspect(response);
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> updateStatus(String id, String newStatus) async {
  await userCollection.updateOne(
    where.eq('_id', id),
    modify.set('status', newStatus),
  );
}
  static Future<void> updatePriority(String id, String newPriority) async {
  await userCollection.updateOne(
    where.eq('_id', id),
    modify.set('priority', newPriority),
  );
  }
  static Future<void> close() async {
    await db.close();
  }
}