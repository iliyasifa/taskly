import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? _deviceHeight;
  String? _newTaskContent;
  Box? _box;
  _HomePageState();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight! * 0.15,
        title: const Text('Taskly!', style: TextStyle(fontSize: 25)),
      ),
      body: _tasksView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _tasksView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data as Box;
          return _tasksList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }

  Widget _tasksList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        var task = Task.fromMap(tasks[index]);

        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(task.timeStamp.toString()),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank,
            color: Colors.red,
          ),
          onTap: () {
            task.done = !task.done;
            setState(() {
              _box!.putAt(index, task.toMap());
            });
          },
          onLongPress: () {
            _box!.deleteAt(index);
            setState(() {});
          },
        );
      },
      itemCount: tasks.length,
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopUp,
      child: const Icon(Icons.add),
    );
  }

  void _displayTaskPopUp() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Add New Task!'),
            content: TextField(
              onSubmitted: (value) {
                if (_newTaskContent != null) {
                  var task = Task(
                    content: _newTaskContent!,
                    timeStamp: DateTime.now(),
                    done: false,
                  );
                  _box!.add(task.toMap());
                  setState(() {
                    _newTaskContent = null;
                    Navigator.of(context).pop();
                  });
                }
              },
              onChanged: (value) {
                _newTaskContent = value;
              },
            ),
          );
        });
  }
}
