import 'package:flutter/material.dart';
import 'package:test/component/CustomDropdownFormField.dart';
import 'package:test/component/CustomTextFormField.dart';
import 'package:test/Model.dart';
import 'package:test/db/mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import 'package:test/utils/color.dart';
import 'package:test/utils/const.dart';
import 'package:test/utils/string.dart';
// Removed unused import

class MongoDbInsert extends StatefulWidget {
  const MongoDbInsert({super.key});

  @override
  _MongoDbInsertState createState() => _MongoDbInsertState();
}

class _MongoDbInsertState extends State<MongoDbInsert> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ownerController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  String status = "Planning";
  String priority = "High";
  String pick = "Easy/ Low Value";
  DateTime dueDate = DateTime.now();

  String _checkInsertUpdate = "Insert";
  MongoDbModel? data;
  DateTime? time;
  DateTime? date;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is MongoDbModel) {
        setState(() {
          _checkInsertUpdate = "Update";
          data = args;
          nameController.text = data!.name;
          ownerController.text = data!.owner;
          notesController.text = data!.notes;
          status = data!.status;
          priority = data!.priority;
          pick = data!.pick;
          dueDate = data!.dueDate;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 70,
                      child: Divider(
                        thickness: 2,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                          text: _checkInsertUpdate,
                          style: const TextStyle(
                              fontSize: 30, color: Colors.black),
                          children: const [
                            TextSpan(
                              text: MyString.taskStrnig,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ]),
                    ),
                    const SizedBox(
                      width: 70,
                      child: Divider(
                        thickness: 2,
                      ),
                    ),
                  ],
                ),
              ),
              CustomTextFormField(
                controller: nameController,
                labelText: "Name",
                validator: (value) => value!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 20),
              CustomDropdownFormField<String>(
                labelText: "Status",
                value: status,
                items: ["Planning", "Pending Approval","Approved","In Progress", "Pending Review", "On Hold", "Completed"],
                onChanged: (value) => setState(() => status = value!),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tileColor: Colors.grey[200], // Màu nền nhẹ để nổi bật
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bo góc mềm mại
                  side: BorderSide(color: Colors.grey.shade400), // Viền nhẹ
                ),
                leading:
                    const Icon(Icons.calendar_today, color: Colors.blueAccent),
                title: Text(
                  "Due Date: ${dueDate.toString().split(' ')[0]}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing:
                    const Icon(Icons.edit_calendar, color: Colors.blueAccent),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              CustomDropdownFormField<String>(
                labelText: "Priority",
                value: priority,
                items: ["High", "Normal", "Low"],
                onChanged: (value) => setState(() => priority = value!),
              ),
              const SizedBox(height: 20),
              CustomDropdownFormField<String>(
                labelText: "PICK",
                value: pick,
                items: [
                  "Easy/ Low Value",
                  "Easy/ High Value",
                  "Hard/ Low Value",
                  "Hard/ High Value"
                ],
                onChanged: (value) => setState(() => pick = value!),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: ownerController,
                labelText: "Owner",
                validator: (value) => value!.isEmpty ? "Enter owner" : null,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: notesController,
                labelText: "Notes",
              ),
              const SizedBox(height: 20),
              MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            minWidth: 150,
            height: 55,
            onPressed: () {
              isTaskAlreadyExistUpdateTask();
            },
            color: MyColors.primaryColor,
            child: Text(
              _checkInsertUpdate,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
      });
    }
  }
  dynamic isTaskAlreadyExistUpdateTask() {
    if(nameController.text.isEmpty || ownerController.text.isEmpty){
      return emptyFieldsWarning(context);
    }
    if (_checkInsertUpdate == "Update" &&
        nameController.text == data!.name &&
        ownerController.text == data!.owner &&
        notesController.text == data!.notes &&
        status == data!.status &&
        priority == data!.priority &&
        pick == data!.pick &&
        dueDate == data!.dueDate) {
      return nothingEnterOnUpdateTaskMode(context);
    }
    if (_checkInsertUpdate == "Insert") {
      _insertData();
    } else {
      _updateData(
          data!.id,
          nameController.text,
          status,
          dueDate,
          pick,
          ownerController.text,
          notesController.text,
          priority);
    }
  }
  Future<void> _updateData(var id, String name, String status, DateTime dueDate,
      String pick, String owner, String notes, String priority) async {
    final updateData = MongoDbModel(
        id: id,
        name: name,
        status: status,
        dueDate: dueDate,
        pick: pick,
        owner: owner,
        notes: notes,
        priority: priority);

    await MongodbDatabase.update(updateData);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Data updated successfully")));

    Navigator.pop(context);
  }

  Future<void> _insertData() async {
    var id = mongo_dart.ObjectId();

    final data = MongoDbModel(
        id: id.toHexString(),
        name: nameController.text,
        status: status,
        dueDate: dueDate,
        pick: pick,
        owner: ownerController.text,
        notes: notesController.text,
        priority: priority);

    await MongodbDatabase.insert(data);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Data inserted successfully")));
    _clearFields();
  }

  void _clearFields() {
    nameController.clear();
    ownerController.clear();
    notesController.clear();
    setState(() {
      priority = "High";
      dueDate = DateTime.now();
    });
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}


