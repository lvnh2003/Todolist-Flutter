import 'package:flutter/material.dart';
import 'package:test/Model.dart';
import 'package:test/db/mongodb.dart';
import 'package:test/component/OptionPicker.dart';
import 'package:test/insert.dart';
import 'package:test/utils/color.dart';
import 'package:test/utils/const.dart';

class TaskItem extends StatelessWidget {
  final MongoDbModel data;
  final VoidCallback onUpdate;

  TaskItem({required this.data, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        showStatusPicker(context, data.status, (newStatus) async {
                          await MongodbDatabase.updateStatus(data.id, newStatus);
                          onUpdate();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: getStatusColor(data.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data.status,
                          style: TextStyle(
                            color: statusColorsText[statusOptions.indexOf(data.status)]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      data.dueDate.toString().split(' ')[0],
                      style: TextStyle(
                        color: data.dueDate.isBefore(DateTime.now()) ? Colors.red : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        showPriorityPicker(context, data.priority, (newPriority) async {
                          await MongodbDatabase.updatePriority(data.id, newPriority);
                          onUpdate();
                        });
                      },
                      child: Text(
                        data.priority,
                        style: TextStyle(
                          color: priorityColors[priorityOptions.indexOf(data.priority)],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      data.owner,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => MongoDbInsert(),
                                settings: RouteSettings(arguments: data),
                              ),
                            ).then((value) {
                              onUpdate();
                            });
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            await deleteTask(context, data).then((value) {
                              onUpdate();
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showStatusPicker(BuildContext context, String currentStatus, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return OptionPicker(
          title: "Select Status",
          options: statusOptions,
          colors: statusColorsText,
          currentSelection: currentStatus,
        );
      },
    ).then((selected) {
      if (selected != null) {
        onSelected(selected);
      }
    });
  }

  void showPriorityPicker(BuildContext context, String currentPriority, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return OptionPicker(
          title: "Select Priority",
          options: priorityOptions,
          colors: priorityColors,
          currentSelection: currentPriority,
        );
      },
    ).then((selected) {
      if (selected != null) {
        onSelected(selected);
      }
    });
  }
}

