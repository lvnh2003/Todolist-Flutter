import 'package:flutter/material.dart';
import 'package:test/component/CustomDropdownFormField.dart';
import 'package:test/component/CustomTextFormField.dart';
import 'package:test/Model.dart';
import 'package:test/component/MyAppBar.dart';
import 'package:test/component/OwnerSelectionDropdown.dart';
import 'package:test/db/mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import 'package:test/utils/color.dart';
import 'package:test/utils/const.dart';
import 'package:test/utils/string.dart';

class MongoDbInsert extends StatefulWidget {
  const MongoDbInsert({super.key});

  @override
  _MongoDbInsertState createState() => _MongoDbInsertState();
}

class _MongoDbInsertState extends State<MongoDbInsert> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  String? ownerImageUrl;
  String status = "Planning";
  String priority = "High";
  DateTime dueDate = DateTime.now();

  String _checkInsertUpdate = "Insert";
  Task? data;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Task) {
        setState(() {
          _checkInsertUpdate = "Update";
          data = args;
          nameController.text = data!.name;
          ownerController.text = data!.owner;
          status = data!.status;
          priority = data!.priority;
          dueDate = data!.dueDate;
          ownerImageUrl = data?.ownerImage;
        });
      } else {
        setState(() {
          _checkInsertUpdate = "Insert";
          ownerImageUrl = null; // Gán mặc định khi insert
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: nameController,
                  labelText: "Name",
                  validator: (value) => value!.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 20),
                CustomDropdownFormField<String>(
                  labelText: "Status",
                  value: status,
                  items: [
                    "Planning",
                    "Pending Approval",
                    "Approved",
                    "In Progress",
                    "Pending Review",
                    "On Hold",
                    "Completed"
                  ],
                  onChanged: (value) => setState(() => status = value!),
                ),
                const SizedBox(height: 20),
                _buildDueDateTile(),
                const SizedBox(height: 20),
                CustomDropdownFormField<String>(
                  labelText: "Priority",
                  value: priority,
                  items: ["High", "Normal", "Low"],
                  onChanged: (value) => setState(() => priority = value!),
                ),
                const SizedBox(height: 20),
                OwnerSelectionDropdown(
                  initialOwner: data != null
                      ? {'name': data!.owner, 'image': ownerImageUrl}
                      : {'name': '', 'image': null},
                  onSelected: (String ownerName, String? ownerImage) {
                    setState(() {
                      ownerController.text = ownerName;
                      ownerImageUrl = ownerImage;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
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
              style: const TextStyle(fontSize: 30, color: Colors.black),
              children: const [
                TextSpan(
                  text: MyString.taskStrnig,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 70,
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
      title: Text(
        "Due Date: ${dueDate.toString().split(' ')[0]}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.edit_calendar, color: Colors.blueAccent),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildSubmitButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      minWidth: 150,
      height: 55,
      onPressed: isTaskAlreadyExistUpdateTask,
      color: MyColors.primaryColor,
      child: Text(
        "💾  ${_checkInsertUpdate}",
        style: const TextStyle(
          color: Colors.white,
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
    if (nameController.text.isEmpty || ownerController.text.isEmpty) {
      return emptyFieldsWarning(context);
    }
    if (_checkInsertUpdate == "Update" &&
        nameController.text == data!.name &&
        ownerController.text == data!.owner &&
        status == data!.status &&
        priority == data!.priority &&
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
        ownerController.text,
        priority,
        ownerImageUrl
      );
    }
  }

  Future<void> _updateData(
    var id,
    String name,
    String status,
    DateTime dueDate,
    String owner,
    String priority,
    String? ownerImage,
  ) async {
    final updateData = Task(
      id: id,
      name: name,
      status: status,
      dueDate: dueDate,
      owner: owner,
      priority: priority,
      ownerImage: ownerImage,
    );

    await MongodbDatabase.update(updateData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data updated successfully")),
    );

    Navigator.pop(context);
  }

  Future<void> _insertData() async {
    var id = mongo_dart.ObjectId();

    final data = Task(
      id: id.toHexString(),
      name: nameController.text,
      status: status,
      dueDate: dueDate,
      owner: ownerController.text,
      priority: priority,
      ownerImage: ownerImageUrl,
    );

    await MongodbDatabase.insert(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data inserted successfully")),
    );
    _clearFields();
  }

  void _clearFields() {
    nameController.clear();
    ownerController.clear();
    setState(() {
      priority = "High";
      dueDate = DateTime.now();
    });
  }
}

