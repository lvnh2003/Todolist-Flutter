import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:test/Model.dart';
import 'package:test/component/OptionPicker.dart';
import 'package:test/db/mongodb.dart';
import 'package:test/insert.dart';
import 'package:test/utils/color.dart';
import 'package:test/utils/const.dart';
import 'package:test/utils/string.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: _buildFloatingActionButton(context),
      body: SafeArea(
        child: FutureBuilder(
          future: MongodbDatabase.getData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              return _buildDataTable(snapshot.data);
            }
            return const Center(
                child: Text("No data available",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
          },
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const MongoDbInsert();
            },
          ),
        ).then((value) {
          setState(() {});
        })
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(List data) {
    List<MongoDbModel> dataList =
        data.map<MongoDbModel>((json) => MongoDbModel.fromJson(json)).toList();

    if (dataList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        const SizedBox(height: 60),
        _buildHeader(),
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Divider(
            thickness: 2,
            indent: 0,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.blueAccent),
                headingTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                columnSpacing: 20,
                border: TableBorder.all(color: Colors.grey, width: 0.5),
                columns: _buildDataColumns(),
                rows: dataList.map((data) => _buildDataRow(data)).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(label: Text("Project/Task")),
      DataColumn(label: Text("Status")),
      DataColumn(label: Text("Due Date")),
      DataColumn(label: Text("Priority")),
      DataColumn(label: Text("PICK")),
      DataColumn(label: Text("Owner")),
      DataColumn(label: Text("Notes")),
      DataColumn(label: Text("Actions")),
    ];
  }

  DataRow _buildDataRow(MongoDbModel data) {
    return DataRow(cells: [
      DataCell(GestureDetector(
          onDoubleTap: () {
            showDetailTask(context, data);
          },
          child: Text(data.name))),
      DataCell(
        GestureDetector(
          onTap: () async {
            showStatusPicker(context, data.status, (newStatus) async {
              await MongodbDatabase.updateStatus(data.id, newStatus);
              setState(() {
                data.status = newStatus;
              });
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColors[statusOptions.indexOf(data.status)],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              data.status,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      DataCell(
        Text(
          data.dueDate.toString().split(' ')[0],
          style: TextStyle(
            color: data.dueDate.isBefore(DateTime.now())
                ? Colors.red
                : Colors.black,
          ),
        ),
      ),
      DataCell(
        GestureDetector(
          onTap: () async {
            showPriorityPicker(context, data.priority, (newPriority) async {
              await MongodbDatabase.updatePriority(data.id, newPriority);
              setState(() {
                data.priority = newPriority;
              });
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: priorityColors[priorityOptions.indexOf(data.priority)],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              data.priority,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      DataCell(Text(data.pick)),
      DataCell(Text(data.owner)),
      DataCell(Text(data.notes, overflow: TextOverflow.ellipsis, maxLines: 1)),
      DataCell(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return MongoDbInsert();
                    },
                    settings: RouteSettings(arguments: data),
                  ),
                ).then((value) {
                  setState(() {});
                });
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                await deleteTask(context, data).then((value) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                lottieURL,
                animate: true,
              ),
            ),
          ),
          FadeInUp(
            from: 30,
            child: const Text(MyString.noneTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MyString.mainTitle,
            style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 3,
        ),
      ],
    );
  }

  void showStatusPicker(
      BuildContext context, String currentStatus, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return OptionPicker(
          title: "Select Status",
          options: statusOptions,
          colors: statusColors,
          currentSelection: currentStatus,
        );
      },
    ).then((selected) {
      if (selected != null) {
        onSelected(selected);
      }
    });
  }

  void showPriorityPicker(BuildContext context, String currentPriority,
      Function(String) onSelected) {
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