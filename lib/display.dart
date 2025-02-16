import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:test/Model.dart';
import 'package:test/db/mongodb.dart';
import 'package:test/insert-owner.dart';
import 'package:test/insert.dart';
import 'package:test/utils/const.dart';
import 'package:test/utils/string.dart';
import 'package:test/component/TaskItem.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ValueNotifier<bool> _showExtraButtons = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _showExtraButtons,
              builder: (context, value, child) {
                return value
                    ? Stack(
                      alignment: Alignment.bottomRight,
                        children: [
                          Positioned(
                            bottom: 150,
                            right: 20,
                            width: 70,
                            height: 70,
                            child: _buildExtraButton(Icons.person, Colors.amber, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) {
                                return const InsertOwner();
                              }));
                            }),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 150,
                            width: 70,
                            height: 70,
                            child: _buildExtraButton(Icons.task, Colors.purple, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const MongoDbInsert();
                                  },
                                ),
                              );
                            }),
                          ),
                        ],
                      )
                    : SizedBox.shrink();
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              width: 70,
              height: 70,
              child: _buildToggleFloatingButton(),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: MongodbDatabase.getData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data.isNotEmpty) {
              return _buildTaskList(snapshot.data);
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

  Widget _buildToggleFloatingButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: () {
        _showExtraButtons.value = !_showExtraButtons.value; // Không cần setState()
      },
      shape: const CircleBorder(),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showExtraButtons,
        builder: (context, value, child) {
          return Icon(value ? Icons.close : Icons.add, color: Colors.white);
        },
      ),
    );
  }

 Widget _buildExtraButton(IconData icon, Color color, VoidCallback onPressed) {
  return FloatingActionButton(
    backgroundColor: color,
    onPressed: onPressed,
    shape: const CircleBorder(),
    child: Icon(icon, color: Colors.white),
  );
}

  Widget _buildTaskList(List data) {
    List<Task> dataList =
        data.map<Task>((json) => Task.fromJson(json)).toList();

    if (dataList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        _buildHeader(),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                _buildColumnHeaders(),
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 1.7,
                    child: ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        return TaskItem(
                            data: dataList[index],
                            onUpdate: () {
                              setState(() {});
                            });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnHeaders() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: const [
                SizedBox(
                    width: 140,
                    child: Text("Status",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 130,
                    child: Text("Due Date",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 120,
                    child: Text("Priority",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 150,
                    child: Text("Owner",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 100,
                    child: Text("Actions",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
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
        const SizedBox(height: 3),
      ],
    );
  }
}
