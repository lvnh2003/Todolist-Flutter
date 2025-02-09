import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:test/Model.dart';
import 'package:test/db/mongodb.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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

  Widget _buildTaskList(List data) {
    List<MongoDbModel> dataList =
        data.map<MongoDbModel>((json) => MongoDbModel.fromJson(json)).toList();

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
                    width: MediaQuery.of(context).size.width * 1.2,
                    child: ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        return TaskItem(
                          data: dataList[index],
                          onUpdate: () {
                            setState(() {});
                          }
                        );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: const [
            SizedBox(width: 100, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 100, child: Text("Due Date", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 100, child: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 100, child: Text("Owner", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 100, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
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
