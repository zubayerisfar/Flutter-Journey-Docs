import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskModel> tasks = [];
  TextEditingController taskController = TextEditingController();

  Future<void> refreshTask() async {
    tasks = await TaskDatabase.getTasks();
    setState(() {});
  }

  Future<void> addTask() async {
    if (taskController.text.isEmpty) return;
    await TaskDatabase.insertTask(
      TaskModel(title: taskController.text, isDone: false),
    );
    taskController.clear();
    refreshTask();
  }

  Future<void> deleteTask(int id) async {
    await TaskDatabase.deleteTask(id);
    refreshTask();
  }

  Future<void> updateTask(TaskModel task) async {
    await TaskDatabase.updateTask(task);
    refreshTask();
  }

  Future<void> showUpdateDialog(TaskModel task) async {
  // Create a controller pre-filled with the current task title
  final editController = TextEditingController(text: task.title);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Update Task'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "Enter updated task",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close without saving
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isEmpty) return;

              // Call your update function with the modified title
              updateTask(
                TaskModel(
                  id: task.id,
                  title: editController.text.trim(),
                  isDone: task.isDone,
                ),
              );

              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
  @override
  void initState() {
    super.initState();
    // Example of inserting a task
    refreshTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite Task Manager')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: addTask, icon: Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index].isDone,
                    onChanged: (_) {
                      updateTask(
                        TaskModel(
                          id: tasks[index].id,
                          title: tasks[index].title,
                          isDone: !tasks[index].isDone,
                        ),
                      );
                    },
                  ),
                  // Removed unnecessary curly braces around index
                  title: Text('Task-${tasks[index].title}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showUpdateDialog(tasks[index]);
                        },
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: () => deleteTask(tasks[index].id!),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
