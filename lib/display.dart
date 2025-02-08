import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:test/Model.dart';
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
      floatingActionButton: GestureDetector(
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
            child: Center(child: Icon(Icons.add, color: Colors.white,),) ,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: MongodbDatabase.getData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.hasData) {
                List<MongoDbModel> dataList = snapshot.data
                    .map<MongoDbModel>((json) => MongoDbModel.fromJson(json))
                    .toList();

                if (dataList.isEmpty) {
                    return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      /// Lottie
                      FadeIn(
                        child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset(
                          lottieURL,
                          animate: snapshot.data.isNotEmpty ? false : true,
                        ),
                        ),
                      ),

                      /// Bottom Texts
                      FadeInUp(
                        from: 30,
                        child: const Text(MyString.noneTasks),
                      ),
                      ],
                    ),
                    );
                }

                return Column(
                  children: [
                    const SizedBox(height: 60),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MyString.mainTitle,
                            style: TextStyle(
                                fontSize: 45, fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                              /// Divider
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateColor.resolveWith(
                                (states) => Colors.blueAccent),
                            headingTextStyle: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                            columnSpacing: 20,
                            border: TableBorder.all(
                                color: Colors.grey, width: 0.5),
                            columns: [
                              DataColumn(label: Text("Project/Task")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Due Date")),
                              DataColumn(label: Text("Priority")),
                              DataColumn(label: Text("PICK")),
                              DataColumn(label: Text("Owner")),
                              DataColumn(label: Text("Notes")),
                              DataColumn(label: Text("Actions")),
                            ],
                            rows: dataList.map((data) {
                              return DataRow(cells: [
                                DataCell(
                                  GestureDetector(
                                    onDoubleTap: () {
                                      showDetailTask(context, data);
                                    },
                                  child: Text(data.name))
                                ),
                                DataCell(Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(data.status),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    data.status,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
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
                                DataCell(Text(data.priority,
                                    style: TextStyle(fontWeight: FontWeight.bold,color: getPriorityColor(data.priority)))),
                                    DataCell(Text(data.pick)),
                                DataCell(Text(data.owner)),
                                DataCell(Text(data.notes,
                                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return MongoDbInsert();
                                              },
                                              settings:
                                                  RouteSettings(arguments: data),
                                            ),
                                          ).then((value) {
                                            setState(() {});
                                          });
                                        },
                                      ),
                                      SizedBox(
                                          width: 8),
                                      IconButton(
                                        onPressed: () async {
                                          await deleteTask(context, data).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        icon: Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
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

}