import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'task_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late FirebaseService _firebaseService;
  final TextEditingController _controller = TextEditingController();
  final String testUserId = 'test_user_id';

  String selectedDay = 'Monday';
  String selectedHour = '9 am - 10 am';

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
  }

  void _addTask() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      final task = Task(
        id: '',
        name: name,
        day: selectedDay,
        hour: selectedHour,
      );
      _firebaseService.addTask(testUserId, task);
      _controller.clear();
    }
  }

  void _toggleComplete(Task task) {
    task.isDone = !task.isDone;
    _firebaseService.updateTask(testUserId, task);
  }

  void _deleteTask(String id) {
    _firebaseService.deleteTask(testUserId, id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Manager")),
      body: Column(
        children: [
          // Input UI
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: "Enter task"),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: selectedDay,
                items:
                    ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                        .map(
                          (day) =>
                              DropdownMenuItem(value: day, child: Text(day)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedDay = val!),
              ),
              DropdownButton<String>(
                value: selectedHour,
                items:
                    ['9 am - 10 am', '12 pm - 2 pm', '3 pm - 5 pm']
                        .map(
                          (hour) =>
                              DropdownMenuItem(value: hour, child: Text(hour)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedHour = val!),
              ),
              IconButton(onPressed: _addTask, icon: const Icon(Icons.add)),
            ],
          ),

          const Divider(),

          // Task List
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _firebaseService.getTasks(testUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!;

                // Group tasks by day > hour
                final grouped = <String, Map<String, List<Task>>>{};
                for (var task in tasks) {
                  grouped.putIfAbsent(task.day, () => {});
                  grouped[task.day]!.putIfAbsent(task.hour, () => []);
                  grouped[task.day]![task.hour]!.add(task);
                }

                return ListView(
                  children:
                      grouped.entries.map((dayEntry) {
                        return ExpansionTile(
                          title: Text(
                            "📅 ${dayEntry.key}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children:
                              dayEntry.value.entries.map((hourEntry) {
                                return ExpansionTile(
                                  title: Text("🕒 ${hourEntry.key}"),
                                  children:
                                      hourEntry.value.map((task) {
                                        return ListTile(
                                          title: Text(
                                            task.name,
                                            style: TextStyle(
                                              decoration:
                                                  task.isDone
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                            ),
                                          ),
                                          leading: Checkbox(
                                            value: task.isDone,
                                            onChanged:
                                                (_) => _toggleComplete(task),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed:
                                                () => _deleteTask(task.id),
                                          ),
                                        );
                                      }).toList(),
                                );
                              }).toList(),
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
